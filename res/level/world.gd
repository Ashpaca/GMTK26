extends Node3D

enum Tutorial{
	BEFORE,
	MOVEMENT,
	RUN,
	PICKUP,
	STOCK,
	CUSTOMER,
	DONE
}

const SHOPPER = preload("uid://bc26jrpphkke5")

@onready var doors: Node3D = $Doors
@onready var shelves: Node3D = $Shelves
@onready var spawn_points: Node3D = $SpawnPoints
@onready var despawn_points: Node3D = $DespawnPoints
var the_doors : Array[WallDoor]
var the_shelves : Array[Shelf]
var the_spawns : Array[Node3D]
var the_despawns : Array[Node3D]

var tutorial_point : Tutorial = Tutorial.BEFORE
var has_done_up : bool
var has_done_down : bool
var has_done_left : bool
var has_done_right : bool
@onready var up: AnimatedSprite3D = $Player/TutorialPopups/Up
@onready var down: AnimatedSprite3D = $Player/TutorialPopups/Down
@onready var left: AnimatedSprite3D = $Player/TutorialPopups/Left
@onready var right: AnimatedSprite3D = $Player/TutorialPopups/Right


func _on_request_start_game() -> void:
	tutorial_point = Tutorial.MOVEMENT


func _ready() -> void:
	EventBus.request_start_game.connect(_on_request_start_game)
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
	if not GameState.is_playing(): return
	
	match tutorial_point:
		Tutorial.BEFORE:
			pass
		Tutorial.MOVEMENT:
			if Input.is_action_pressed("move_up"):
				up.play("complete")
			if Input.is_action_pressed("move_down"):
				down.play("complete")
			if Input.is_action_pressed("move_left"):
				left.play("complete")
			if Input.is_action_pressed("move_right"):
				right.play("complete")
		Tutorial.RUN:
			pass
		Tutorial.PICKUP:
			pass
		Tutorial.STOCK:
			pass
		Tutorial.CUSTOMER:
			pass
		Tutorial.DONE:
			pass
