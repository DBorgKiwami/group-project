extends Area3D

@export var water_surface_y := 0.22
@export var float_height := 0.48
@export var float_speed := 4.0
@export var sink_speed := 1.2
@export var water_drag := 2.0

var players_in_water: Array[Player3D] = []
var old_collision_masks := {}


func _physics_process(delta: float) -> void:
	for player in players_in_water:
		if not is_instance_valid(player):
			continue

		# The water should not let the player stand on the hidden pond floor.
		player.set_meta("in_pond_water", true)
		player.set_collision_mask_value(7, false)

		var target_y := water_surface_y + float_height
		var height_error := target_y - player.global_position.y
		var target_vertical_speed: float = clampf(height_error * 4.0, -1.0, 1.0)
		player.velocity.y = move_toward(player.velocity.y, target_vertical_speed, float_speed * delta)

		player.velocity.x = move_toward(player.velocity.x, 0.0, water_drag * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, water_drag * delta)


func _on_area_entered(area: Area3D) -> void:
	var player = area.get_parent()
	if player is Player3D and not players_in_water.has(player):
		players_in_water.append(player)
		player.set_meta("in_pond_water", true)
		old_collision_masks[player] = {
			"land": player.get_collision_mask_value(1),
			"pond_floor": player.get_collision_mask_value(7)
		}
		# Keep land collision for the shoreline, but do not stand on the pond floor.
		player.set_collision_mask_value(7, false)


func _on_area_exited(area: Area3D) -> void:
	var player = area.get_parent()
	if player is Player3D:
		players_in_water.erase(player)
		player.set_meta("in_pond_water", false)
		if old_collision_masks.has(player):
			var old_masks: Dictionary = old_collision_masks[player]
			player.set_collision_mask_value(1, old_masks["land"])
			player.set_collision_mask_value(7, old_masks["pond_floor"])
			old_collision_masks.erase(player)
