# Tongue Snap VFX Demo

Small Godot 4.6 prototype for testing a tongue attack VFX.

This is only a VFX sandbox. It uses a small reference image from the team's front-facing player sprite so the tongue color and origin can be checked against the real character.

## Controls

- `Space`: play the default tongue snap.
- Left click: move the target point and play the effect.

## What It Shows

- fast tongue extend
- tongue starts near the character's mouth
- character opens mouth while the tongue snap plays
- pink / coral tongue color matched to the character mouth and red scarf
- soft sticky hit frame
- quick retract
- small saliva / sticky droplets
- simple low-resolution test background

## Notes

The implementation is intentionally simple: one scene, one script, and basic `_draw()` calls. Later this can be replaced by an `AnimatedSprite2D` sprite sheet or a Line2D-based scene inside the real game.
