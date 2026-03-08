# 3D Snake Model Integration Plan

## Milestone 1: Basic Rigid Movement (COMPLETE)

### 1. Ground Truth: snake_Titanoboa
The following configuration is definitively verified for the production model:

**Verified Transform3D:**
`Transform3D(0, 0, -1, 0, 3, 0, 3, 0, 0, 0, -0.05, 0.46)`

**Technical Breakdown for Junior Developers:**
Godot's `Transform3D` constructor takes 12 floats in this order: `Basis.x (3), Basis.y (3), Basis.z (3), Origin (3)`.

| Property | Value | Mapping & Logic |
| :--- | :--- | :--- |
| **Basis.x** | `(0, 0, -1)` | Maps model's **Local X** to **World -Z** (North). Length is 1.0 (1x scale). |
| **Basis.y** | `(0, 3, 0)` | Maps model's **Local Y** to **World +Y** (Up). Length is 3.0 (**3x vertical scale**). |
| **Basis.z** | `(3, 0, 0)` | Maps model's **Local Z** to **World +X** (East). Length is 3.0 (**3x horizontal scale**). |
| **Origin** | `(0, -0.05, 0.46)`| **Translation**: `0.46` on the Z-axis pulls the visual snout tip to $(0,0,0)$. `-0.05` aligns the belly with the floor. |

---

### 2. The "Wrong Ways" (Lessons Learned)
*   **Assuming Identity Rotation:** We initially tried `Transform3D.IDENTITY`. In many GLTF models, the head is NOT pointing along the $-Z$ axis. For Titanoboa, the head is along Local $+X$.
*   **Confusing Column Order:** In the 12-float constructor, the first three floats are NOT the position. They are the direction the local X-axis points.
*   **Ignoring Script Interference:** We spent hours fixing the `.tscn` while the `.gd` script was counter-rotating the mesh to create a "smooth turn." Always disable "juice" logic when calibrating base transforms.
*   **Relying on Numbers over Vision:** Positional logs confirmed the pivot was at $(0,0,0)$, but we couldn't see the snake was 180 degrees backward. The "Truth Arrows" (visual axis markers) were the only way to solve this.

---

## Milestone 2: Bending & Morphing (IN PROGRESS)

### 1. The Skeleton System
*   **Bones vs Nodes**: In Godot, bones are **internal data** within a `Skeleton3D` node. They are NOT nodes themselves.
*   **Bone Mapping**: Titanoboa has 91 bones.
    *   **Head**: `GLTF_created_0_rootJoint` through `Bone.086`.
    *   **Body/Spine**: `Bone.001` through `Bone.084`.
*   **Coordinate Spaces**:
    *   **Bone Rest**: The default "T-pose" of the bone.
    *   **Bone Pose**: The local transformation we apply.
    *   **Global Pose**: The final position of the bone relative to the `Skeleton3D` node.

### 2. Implementation Logic
To make the body follow a path:
1.  Use `skeleton.set_bone_global_pose_override(bone_idx, transform, 1.0, true)`.
2.  The `transform` must be in the **Skeleton node's local coordinate space**.
3.  Formula: `Target_Global_Transform * Skeleton_Node.global_transform.affine_inverse()`.

---

## Milestone 3: Growing & Length Adjustment
*   **Strategy**: Every bone in the skeleton has a `pose_scale`.
*   **Junior Tip**: To "hide" the tail, iterate through bones `Bone.020` to `Bone.084` and set their `pose_scale` to `Vector3.ZERO`. As the snake eats, scale them back to `Vector3.ONE` one by one.

---

## Milestone 5: Mouth & Eating Interactions
*   **Verification**: `Titanoboa` has no jaw bones but has `morph_0`.
*   **Discovery**: If `morph_0` does not open the mouth, we must use a **Vertex Shader** to procedurally move the vertices of the head mesh downward based on their distance from the snout.
*   **Logic**: `mouth_open_amount` (0.0 to 1.0) will be a uniform passed to the shader.
