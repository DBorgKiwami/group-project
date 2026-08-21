extends Node

var inGameShops : Dictionary = {"merchant": [
	{
		"name" : "TestItem1",
		"desc" : "This is a test",
		"price" : 5,
		"purchased" : false
	},
	{
		"name" : "TestItem2",
		"desc" : "This is a test as well",
		"price" : 10,
		"purchased" : false
	}
	]
	}

func get_shop(shop_id: String) -> Array:
	if inGameShops.has(shop_id):
		return inGameShops[shop_id]
	return []

func buy_item_from_shop(shop_id: String, item_name: String):
	print("Test 1")
	if inGameShops.has(shop_id):
		print("Test 2")
		for object in inGameShops[shop_id]:
			print("Test 3")
			print(object["name"])
			print(item_name)
			if object["name"] == item_name:
				print("Test 4")
				object["purchased"] = true
				PersistentData.store_data_collectible(object["name"],object["desc"])
