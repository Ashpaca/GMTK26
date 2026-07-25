class_name Shopper
extends CharacterBody3D


static var skins : Array[PackedScene] = [
	load("res://assets/models/character-female-b.glb"), 
	load("res://assets/models/character-female-c.glb"), 
	load("res://assets/models/character-female-d.glb"), 
	load("res://assets/models/character-female-e.glb"), 
	load("res://assets/models/character-female-f.glb"), 
	load("res://assets/models/character-male-a.glb"), 
	load("res://assets/models/character-male-b.glb"), 
	load("res://assets/models/character-male-c.glb"), 
	load("res://assets/models/character-male-d.glb"), 
	load("res://assets/models/character-male-e.glb"), 
	load("res://assets/models/character-male-f.glb")]



enum State{
	WALK,
	GRAB,
	WAIT,
	DEAD,
	GET_UP
}

const SPEED : float = 2
const DEATH_OFFSET : Vector3 = Vector3(0, 0, -.35)
@export var shelves_in_store : Array[Shelf]
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = visuals.get_child(1)
var visuals: Node3D
@onready var get_up_timer: Timer = $GetUpTimer
var current_state : State = State.WAIT
var has_item : bool
var closest_shelf : Shelf
var despawn_location : Vector3



func do_walk(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	var next_point : Vector3 = (navigation_agent_3d.get_next_path_position() - global_position) * SPEED
	navigation_agent_3d.velocity = next_point
	
	if velocity.is_zero_approx():
		animation_player.play("idle")
	else:
		animation_player.play("walk")
		
		var angle_current : float = visuals.rotation.y
		visuals.look_at(velocity + global_position)
		var angle_goal : float = visuals.rotation.y
		visuals.rotation.y = rotate_toward(angle_current, angle_goal, delta * 10)
	
	if navigation_agent_3d.is_navigation_finished():
		current_state = State.GRAB
	move_and_slide()


func do_wait() -> void:
	var nav_map : RID = get_world_3d().navigation_map
	if NavigationServer3D.map_get_iteration_id(nav_map) < 2:
		return
	var target_shelf_location : Vector3 = shelves_in_store.pick_random().global_position
	var valid_shopping_location : Vector3 = NavigationServer3D.map_get_closest_point(nav_map, target_shelf_location - target_shelf_location.y * Vector3.UP)
	navigation_agent_3d.target_position = valid_shopping_location
	current_state = State.WALK


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if current_state != State.WALK:
		return
	velocity = Vector3(safe_velocity.x, 0, safe_velocity.z).normalized() * SPEED


func _on_player_detector_body_entered(body: Node3D) -> void:
	if current_state == State.DEAD:
		return
	if body is Player:
		var player : Player = body
		if player.is_running():
			visuals.look_at(player.global_position)
			animation_player.play("die")
			visuals.position = DEATH_OFFSET.rotated(Vector3.UP, visuals.rotation.y)
			current_state = State.DEAD
			get_up_timer.start()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die" and current_state == State.GET_UP:
		visuals.position = Vector3.ZERO
		current_state = State.WALK
	if anim_name == "interact-right" and current_state == State.GRAB:
		if closest_shelf.is_stocked:
			closest_shelf.take_item()
			current_state = State.WALK
			has_item = true
			navigation_agent_3d.avoidance_priority = 1.0
			navigation_agent_3d.target_position = despawn_location
		else:
			current_state = State.WAIT


func _on_get_up_timer_timeout() -> void:
	if GameState.current_state == GameState.State.END:
		return
	animation_player.play_backwards("die")
	current_state = State.GET_UP


func _on_navigation_agent_3d_target_reached() -> void:
	if has_item:
		queue_free()
		return
	current_state = State.GRAB
	closest_shelf = shelves_in_store[0]
	for shelf in shelves_in_store:
		if global_position.distance_squared_to(shelf.global_position) < global_position.distance_squared_to(closest_shelf.global_position):
			closest_shelf = shelf
	visuals.look_at(closest_shelf.global_position)
	if not closest_shelf.is_stocked:
		current_state = State.WAIT


func _on_game_over(_good_ending : bool) -> void:
	animation_player.play("die")


func _physics_process(delta: float) -> void:
	if not GameState.is_playing(): return
	match current_state:
		State.WALK:
			do_walk(delta)
		State.GRAB:
			animation_player.play("interact-right")
		State.DEAD:
			pass # could have something here
		State.WAIT:
			do_wait()


func _ready() -> void:
	EventBus.game_over.connect(_on_game_over)


func _init() -> void:
	visuals = skins.pick_random().instantiate()
	animation_player = visuals.get_child(1)
	visuals.get_child(0).rotate(Vector3.UP, PI)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	add_child(visuals)
