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
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var visuals: Node3D = $Visuals
var current_state : State = State.WALK
var has_item : bool
@onready var get_up_timer: Timer = $GetUpTimer


func do_walk(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	navigation_agent_3d.target_position = Vector3(-5.3, 0, 3.3) # needs to be set 
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
