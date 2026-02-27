# Milestone 6 Verification Guide (Godot 4 Editor)

This guide provides the manual steps needed to verify that the Godot pipeline and tooling (Milestone 6) are working as intended in the Godot Editor.

## 1. Import Post-Processor Verification
To verify the automated collision generation, marker conversion, and material swapping:
1.  **Assign the Script:** Select any `.glb` model in the **FileSystem** dock. In the **Import** dock, find the **Import Script** property and assign `res://scripts/utils/ImportPostProcessor.gd`. Click **Reimport**.
2.  **Verify Collisions:**
    *   Ensure the mesh name ends in `-col` (e.g., `test_segment-col.glb`).
    *   Open the reimported scene. You should see a `StaticBody3D` and `CollisionShape3D` as children of the mesh.
3.  **Verify Markers:**
    *   In the original 3D model, ensure there are nodes named `Socket_Front` or `Socket_Back`.
    *   In the Godot scene, these should now be `Marker3D` nodes.
4.  **Verify Material Swapper:**
    *   Ensure the mesh node name contains the word "Snake".
    *   In the **MeshInstance3D** inspector, check the **Surface Material Override**. It should have the `Snake_Skin.tres` material applied.

## 2. Segment Snapper Tool Verification
To verify the "Visual Vibe Coding" tool:
1.  **Scene Setup:** Create a new scene and add a node with a `Marker3D` child named `Socket_Back`.
2.  **Instance a Segment:** Drag and drop `res://scenes/main/SnakeSegment.tscn` into the scene as a child of the node created in Step 1.
3.  **Automatic Snapping:** The instanced segment should immediately snap its position to the `Socket_Back` marker.
4.  **Tuck Margin:** In the **Inspector**, observe the segment's position. It should be offset by `-0.05m` on its local Z-axis relative to the socket, demonstrating the "tuck" margin.

## 3. Validation Script Verification
1.  **Run in Terminal:** Execute `python3 validate.py`.
2.  **Naming Check:** Temporarily rename a `.glb` to use `_col` instead of `-col`. The script should report an error.
3.  **Texture Check:** Create a dummy `.png.import` file with `type="Texture2D"` (not `CompressedTexture2D`) in `assets/textures/`. The script should report an error.
