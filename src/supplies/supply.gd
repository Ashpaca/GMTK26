class_name Supply
extends StaticBody3D

@export var stored_item : PackedScene
const ITEM_OFFSET : Vector3 = Vector3(0, .1, .25)

func get_item(getter : Node3D) -> Item:
	var item : Item = stored_item.instantiate()
	item.position = ITEM_OFFSET
	getter.add_child(item)
	return item
