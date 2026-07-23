class_name Shelf
extends StaticBody3D

@onready var shelf_items: Node3D = $ShelfItems
var is_stocked : bool

func stock_shelf() -> void:
	is_stocked = true
	shelf_items.visible = true


func empty_shelf() -> void:
	is_stocked = false
	shelf_items.visible = false
