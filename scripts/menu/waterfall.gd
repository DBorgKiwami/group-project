@tool
extends Sprite2D

func _process(_delta):
	var mat = get_material()
	if mat:
		mat.set_shader_parameter("zoom", get_viewport_transform().y.y)

func _on_waterfall_item_rect_changed():
	var mat = get_material()
	if mat:
		mat.set_shader_parameter("scale", scale)
