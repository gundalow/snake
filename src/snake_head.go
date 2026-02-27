package main

import (
	. "github.com/godot-go/godot-go/pkg/builtin"
	. "github.com/godot-go/godot-go/pkg/core"
	. "github.com/godot-go/godot-go/pkg/gdclassimpl"
)

type SnakeHead struct {
	CharacterBody3DImpl
	Speed      float64
	TurnSpeed  float64
	LeanAmount float64
}

func (s *SnakeHead) GetClassName() string {
	return "SnakeHead"
}

func (s *SnakeHead) GetParentClassName() string {
	return "CharacterBody3D"
}

func (s *SnakeHead) V_Ready() {
	println("SnakeHead is Ready!")
	s.Speed = 10.0
	s.TurnSpeed = 3.0
	s.LeanAmount = 0.2
}

func (s *SnakeHead) V_PhysicsProcess(delta float64) {
	input := GetInputSingleton()

	snakeLeft := NewStringNameWithUtf8Chars("snake_left")
	defer snakeLeft.Destroy()
	snakeRight := NewStringNameWithUtf8Chars("snake_right")
	defer snakeRight.Destroy()

	leftStrength := input.GetActionStrength(snakeLeft, false)
	rightStrength := input.GetActionStrength(snakeRight, false)
	turn := float32(leftStrength - rightStrength)

	// Rotate Head
	rotation := s.GetRotation()
	newRotationY := rotation.MemberGety() + turn*float32(s.TurnSpeed)*float32(delta)
	newRotation := NewVector3WithFloat32Float32Float32(rotation.MemberGetx(), newRotationY, rotation.MemberGetz())
	s.SetRotation(newRotation)

	// Forward movement
	gt := s.GetGlobalTransform()
	basis := gt.MemberGetbasis()
	zAxis := basis.MemberGetz()
	forward := zAxis.Multiply_float(-1.0)
	velocity := forward.Multiply_float(float32(s.Speed))
	s.SetVelocity(velocity)

	s.MoveAndSlide()

	// Lean logic for SpringArm3D
	springArmName := NewStringWithUtf8Chars("SpringArm3D")
	defer springArmName.Destroy()
	springArmPath := NewNodePathWithString(springArmName)
	defer springArmPath.Destroy()

	node := s.GetNode(springArmPath)
	if node != nil {
		springArm, ok := ObjectCastTo(node, "SpringArm3D").(SpringArm3D)
		if ok {
			targetLean := turn * float32(s.LeanAmount)
			currentRot := springArm.GetRotation()
			newLeanZ := currentRot.MemberGetz() + (targetLean-currentRot.MemberGetz())*float32(delta*5.0)
			newRot := NewVector3WithFloat32Float32Float32(currentRot.MemberGetx(), currentRot.MemberGety(), newLeanZ)
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
	println("Registering SnakeHead class...")
	ClassDBRegisterClass(NewSnakeHeadFromOwnerObject, nil, nil, func(t *SnakeHead) {
		ClassDBBindMethodVirtual(t, "V_Ready", "_ready", nil, nil)
		ClassDBBindMethodVirtual(t, "V_PhysicsProcess", "_physics_process", []string{"delta"}, nil)
	})
}

func UnregisterClassSnakeHead() {
	ClassDBUnregisterClass[*SnakeHead]()
}
