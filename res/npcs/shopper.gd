extends CharacterBody3D

const SPEED = 1
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $"character-female-f2/AnimationPlayer"

var is_dead : bool


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	if is_dead:
		return
	navigation_agent_3d.target_position = Vector3(-5.3, 0, 3.3)
	var next_point : Vector3 = (navigation_agent_3d.get_next_path_position() - global_position) * SPEED
	navigation_agent_3d.velocity = next_point
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = Vector3(safe_velocity.x, 0, safe_velocity.z).normalized() * SPEED


func _on_player_detector_body_entered(body: Node3D) -> void:
	if is_dead:
		return
	if body is Player:
		var player : Player = body
		if player.is_running():
			animation_player.play("die")
			is_dead = true
