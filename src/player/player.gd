class_name Player
extends CharacterBody3D


const SPEED = 5.0
const HELD_SPEED = 3.5
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var interaction_zone: Area3D = $Visuals/InteractionZone
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var is_stocking : bool
var is_picking_up : bool
var is_dropping : bool
var held_item : Item
var shelf_to_stock : Shelf
var supply_to_grab : Supply
var run_speed_multiplier : float = 0.8
var steps_audios : Array[AudioStream] = [
	load("res://assets/sfx/steps/impactWood_heavy_000.ogg"),
	load("res://assets/sfx/steps/impactWood_heavy_001.ogg"),
	load("res://assets/sfx/steps/impactWood_heavy_002.ogg"),
	load("res://assets/sfx/steps/impactWood_heavy_003.ogg"),
	load("res://assets/sfx/steps/impactWood_heavy_004.ogg")
]

func handle_interaction() -> void:
	for body in interaction_zone.get_overlapping_bodies():
			if body is Shelf:
				var shelf : Shelf = body
				if not shelf.is_stocked and held_item:
					shelf.start_stocking()
					shelf_to_stock = shelf
					is_stocking = true
					animation_player.play("interact-right", -1, 2.0)
					return
			if body is Supply:
				if not held_item:
					supply_to_grab = body
					is_picking_up = true
					animation_player.play("pick-up")
				else:
					is_dropping = true
					animation_player.play_backwards("pick-up")


func is_running() -> bool:
	return run_speed_multiplier > 1.0


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "interact-right" and is_stocking:
		shelf_to_stock.stock_shelf()
		is_stocking = false
		held_item.queue_free()
	if anim_name == "pick-up":
		if is_picking_up:
			is_picking_up = false
			held_item = supply_to_grab.get_item(visuals)
		elif is_dropping:
			is_dropping = false
			held_item.queue_free()


func _on_game_over(_good_ending : bool) -> void:
	animation_player.play("die")


func _physics_process(delta: float) -> void:
	if not GameState.is_playing(): return
	if is_stocking or is_picking_up or is_dropping: return
	
	if Input.is_action_just_pressed("interact"):
		handle_interaction()
	if is_stocking or is_picking_up or is_dropping: return
	
	if Input.is_action_pressed("run"):
		navigation_agent_3d.radius = 1
		run_speed_multiplier = 1.1
	else:
		navigation_agent_3d.radius = 0.3
		run_speed_multiplier = 0.8
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, PI/4)
	if direction:
		visuals.look_at(global_position - direction)
		if not audio_stream_player.playing:
			audio_stream_player.stream = steps_audios.pick_random()
			audio_stream_player.play()
			if run_speed_multiplier > 1:
				audio_stream_player.pitch_scale = 1.2
			else:
				audio_stream_player.pitch_scale = 1
		if held_item:
			velocity.x = direction.x * HELD_SPEED * run_speed_multiplier
			velocity.z = direction.z * HELD_SPEED * run_speed_multiplier
			animation_player.play("walk_holding_character-employee")
		else:
			velocity.x = direction.x * SPEED * run_speed_multiplier
			velocity.z = direction.z * SPEED * run_speed_multiplier
			animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if held_item:
			animation_player.play("holding-both")
		else:
			animation_player.play("idle")
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _ready() -> void:
	EventBus.game_over.connect(_on_game_over)
