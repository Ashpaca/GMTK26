extends CharacterBody3D

enum State{
	WALK,
	GRAB,
	WAIT,
	DEAD,
	GET_UP
}

const SPEED : float = 1
const DEATH_OFFSET : Vector3 = Vector3(0, 0, .35)
@export var shelves_in_store : Array[Shelf]
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var get_up_timer: Timer = $GetUpTimer
var current_state : State = State.WAIT
var has_item : bool



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
		
		var goal_rotation : float = -visuals.basis.x.angle_to(velocity)
		visuals.rotation.y = rotate_toward(visuals.rotation.y, goal_rotation, delta*10)
		#visuals.look_at(global_position - velocity)
	move_and_slide()


func do_wait() -> void:
	var nav_map : RID = get_world_3d().navigation_map
	if NavigationServer3D.map_get_iteration_id(nav_map) < 2:
		return
	print(shelves_in_store.pick_random())
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
			animation_player.play("die")
			visuals.position = DEATH_OFFSET.rotated(Vector3.UP, visuals.rotation.y)
			current_state = State.DEAD
			get_up_timer.start()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die" and current_state == State.GET_UP:
		current_state = State.WALK


func _on_get_up_timer_timeout() -> void:
	animation_player.play_backwards("die")
	current_state = State.GET_UP


func _physics_process(delta: float) -> void:
	match current_state:
		State.WALK:
			do_walk(delta)
		State.DEAD:
			pass # could have something here
		State.WAIT:
			do_wait()
