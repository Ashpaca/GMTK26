class_name Shelf
extends StaticBody3D

@onready var shelf_items: Node3D = $Visuals/ShelfItems
@onready var visuals: Node3D = $Visuals
@onready var stock_sfx: AudioStreamPlayer3D = $StockSFX

var individual_items : Array[Node3D]
var is_stocked : bool
var shelf_tween : Tween

func stock_shelf() -> void:
	is_stocked = true
	shelf_items.visible = true
	for item in individual_items:
		item.visible = true


func start_stocking()-> void:
	if shelf_tween:
		shelf_tween.kill()
	shelf_tween = create_tween()
	shelf_tween.tween_property(visuals, "scale", Vector3(1, 0.8, 1), .2)
	shelf_tween.tween_property(visuals, "scale", Vector3(1, 1, 1), .1)
	stock_sfx.play()


func empty_shelf() -> void:
	if shelf_tween:
		shelf_tween.kill()
	shelf_tween = create_tween()
	shelf_tween.tween_property(visuals, "scale", Vector3(1.1, 1.1, 1.1), .2)
	shelf_tween.tween_property(visuals, "scale", Vector3(1, 1, 1), .1)
	
	is_stocked = false
	shelf_items.visible = false


func take_item() -> bool:
	for i in range(individual_items.size()):
		var item : Node3D = individual_items[i]
		if item.visible:
			item.visible = false
			if i == individual_items.size() -1:
				empty_shelf()
			return true
	return false


func _ready() -> void:
	individual_items.append_array(shelf_items.get_children())
