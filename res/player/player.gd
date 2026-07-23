extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var interaction_zone: Area3D = $Visuals/InteractionZone
var is_stocking : bool
var shelf_to_stock : Shelf

func handle_interaction() -> void:
	for body in interaction_zone.get_overlapping_bodies():
			if body is Shelf:
				var shelf : Shelf = body
				if not shelf.is_stocked:
					shelf_to_stock = shelf
					is_stocking = true
					animation_player.play("interact-right")
					return


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "interact-right" and is_stocking:
		shelf_to_stock.stock_shelf()
		is_stocking = false


func _physics_process(delta: float) -> void:
	if is_stocking: return
	
	if Input.is_action_just_pressed("interact"):
		handle_interaction()
	if is_stocking: return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
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
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
