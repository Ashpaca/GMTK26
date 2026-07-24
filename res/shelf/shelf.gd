class_name Shelf
extends StaticBody3D

@onready var shelf_items: Node3D = $ShelfItems
var individual_items : Array[Node3D]
var is_stocked : bool

func stock_shelf() -> void:
	is_stocked = true
	shelf_items.visible = true
	for item in individual_items:
		item.visible = true


func empty_shelf() -> void:
	is_stocked = false
	shelf_items.visible = false


func _on_test_signal() -> void:
	for item in individual_items:
		if item.visible:
			item.visible = false
			return
	is_stocked = false


func _ready() -> void:
	EventBus.test_signal.connect(_on_test_signal)
	individual_items.append_array(shelf_items.get_children())
