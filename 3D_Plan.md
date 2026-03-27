# 3D Snake Model Integration Plan

## Ground Truth: snake_Titanoboa (Milestone 1 COMPLETE)

The following configuration is verified for the production model:

### 1. Transform Basis Breakdown
The `Transform3D` constructor uses 12 floats: `Transform3D(x_x, x_y, x_z, y_x, y_y, y_z, z_x, z_y, z_z, o_x, o_y, o_z)`

**Our Configuration:**
`Transform3D(0, 0, -1, 0, 3, 0, 3, 0, 0, 0, -0.05, 0.46)`

| Column | Vector | Mapping | Purpose |
| :--- | :--- | :--- | :--- |
| **X** | `(0, 0, -1)` | Local X $\rightarrow$ World -Z | Maps model length to World North. Scale = 1.0. |
| **Y** | `(0, 3, 0)` | Local Y $\rightarrow$ World +Y | Maps model up to World Up. **Scale = 3.0**. |
| **Z** | `(3, 0, 0)` | Local Z $\rightarrow$ World +X | Maps model side to World East. **Scale = 3.0**. |
| **Origin**| `(0, -0.05, 0.46)` | Translation | Centers snout at pivot and aligns with floor. |

**Why this works:**
- **Rotation:** By mapping Local X to World -Z, the snake's visual head (which is at Local X = 0.46) points North.
- **Scaling:** The basis vectors' lengths (3.0 for Y and Z) triple the snake's thickness while keeping length at 1.0.
- **Alignment:** The $0.46$ Z-offset pulls the snout tip exactly to the $(0,0,0)$ pivot.

---

## Milestone 2: Bending & Morphing (STARTING)

### 1. Requirements
- The snake body must follow the historical path of the head.
- Use bone-based skinning for the 91-bone skeleton.

### 2. Strategy: Spline-Based Bone Following
- **Resolution:** 91 bones over ~24 units $\approx 0.26$ units per bone.
- **Bone Mapping:** 
  - `Bone.001` through `Bone.084`.
  - Sample `position_history` at offsets of 0.26 units.
  - Apply `global_transform` to bones.

---

## Future Milestones

### Milestone 3: Growing & Length Adjustment
- **Strategy:** Sequential bone scaling. tail bones start at `0.0`.

### Milestone 5: Mouth & Eating Interactions
- **Morph Target:** `morph_0` (To be confirmed if this opens the jaw).
- **Fallback:** If `morph_0` is unsuitable, use vertex shader deformation for biting.
