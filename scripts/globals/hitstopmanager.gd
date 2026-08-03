extends Node

func hit_stop(len: float):
	Engine.time_scale = 0
	await get_tree().create_timer(len, true, false, true).timeout
	Engine.time_scale = 1
	pass
