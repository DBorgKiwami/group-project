extends Control
class_name ShopItem

var active = false
var shop_tag = ""
var item = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and active:
			Shop.buy_item_from_shop(shop_tag, item)
			SignalBus.open_shop.emit(shop_tag)
			print($ColorRect/RichTextLabel.text)

func load_information(shop, price, name, desc):
	shop_tag = shop
	item = name
	$ColorRect/RichTextLabel.text = str(price) + " " + str(name) + " " + str(desc)

func _on_mouse_entered() -> void:
	print("Hello there")
	active = true


func _on_mouse_exited() -> void:
	print("Bye Bye")
	active = false
