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
@onready var ui: CanvasLayer = $Ui
@onready var up: AnimatedSprite3D = $Player/TutorialPopups/Up
@onready var down: AnimatedSprite3D = $Player/TutorialPopups/Down
@onready var left: AnimatedSprite3D = $Player/TutorialPopups/Left
@onready var right: AnimatedSprite3D = $Player/TutorialPopups/Right
@onready var apple_indicators : Array[AnimatedSprite3D] = [$Supplies/Supply/AppleIndicator, $Supplies/Supply2/AppleIndicator, $Supplies/Supply3/AppleIndicator]
@onready var shelf_indicator: AnimatedSprite3D = $Shelves/Shelf4/ShelfIndicator
@onready var player: Player = $Player
var last_shopper : Shopper

func _on_request_start_game() -> void:
	tutorial_point = Tutorial.MOVEMENT
	ui.visible = true
	GameState.current_state = GameState.State.WAIT
	ui.do_next_dialogue()


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
	last_shopper = shopper_instance
	


func _physics_process(_delta: float) -> void:
	if not GameState.is_playing(): return
	if GameState.tutorial_complete:
		return
	match tutorial_point:
		Tutorial.BEFORE:
			ui.visible = false
		Tutorial.MOVEMENT:
			ui.visible = false
			up.visible = true
			down.visible = true
			left.visible = true
			right.visible = true
			if Input.is_action_pressed("move_up"):
				up.play("complete")
			if Input.is_action_pressed("move_down"):
				down.play("complete")
			if Input.is_action_pressed("move_left"):
				left.play("complete")
			if Input.is_action_pressed("move_right"):
				right.play("complete")
			if up.animation == "complete" and down.animation == "complete" and left.animation == "complete" and right.animation == "complete":
				tutorial_point = Tutorial.RUN
				up.visible = false
				down.visible = false
				left.visible = false
				right.visible = false
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				ui.do_next_dialogue()
		Tutorial.RUN:
			ui.visible = false
			if Input.is_action_just_released("run"):
				tutorial_point = Tutorial.PICKUP
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				ui.do_next_dialogue()
		Tutorial.PICKUP:
			ui.visible = false
			for apple in apple_indicators:
				apple.visible = true
			if player.held_item:
				for apple in apple_indicators:
					apple.visible = false
				tutorial_point = Tutorial.STOCK
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				ui.do_next_dialogue()
		Tutorial.STOCK:
			ui.visible = false
			shelf_indicator.visible = true
			if not player.held_item:
				shelf_indicator.visible = false
				tutorial_point = Tutorial.CUSTOMER
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				ui.do_next_dialogue()
		Tutorial.CUSTOMER:
			ui.visible = false
			for door in the_doors:
				door.open()
			_on_spawn_shopper()
			tutorial_point = Tutorial.DONE
		Tutorial.DONE:
			if not last_shopper:
				for door in the_doors:
					door.close()
				print("dad cut scene")
				GameState.tutorial_complete = true
