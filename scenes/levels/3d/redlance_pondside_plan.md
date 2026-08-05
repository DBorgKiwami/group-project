# Redlance Pondside Playable Route Plan

This scene is now a larger environment blockout. It uses bigger stepped landmasses, deeper pond space, and oversized background cliffs so the level reads closer to the tutorial scale and the current art direction.

Route:

1. PlayerSpawn
2. Checkpoint_01_AfterPondEdge
3. CombatTrigger_01_To2DTestCombat
4. RewardMarker_01
5. Checkpoint_02_BeforeExit
6. LevelExit

Current trigger notes:

- CombatTrigger_01_To2DTestCombat uses the existing scene transition script and points to `res://scenes/levels/2d/testlevel2d.tscn`.
- WaterAreaPlaceholder now has simple pond float logic. If the player drops into the lake, they are pushed back toward the water surface instead of falling forever.
- Checkpoint and exit areas are named and shaped, but they do not have gameplay scripts yet.

The current trees, rocks, mushrooms, reeds, and lily pads are still broad blockout/detail dressing. Final structures and hand-polished props can be added separately.
