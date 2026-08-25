extends State
class_name DragonflyProjectile

@export var sprite : AnimatedSprite3D
@export var enemey_reference : CharacterBody3D
@export var number_of_projectiles : int = 4
@export var projectile_scene : PackedScene
@export var fire_interval : float = 3.0
@export var fire_distance : float = 10.0
@export var fire_distance_from_floor : float = 10.0
@export var fire_from_floor_variant : float = 5.0
@export var projectile_origin_offset := Vector3(0.0, 0.0, 0.22)
@export var projectile_emerge_distance : float = 0.3

var timer
var projectiles_fired = 0
var neutral_y
var neutral_x
var swooping = false


func enter():
	timer = 0
	projectiles_fired = 0


func exit():
	pass


func fire():
	var newInstance = projectile_scene.instantiate()
	var player := _find_player()
	var spawn_position := enemey_reference.global_position + projectile_origin_offset
	var target_position := spawn_position + Vector3.RIGHT
	if is_instance_valid(player):
		target_position = player.global_position + Vector3.UP * 0.25

	var launch_direction := target_position - spawn_position
	launch_direction.z = 0.0
	if launch_direction.is_zero_approx():
		launch_direction = Vector3.RIGHT
	launch_direction = launch_direction.normalized()

	# Start just inside the boss sprite so the spear visibly emerges from its body.
	newInstance.position = spawn_position + launch_direction * projectile_emerge_distance
	newInstance.flip = launch_direction.x < 0.0
	if newInstance.has_method("set_target_position"):
		newInstance.set_target_position(target_position)
	get_tree().root.add_child(newInstance)


func physicsUpdate(delta: float):
	timer = timer + delta
	if timer > fire_interval:
		fire()
		timer = 0
		projectiles_fired += 1
	if projectiles_fired >= number_of_projectiles:
		Transitioned.emit(self, "dragonflyidle")
		return


func update(_delta: float):
	pass


func _find_player() -> Node3D:
	var player := get_tree().get_first_node_in_group("Player") as Node3D
	if not is_instance_valid(player) and is_instance_valid(get_tree().current_scene):
		player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	return player
