extends CharacterBody3D

const SPEED = 1
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


func _physics_process(delta: float) -> void:
	navigation_agent_3d.target_position = Vector3(-5.3, 0, 3.3)
	velocity = (navigation_agent_3d.get_next_path_position() - global_position) * SPEED
	move_and_slide()
