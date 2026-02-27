package main

import (
	. "github.com/godot-go/godot-go/pkg/builtin"
	. "github.com/godot-go/godot-go/pkg/core"
	. "github.com/godot-go/godot-go/pkg/gdclassimpl"
)

type SnakeHead struct {
	CharacterBody3DImpl
	speed     float32
	turnSpeed float32
}

func (s *SnakeHead) GetClassName() string {
	return "SnakeHead"
}

func (s *SnakeHead) GetParentClassName() string {
	return "CharacterBody3D"
}

func (s *SnakeHead) V_Ready() {
	s.speed = 10.0
	s.turnSpeed = 2.0
}

func (s *SnakeHead) V_PhysicsProcess(delta float64) {
	input := GetInputSingleton()

	uiLeft := NewStringNameWithUtf8Chars("ui_left")
	defer uiLeft.Destroy()
	uiRight := NewStringNameWithUtf8Chars("ui_right")
	defer uiRight.Destroy()

	turn := float32(0.0)
	if input.IsActionPressed(uiLeft, false) {
		turn += 1.0
	}
	if input.IsActionPressed(uiRight, false) {
		turn -= 1.0
	}

	// Rotate
	rotation := s.GetRotation()
	newRotationY := rotation.MemberGety() + turn*s.turnSpeed*float32(delta)
	newRotation := NewVector3WithFloat32Float32Float32(rotation.MemberGetx(), newRotationY, rotation.MemberGetz())
	s.SetRotation(newRotation)

	// Forward movement
	// In Godot, -Z is forward. Basis member Z is column 2.
	gt := s.GetGlobalTransform()
	basis := gt.MemberGetbasis()
	zAxis := basis.MemberGetz()
	forward := zAxis.Multiply_float(-1.0)
	velocity := forward.Multiply_float(s.speed)
	s.SetVelocity(velocity)

	s.MoveAndSlide()

	// Camera lag logic
	springArmName := NewStringWithUtf8Chars("SpringArm3D")
	defer springArmName.Destroy()
	springArmPath := NewNodePathWithString(springArmName)
	defer springArmPath.Destroy()

	node := s.GetNode(springArmPath)
	if node != nil {
		springArm, ok := ObjectCastTo(node, "SpringArm3D").(SpringArm3D)
		if ok {
			// Apply a bit of lag to the spring arm rotation relative to the head
			targetRotY := turn * 0.2 // Tilt slightly when turning
			currentRot := springArm.GetRotation()
			newRotY := currentRot.MemberGety() + (targetRotY-currentRot.MemberGety())*float32(delta*3.0)
			newRot := NewVector3WithFloat32Float32Float32(currentRot.MemberGetx(), newRotY, currentRot.MemberGetz())
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
	ClassDBRegisterClass(NewSnakeHeadFromOwnerObject, nil, nil, func(t *SnakeHead) {
		ClassDBBindMethodVirtual(t, "V_Ready", "_ready", nil, nil)
		ClassDBBindMethodVirtual(t, "V_PhysicsProcess", "_physics_process", []string{"delta"}, nil)
	})
}

func UnregisterClassSnakeHead() {
	ClassDBUnregisterClass[*SnakeHead]()
}
