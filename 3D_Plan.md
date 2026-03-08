# Plan: Final-Attempt Snake Orientation Debug

## Executive Summary
Previous attempts to fix the snake's 180-degree orientation issue have failed, despite logs confirming the pivot point is now correct. This indicates a fundamental disconnect between our assumption of the model's intrinsic "forward" direction and its visual reality. Positional logs are no longer sufficient. We must debug the model's rotation directly.

This plan abandons all prior rotational assumptions and implements a new visual validation strategy called the "Arrow Hat" to get an undeniable, in-game ground truth before making the final correction.

## Phase 1: The "Arrow Hat" (Visual Ground Truth)

**Hypothesis:** The model's visually-apparent "forward" direction is not aligned with what the code assumes to be its local forward axis.

**Validation Strategy:** We will programmatically attach a bright, arrow-shaped mesh to the snake's head. This arrow will be hard-coded to point along the model's assumed forward vector (local `-X`). By observing where this arrow points *in-game*, we can definitively determine the model's true orientation.

**Implementation Steps:**
1.  **Modify `scripts/utils/DebugLogger.gd`:** This script, which is already attached to the `SnakeHead`, will be given a new task.
2.  **Programmatically Create Arrow:** In the `_ready` function, the script will:
    *   Instantiate a new `MeshInstance3D`.
    *   Create a `PrismMesh` or `BoxMesh` resource, sized and shaped to look like a distinct arrow.
    *   Crucially, the arrow's geometry will be oriented to point along the **local negative X axis**.
    *   Assign a new, bright magenta `StandardMaterial3D` to the arrow for maximum visibility.
3.  **Attach Arrow to Head:**
    *   The script will find the `teeth_node` (`Object_11`) within the `SnakeModel`.
    *   It will add the newly created magenta arrow as a direct child of the `teeth_node`.

**Expected Outcome:**
When the game runs, a magenta arrow will be visibly "stuck" to the snake's snout. This arrow's direction relative to the snake's body provides the ground truth we need.

## Phase 2: Analysis & Final Correction

With the Arrow Hat in place, analysis is simple:

1.  **Run the game** and move the snake North (press the "Up" arrow key).
2.  **Observe the Arrow:**
    *   **If the magenta arrow points South (towards the camera/bottom of the screen):** Our core assumption was wrong. The model's visual forward is local `+X`. A 180-degree rotation is required.
    *   **If the magenta arrow points North (away from the camera):** Our assumption and rotation basis are correct, and the issue lies elsewhere (which is extremely unlikely at this point).
    *   **If the arrow points East or West:** The primary axis is not X, or there is an unhandled base rotation in the model hierarchy.
3.  **Calculate Final Transform:** Based on the observation, calculate the one, final `Transform3D` basis.
    *   If a 180-degree flip is needed, the `Basis.x` column will be flipped from `(0,0,1)` to `(0,0,-1)` and the `Basis.z` from `(-3,0,0)` to `(3,0,0)`. The origin offset will also be recalculated to keep the pivot correct.
4.  **Implement:** Apply the final transform to `SnakeModel` in `SnakeHead.tscn`.

This method replaces all guesswork with a clear, empirical visual test and will be the final step in resolving the orientation bug.
