package main

import "C"

import (
	"unsafe"

	. "github.com/godot-go/godot-go/pkg/core"
	"github.com/godot-go/godot-go/pkg/ffi"
	"github.com/godot-go/godot-go/pkg/util"
)

func RegisterSnakeTypes() {
	println("[GDExtension] RegisterSnakeTypes called - Scene level")
	RegisterClassSnakeHead()
	RegisterClassHUD()
}

func UnregisterSnakeTypes() {
	println("[GDExtension] UnregisterSnakeTypes called")
	UnregisterClassSnakeHead()
	UnregisterClassHUD()
}

//export SnakeInit
func SnakeInit(p_get_proc_address unsafe.Pointer, p_library unsafe.Pointer, r_initialization unsafe.Pointer) bool {
	println("[GDExtension] SnakeInit entry point called")
	util.SetThreadName("snake-pilot")
	initObj := NewInitObject(
		(ffi.GDExtensionInterfaceGetProcAddress)(p_get_proc_address),
		(ffi.GDExtensionClassLibraryPtr)(p_library),
		(*ffi.GDExtensionInitialization)(r_initialization),
	)

	initObj.RegisterSceneInitializer(RegisterSnakeTypes)
	initObj.RegisterSceneTerminator(UnregisterSnakeTypes)

	result := initObj.Init()
	println("[GDExtension] initObj.Init completed with result:", result)
	return result
}

func main() {
}
