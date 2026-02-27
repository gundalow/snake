package main

import "C"

import (
	"fmt"
	"os"
	"unsafe"

	. "github.com/godot-go/godot-go/pkg/builtin"
	. "github.com/godot-go/godot-go/pkg/core"
	. "github.com/godot-go/godot-go/pkg/ffi"
	. "github.com/godot-go/godot-go/pkg/gdclassimpl"
	"github.com/godot-go/godot-go/pkg/util"
)

// --- SnakeHead ---

type SnakeHead struct {
	CharacterBody3DImpl
	speed      float32
	turnSpeed  float32
	leanAmount float32
	frame      int
}

func (s *SnakeHead) GetClassName() string {
	return "SnakeHead"
}

func (s *SnakeHead) GetParentClassName() string {
	return "CharacterBody3D"
}

func (s *SnakeHead) V_Ready() {
	os.Stderr.WriteString("[SnakeHead] V_Ready\n")
	s.speed = 10.0
	s.turnSpeed = 3.0
	s.leanAmount = 0.2
	s.frame = 0
	s.SetPhysicsProcess(true)
}

func (s *SnakeHead) V_PhysicsProcess(delta float64) {
	s.frame++
	input := GetInputSingleton()

	snakeLeft := NewStringNameWithUtf8Chars("snake_left")
	defer snakeLeft.Destroy()
	snakeRight := NewStringNameWithUtf8Chars("snake_right")
	defer snakeRight.Destroy()

	leftStrength := input.GetActionStrength(snakeLeft, false)
	rightStrength := input.GetActionStrength(snakeRight, false)
	turn := float32(leftStrength - rightStrength)

	// Rotate Head
	if turn != 0 {
		s.RotateY(turn * s.turnSpeed * float32(delta))
	}

	// Forward movement
	gt := s.GetGlobalTransform()
	basis := (&gt).MemberGetbasis()
	zAxis := (&basis).MemberGetz()
	negZ := (&zAxis).Multiply_float(-1.0)
	velocity := (&negZ).Multiply_float(s.speed)

	s.SetVelocity(velocity)
	s.MoveAndSlide()

	if s.frame%120 == 0 {
		vX := (&velocity).MemberGetx()
		vZ := (&velocity).MemberGetz()
		fmt.Fprintf(os.Stderr, "[SnakeHead] Frame %d: Turn=%.2f, Vel=(%.2f, %.2f)\n", s.frame, turn, vX, vZ)
	}

	// Lean logic
	springArmName := NewStringWithUtf8Chars("SpringArm3D")
	defer springArmName.Destroy()
	springArmPath := NewNodePathWithString(springArmName)
	defer springArmPath.Destroy()

	node := s.GetNode(springArmPath)
	if node != nil {
		if springArm, ok := ObjectCastTo(node, "SpringArm3D").(SpringArm3D); ok {
			targetLean := turn * s.leanAmount
			currentRot := springArm.GetRotation()
			curLeanZ := (&currentRot).MemberGetz()
			newLeanZ := curLeanZ + (targetLean-curLeanZ)*float32(delta*5.0)

			curRotX := (&currentRot).MemberGetx()
			curRotY := (&currentRot).MemberGety()
			newRot := NewVector3WithFloat32Float32Float32(curRotX, curRotY, newLeanZ)
			springArm.SetRotation(newRot)
		}
	}
}

func NewSnakeHeadFromOwnerObject(owner *GodotObject) GDClass {
	obj := &SnakeHead{}
	obj.SetGodotObjectOwner(owner)
	return obj
}

func RegisterClassSnakeHead() {
	os.Stderr.WriteString("[SnakeHead] Registering class...\n")
	ClassDBRegisterClass(NewSnakeHeadFromOwnerObject, nil, nil, func(t *SnakeHead) {
		ClassDBBindMethodVirtual(t, "V_Ready", "_ready", nil, nil)
		ClassDBBindMethodVirtual(t, "V_PhysicsProcess", "_physics_process", []string{"delta"}, nil)
	})
}

// --- HUD ---

type HUD struct {
	CanvasLayerImpl
	label Label
}

func (h *HUD) GetClassName() string {
	return "HUD"
}

func (h *HUD) GetParentClassName() string {
	return "CanvasLayer"
}

func GetEngineSingleton() Engine {
	owner := (*GodotObject)(unsafe.Pointer(GetSingleton("Engine")))
	return NewEngineWithGodotOwnerObject(owner)
}

func (h *HUD) V_Ready() {
	os.Stderr.WriteString("[HUD] V_Ready\n")
	labelName := NewStringWithUtf8Chars("FPSLabel")
	defer labelName.Destroy()
	labelPath := NewNodePathWithString(labelName)
	defer labelPath.Destroy()

	node := h.GetNode(labelPath)
	if node != nil {
		if l, ok := ObjectCastTo(node, "Label").(Label); ok {
			h.label = l
		}
	}
	h.SetProcess(true)
}

func (h *HUD) V_Process(delta float64) {
	if h.label != nil {
		engine := GetEngineSingleton()
		fps := engine.GetFramesPerSecond()
		text := NewStringWithUtf8Chars(fmt.Sprintf("FPS: %.0f", fps))
		defer text.Destroy()
		h.label.SetText(text)
	}
}

func NewHUDFromOwnerObject(owner *GodotObject) GDClass {
	obj := &HUD{}
	obj.SetGodotObjectOwner(owner)
	return obj
}

func RegisterClassHUD() {
	os.Stderr.WriteString("[HUD] Registering class...\n")
	ClassDBRegisterClass(NewHUDFromOwnerObject, nil, nil, func(t *HUD) {
		ClassDBBindMethodVirtual(t, "V_Ready", "_ready", nil, nil)
		ClassDBBindMethodVirtual(t, "V_Process", "_process", []string{"delta"}, nil)
	})
}

// --- GDExtension Entry Point ---

func RegisterSnakeTypes() {
	os.Stderr.WriteString("[GDExtension] Scene Level initialization\n")
	RegisterClassSnakeHead()
	RegisterClassHUD()
}

func UnregisterSnakeTypes() {
	os.Stderr.WriteString("[GDExtension] Deinitialization\n")
	ClassDBUnregisterClass[*SnakeHead]()
	ClassDBUnregisterClass[*HUD]()
}

//export SnakeInit
func SnakeInit(p_get_proc_address unsafe.Pointer, p_library unsafe.Pointer, r_initialization unsafe.Pointer) uint8 {
	os.Stderr.WriteString("[GDExtension] SnakeInit entry point called\n")
	util.SetThreadName("snake-pilot")
	initObj := NewInitObject(
		(GDExtensionInterfaceGetProcAddress)(p_get_proc_address),
		(GDExtensionClassLibraryPtr)(p_library),
		(*GDExtensionInitialization)(r_initialization),
	)

	initObj.RegisterSceneInitializer(RegisterSnakeTypes)
	initObj.RegisterSceneTerminator(UnregisterSnakeTypes)

	if initObj.Init() {
		os.Stderr.WriteString("[GDExtension] Init successful\n")
		return 1
	}
	os.Stderr.WriteString("[GDExtension] Init failed\n")
	return 0
}

func main() {
}
