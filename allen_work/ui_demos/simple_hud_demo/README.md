# Simple HUD Demo

Small Godot 4.6 HUD prototype for the frog game.

This version only focuses on the player HUD. Other UI parts are removed for now.

## Controls

- `Space`: take 1 damage

## What It Shows

- player portrait using the team character sprite
- 5 heart health display
- empty heart state after damage
- short red portrait flash when the player takes damage

## Design Notes

- Health is shown as full hearts only.
- There are no half hearts.
- Each hit removes one heart.
- The portrait flash is only a visual feedback layer and does not edit the source character art.
