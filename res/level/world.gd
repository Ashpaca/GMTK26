extends Node3D

const SHOPPER = preload("uid://bc26jrpphkke5")

@onready var doors: Node3D = $Doors
@onready var shelves: Node3D = $Shelves
@onready var spawn_points: Node3D = $SpawnPoints
@onready var despawn_points: Node3D = $DespawnPoints
var the_doors : Array[WallDoor]
var the_shelves : Array[Shelf]
var the_spawns : Array[Node3D]
var the_despawns : Array[Node3D]

func _ready() -> void:
	EventBus.spawn_shopper.connect(_on_spawn_shopper)
	
	for door in doors.get_children():
		the_doors.append(door)
	for shelf in shelves.get_children():
		the_shelves.append(shelf)
	for point in spawn_points.get_children():
		the_spawns.append(point)
	for point in despawn_points.get_children():
		the_despawns.append(point)
	

func _on_spawn_shopper() -> void:
	var shopper_instance : Shopper = SHOPPER.instantiate()
	add_child(shopper_instance)
	shopper_instance.shelves_in_store = the_shelves
	shopper_instance.despawn_location = the_despawns.pick_random().global_position
	shopper_instance.global_position = the_spawns.pick_random().global_position
	


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		for door in the_doors:
			door.open()
