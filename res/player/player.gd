extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var interaction_zone: Area3D = $Visuals/InteractionZone


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		for body in interaction_zone.get_overlapping_bodies():
			if body is Shelf:
				var shelf : Shelf = body
				if not shelf.is_stocked:
					shelf.stock_shelf()
					break
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, PI/4)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		visuals.look_at(global_position - direction)
		animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animation_player.play("idle")

	move_and_slide()
