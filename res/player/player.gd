extends CharacterBody3D


const SPEED = 5.0
const HELD_SPEED = 3.5
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var interaction_zone: Area3D = $Visuals/InteractionZone
var is_stocking : bool
var is_picking_up : bool
var is_dropping : bool
var held_item : bool # need to replace with an item
var shelf_to_stock : Shelf

func handle_interaction() -> void:
	for body in interaction_zone.get_overlapping_bodies():
			if body is Shelf:
				var shelf : Shelf = body
				if not shelf.is_stocked and held_item:
					shelf_to_stock = shelf
					is_stocking = true
					animation_player.play("interact-right")
					return
			if body is Supply:
				if not held_item:
					is_picking_up = true
					animation_player.play("pick-up")
				else:
					is_dropping = true
					animation_player.play_backwards("pick-up")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "interact-right" and is_stocking:
		shelf_to_stock.stock_shelf()
		is_stocking = false
		held_item = false
	if anim_name == "pick-up":
		if is_picking_up:
			is_picking_up = false
			held_item = true
		elif is_dropping:
			is_dropping = false
			held_item = false


func _physics_process(delta: float) -> void:
	if is_stocking or is_picking_up or is_dropping: return
	
	if Input.is_action_just_pressed("interact"):
		handle_interaction()
	if is_stocking or is_picking_up or is_dropping: return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, PI/4)
	if direction:
		visuals.look_at(global_position - direction)
		if held_item:
			velocity.x = direction.x * HELD_SPEED
			velocity.z = direction.z * HELD_SPEED
			animation_player.play("walk_holding_character-employee")
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
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
