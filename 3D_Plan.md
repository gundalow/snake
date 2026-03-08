# 3D Snake Model Integration Plan

## Ground Truth: Snake Rendering & Direction

As of Milestone 1 completion, the following facts are definitively verified for the `snake_Titanoboa` model:

### 1. Model Topology
- **Forward Vector (Intrinsic):** The model's visually forward direction (from tail to snout) is along its **Local Negative X Axis**.
- **Head/Snout Location:** The snout meshes (`teeth.001`, `mouth.001`) are centered at local $(0, 0, 0)$ in the provided GLTF instance.
- **Length:** The skeleton extends approximately $24.3$ units along the **Local Positive X Axis**.
- **Up Vector:** The model's "Up" is Local Y.

### 2. Transformation Basis (in `SnakeHead.tscn`)
To align this model with Godot's coordinate system (where $-Z$ is forward) and the game's 1x1x1 grid logic:
- **Basis:** `Transform3D(0, 0, -1, 0, 3, 0, 3, 0, 0, 0, -0.05, 0)`
  - **Local -X (Snout)** maps to **World -Z (Forward)**.
  - **Local Y (Up)** maps to **World Y (Up)**, scaled $3\times$.
  - **Local Z (Side)** maps to **World X (Right)**, scaled $3\times$.
- **Offset:** $Y = -0.05$ to sit the belly on the floor ($Y=0$). Snout is already at origin $X=0, Z=0$.

### 3. Movement Logic
- **Parent Rotation:** The `SnakeHead` node (pivot) rotates instantly to match the `heading`.
- **Inheritance:** The `SnakeModel` is a direct child and inherits this rotation perfectly.
- **No Smoothing:** The previous "smooth turn" logic (counter-rotating the child mesh) has been removed as it conflicted with the model's pre-rotation.

---

## Post-Mortem: False Assumptions & Lessons Learned

### False Assumptions
1.  **"Head is at the end of the Bone Range":** Initially, we found bones from $X = -1.5$ to $X = 22.8$ and assumed the head was at one of these extremes. While true, we guessed *which* end was the head multiple times instead of verifying mesh-to-material assignments.
2.  **"Godot Forward is the only Forward":** We assumed that rotating the model to face $-Z$ would "just work," forgetting that the logic in `SnakeHead.gd` was *also* manipulating the rotation of the child mesh to create a "smooth turn" effect.
3.  **"Logs tell the whole story":** We relied heavily on `global_position` logs. These confirmed the *pivot* was correct but provided zero information about *orientation*. A node can be in the exact right spot but facing the opposite direction.

### Why Mistakes Were Made
- **Code Interference:** We tried to fix orientation via the `.tscn` file while the `.gd` script was actively fighting us by applying its own rotational logic to the child nodes. We were fixing the transform in one place and breaking it in another.
- **Lack of Visual Debugging:** We spent too long looking at numbers in the console. The "Arrow Hat" (Magenta arrow) was the turning point; it provided an undeniable visual proof of where the model *thought* it was facing.
- **Premature Optimization/Clean-up:** We removed the debug boxes and logs before the user had visually confirmed the fix. This led to "flying blind" when the user reported it was still broken.

### How to Produce Better Software Next Time
- **Isolate the System:** When integrating a new asset, disable existing "juice" or secondary logic (like smooth turns) until the basic alignment is 100% verified.
- **Visual Over Numbers:** Always implement visual orientation markers (arrows, coordinate axes) at runtime for 3D assets.
- **Verify Asset Metadata:** Use inspection scripts (`tools/`) to check materials and mesh names immediately, rather than guessing based on bounding box extremes.
- **Step-by-Step Validation:** Do not proceed to "Bending" or "Growing" until the "Rigid Move" is confirmed visually and logically by all stakeholders.

---

## Future Milestones

### Milestone 2: Bending & Morphing
- Implement bone-based skinning to deform the $24.3$ unit mesh along the `position_history` path.

### Milestone 3: Growing & Length Adjustment
- Address the fact that the snake starts at full $24$-unit length.

### Milestone 4: Advanced Physics & Visuals
- Body collisions and shadows.

### Milestone 5: Animations
- Slither animation synchronization.
