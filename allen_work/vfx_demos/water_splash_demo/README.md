# Water Splash VFX Demo

Small Godot 4.6 prototype for a pure pixel-art water splash effect.

This can be used later when a character skill hits water, lands on the pond surface, or triggers a small water impact.

## Controls

- `Space`: play the splash at the center.
- Left click: move the splash position and play it.

## What It Shows

- 6-frame pixel-art splash sprite sheet
- crown / cup shaped splash based on the new reference example
- connected water body, side splash arcs, and small pixel droplets
- cyan water body, darker blue shadow, and white highlight pixels
- simple water ripple line under the splash

## Notes

The Godot part is intentionally simple: one scene, one script, and a small sprite sheet. The script only chooses the current frame by timer, then draws it with nearest filtering.
