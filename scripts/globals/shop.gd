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
	if inGameShops.has(shop_id):
		for object in inGameShops[shop_id]:
			if object["name"] == item_name:
				object["purchased"] = true
				PersistentData.store_data_collectible(object["name"],object["desc"])
