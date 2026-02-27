package main

import (
	"fmt"
	"unsafe"

	. "github.com/godot-go/godot-go/pkg/builtin"
	. "github.com/godot-go/godot-go/pkg/core"
	. "github.com/godot-go/godot-go/pkg/gdclassimpl"
)

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
	println("HUD is Ready!")
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
	ClassDBRegisterClass(NewHUDFromOwnerObject, nil, nil, func(t *HUD) {
		ClassDBBindMethodVirtual(t, "V_Ready", "_ready", nil, nil)
		ClassDBBindMethodVirtual(t, "V_Process", "_process", []string{"delta"}, nil)
	})
}

func UnregisterClassHUD() {
	ClassDBUnregisterClass[*HUD]()
}
