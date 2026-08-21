extends CanvasLayer

@export var shop_item : PackedScene
@export var containter : VBoxContainer
var shop = ""

func _ready() -> void:
	SignalBus.connect("open_shop", show_shop_screen)
	SignalBus.connect("shop_done", close_shop_screen)
	return

func close_shop_screen():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func show_shop_screen(shop_id):
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var shop_details = Shop.get_shop(shop_id)
	shop = shop_id
	print("HIAHGIUEHGEIUEHGIUHERGOIHGEOIGHEROIGHEOIGRHOIERGHOIERGHOIGRH")
	print(Shop.get_shop(shop_id))
	
	for object in shop_details:
		var inst = shop_item.instantiate()
		inst.load_information(shop,object["name"],object["desc"],object["price"])
		containter.add_child(inst)
	print("HIAHGIUEHGEIUEHGIUHERGOIHGEOIGHEROIGHEOIGRHOIERGHOIERGHOIGRH")
