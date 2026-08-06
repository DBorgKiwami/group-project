extends Area3D

@export var water_surface_y := 0.22
@export var float_height := 0.48
@export var float_speed := 4.0
@export var sink_speed := 1.2
@export var water_drag := 2.0

var players_in_water: Array[Player3D] = []
var old_land_masks := {}


func _physics_process(delta: float) -> void:
	for player in players_in_water:
		if not is_instance_valid(player):
			continue

		var target_y := water_surface_y + float_height
		var pos := player.global_position

		if player.global_position.y < target_y:
			pos.y = move_toward(pos.y, target_y, float_speed * delta)
			player.global_position = pos
			player.velocity.y = max(player.velocity.y, -0.15)
		elif player.global_position.y > target_y + 0.08:
			pos.y = move_toward(pos.y, target_y + 0.08, sink_speed * delta)
			player.global_position = pos
			player.velocity.y = min(player.velocity.y, 0.0)

		player.velocity.x = move_toward(player.velocity.x, 0.0, water_drag * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, water_drag * delta)


func _on_area_entered(area: Area3D) -> void:
	var player = area.get_parent()
	if player is Player3D and not players_in_water.has(player):
		players_in_water.append(player)
		old_land_masks[player] = player.get_collision_mask_value(1)
		player.set_collision_mask_value(1, false)
		player.set_collision_mask_value(7, true)


func _on_area_exited(area: Area3D) -> void:
	var player = area.get_parent()
	if player is Player3D:
		players_in_water.erase(player)
		if old_land_masks.has(player):
			player.set_collision_mask_value(1, old_land_masks[player])
			old_land_masks.erase(player)
