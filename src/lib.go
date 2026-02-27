package main

import (
	"unsafe"

	. "github.com/godot-go/godot-go/pkg/core"
	"github.com/godot-go/godot-go/pkg/ffi"
	"github.com/godot-go/godot-go/pkg/util"
)

func RegisterSnakeTypes() {
	println("RegisterSnakeTypes called")
	RegisterClassSnakeHead()
}

func UnregisterSnakeTypes() {
	println("UnregisterSnakeTypes called")
	UnregisterClassSnakeHead()
}

//export SnakeInit
func SnakeInit(p_get_proc_address unsafe.Pointer, p_library unsafe.Pointer, r_initialization unsafe.Pointer) bool {
	println("SnakeInit called")
	util.SetThreadName("snake-pilot")
	initObj := NewInitObject(
		(ffi.GDExtensionInterfaceGetProcAddress)(p_get_proc_address),
		(ffi.GDExtensionClassLibraryPtr)(p_library),
		(*ffi.GDExtensionInitialization)(r_initialization),
	)
	initObj.RegisterSceneInitializer(RegisterSnakeTypes)
	initObj.RegisterSceneTerminator(UnregisterSnakeTypes)
	return initObj.Init()
}

func main() {
}
