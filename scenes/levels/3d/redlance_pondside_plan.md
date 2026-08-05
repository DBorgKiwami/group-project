# Redlance Pondside Playable Route Plan

This scene is still a blockout. The markers are here to show the intended playable route before final props and combat logic are added.

Route:

1. PlayerSpawn
2. Checkpoint_01_AfterPondEdge
3. CombatTrigger_01_To2DTestCombat
4. RewardMarker_01
5. Checkpoint_02_BeforeExit
6. LevelExit

Current trigger notes:

- CombatTrigger_01_To2DTestCombat uses the existing scene transition script and points to `res://scenes/levels/2d/testlevel2d.tscn`.
- WaterAreaPlaceholder is only a placeholder area for future water hazard or splash logic.
- Checkpoint and exit areas are named and shaped, but they do not have gameplay scripts yet.

The actual trees, rocks, branches, and final environmental props should still be added separately.
