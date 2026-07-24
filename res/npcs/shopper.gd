extends CharacterBody3D

const SPEED = 1
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	navigation_agent_3d.target_position = Vector3(-5.3, 0, 3.3)
	var next_point : Vector3 = (navigation_agent_3d.get_next_path_position() - global_position) * SPEED
	navigation_agent_3d.velocity = next_point
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity.normalized() * SPEED
