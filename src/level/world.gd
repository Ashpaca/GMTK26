extends Node3D

enum Tutorial{
	BEFORE,
	MOVEMENT,
	RUN,
	PICKUP,
	STOCK,
	CUSTOMER,
	CUSTOMER2,
	DONE,
	CUTSCENE,
	REALLY_DONE
}

const SHOPPER = preload("uid://bc26jrpphkke5")
const bomb_location_default : Vector3 = Vector3(-0.57, 0.594, 6.359)
const bomb_location_change : Vector3 = Vector3(-0.57, 2.366, 3.359)
const bomb_size_default : Vector3 = Vector3(1, 1, 1)
const bomb_size_change : Vector3 = Vector3(4, 4, 4)
const camera_position_default : Vector3 = Vector3(6, 5.4, 6)
const camera_rotation_default : Vector3 = Vector3(-30, 45, 0)
const camera_size_default : float = 5.0
const camera_position_moved : Vector3 = Vector3(-0.15, 0.328, 0.5)
const camera_rotation_moved : Vector3 = Vector3(0, 0, 0)
const camera_size_moved : float = 0.5

@onready var doors: Node3D = $Doors
@onready var shelves: Node3D = $Shelves
@onready var spawn_points: Node3D = $SpawnPoints
@onready var despawn_points: Node3D = $DespawnPoints
var the_doors : Array[WallDoor]
var the_shelves : Array[Shelf]
var the_spawns : Array[Node3D]
var the_despawns : Array[Node3D]

var tutorial_point : Tutorial = Tutorial.BEFORE
var has_done_up : bool
var has_done_down : bool
var has_done_left : bool
var has_done_right : bool
@onready var ui: CanvasLayer = $Ui
@onready var up: AnimatedSprite3D = $Player/TutorialPopups/Up
@onready var down: AnimatedSprite3D = $Player/TutorialPopups/Down
@onready var left: AnimatedSprite3D = $Player/TutorialPopups/Left
@onready var right: AnimatedSprite3D = $Player/TutorialPopups/Right
@onready var apple_indicators : Array[AnimatedSprite3D] = [$Supplies/Supply/AppleIndicator, $Supplies/Supply2/AppleIndicator, $Supplies/Supply3/AppleIndicator]
@onready var shelf_indicator: AnimatedSprite3D = $Shelves/Shelf4/ShelfIndicator
@onready var player: Player = $Player
@onready var player_visuals : Node3D = player.get_child(1)
@onready var camera: Camera3D = player.get_child(2)
var camera_tween : Tween
var last_shopper : Shopper
@onready var bomb_timer: Label3D = $SetDressing/BombTimer
var timer_change_display : int = 9
var bomb_tween : Tween

@onready var tick_sound: AudioStreamPlayer = $TickSound
@onready var pre_father_music: AudioStreamPlayer = $PreFatherMusic
@onready var post_father_music: AudioStreamPlayer = $PostFatherMusic
@onready var father_audio: AudioStreamPlayer = $FatherAudio
@onready var easter_egg_audio: AudioStreamPlayer = $EasterEggAudio

@onready var tutorial_voice: AudioStreamPlayer = $TutorialVoice
var tutorial_voice_index : int = 0
@onready var tutorials : Array[AudioStream] = [
	load("res://assets/sfx/voice_acting/Countdown_line_1mp3.wav"),
	load("res://assets/sfx/voice_acting/Countdown_line_2mp3.wav"),
	load("res://assets/sfx/voice_acting/Countdown_line_3mp3.wav"),
	load("res://assets/sfx/voice_acting/Countdown_line_4mp3.wav"),
	load("res://assets/sfx/voice_acting/Countdown_line_5mp3.wav"),
	load("res://assets/sfx/voice_acting/Countdown_line_6mp3.wav")
]

func _on_request_start_game() -> void:
	tutorial_point = Tutorial.MOVEMENT
	ui.visible = true
	GameState.current_state = GameState.State.WAIT
	tutorial_voice.stream = tutorials[tutorial_voice_index]
	tutorial_voice_index += 1
	tutorial_voice.play()
	ui.do_next_dialogue()
	pre_father_music.play()


func _do_easter_egg() -> void:
	easter_egg_audio.play()
	pre_father_music.stop()
	post_father_music.stop()


func _ready() -> void:
	EventBus.request_start_game.connect(_on_request_start_game)
	EventBus.spawn_shopper.connect(_on_spawn_shopper)
	EventBus.player_deleted.connect(_do_easter_egg)
	
	for door in doors.get_children():
		the_doors.append(door)
	for shelf in shelves.get_children():
		the_shelves.append(shelf)
	for point in spawn_points.get_children():
		the_spawns.append(point)
	for point in despawn_points.get_children():
		the_despawns.append(point)
	

func _on_spawn_shopper() -> void:
	var shopper_instance : Shopper = SHOPPER.instantiate()
	add_child(shopper_instance)
	shopper_instance.shelves_in_store = the_shelves
	shopper_instance.despawn_location = the_despawns.pick_random().global_position
	shopper_instance.global_position = the_spawns.pick_random().global_position
	last_shopper = shopper_instance
	


func _physics_process(_delta: float) -> void:
	if GameState.time_left < timer_change_display * 10:
		tick_sound.play()
		if bomb_tween:
			bomb_tween.kill()
		bomb_tween = create_tween()
		bomb_tween.set_parallel()
		bomb_tween.tween_property(bomb_timer, "position", bomb_location_change, 1.0)
		bomb_tween.tween_property(bomb_timer, "scale", bomb_size_change, 1.0)
		bomb_tween.tween_property(bomb_timer, "text", str(timer_change_display), 0.01).set_delay(1.0)
		bomb_tween.tween_property(bomb_timer, "position", bomb_location_default, 0.2).set_delay(1.0)
		bomb_tween.tween_property(bomb_timer, "scale", bomb_size_default, 0.2).set_delay(1.0)
		timer_change_display -= 1
		if timer_change_display < 0:
			var caller : Callable = Callable(EventBus, "emit_signal")
			caller = caller.bind("game_over", true)
			bomb_tween.tween_callback(caller.call).set_delay(1.0)
	if not GameState.is_playing(): return
	if GameState.tutorial_complete:
		return
	match tutorial_point:
		Tutorial.BEFORE:
			ui.visible = false
		Tutorial.MOVEMENT:
			ui.visible = false
			up.visible = true
			down.visible = true
			left.visible = true
			right.visible = true
			if Input.is_action_pressed("move_up"):
				up.play("complete")
			if Input.is_action_pressed("move_down"):
				down.play("complete")
			if Input.is_action_pressed("move_left"):
				left.play("complete")
			if Input.is_action_pressed("move_right"):
				right.play("complete")
			if up.animation == "complete" and down.animation == "complete" and left.animation == "complete" and right.animation == "complete":
				tutorial_point = Tutorial.RUN
				up.visible = false
				down.visible = false
				left.visible = false
				right.visible = false
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				tutorial_voice.stream = tutorials[tutorial_voice_index]
				tutorial_voice_index += 1
				tutorial_voice.play()
				ui.do_next_dialogue()
		Tutorial.RUN:
			ui.visible = false
			if Input.is_action_just_released("run"):
				tutorial_point = Tutorial.PICKUP
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				tutorial_voice.stream = tutorials[tutorial_voice_index]
				tutorial_voice_index += 1
				tutorial_voice.play()
				ui.do_next_dialogue()
		Tutorial.PICKUP:
			ui.visible = false
			for apple in apple_indicators:
				apple.visible = true
			if player.held_item:
				for apple in apple_indicators:
					apple.visible = false
				tutorial_point = Tutorial.STOCK
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				tutorial_voice.stream = tutorials[tutorial_voice_index]
				tutorial_voice_index += 1
				tutorial_voice.play()
				ui.do_next_dialogue()
		Tutorial.STOCK:
			ui.visible = false
			shelf_indicator.visible = true
			if not player.held_item:
				shelf_indicator.visible = false
				tutorial_point = Tutorial.CUSTOMER
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				tutorial_voice.stream = tutorials[tutorial_voice_index]
				tutorial_voice_index += 1
				tutorial_voice.play()
				ui.do_next_dialogue()
		Tutorial.CUSTOMER:
			ui.visible = false
			for door in the_doors:
				door.open()
			_on_spawn_shopper()
			tutorial_point = Tutorial.CUSTOMER2
		Tutorial.CUSTOMER2:
			tutorial_voice.stream = tutorials[tutorial_voice_index]
			tutorial_voice_index += 1
			tutorial_voice.play()
			ui.do_next_dialogue()
			ui.visible = true
			GameState.current_state = GameState.State.WAIT
			tutorial_point = Tutorial.DONE
		Tutorial.DONE:
			ui.visible = false
			if not last_shopper:
				for door in the_doors:
					door.close()
				player_visuals.look_at(Vector3(0, 0, 100))
				if camera_tween:
					camera_tween.kill()
				camera_tween = create_tween()
				camera_tween.set_parallel()
				camera_tween.tween_property(camera, "position", camera_position_moved, 1.0)
				camera_tween.tween_property(camera, "rotation_degrees", camera_rotation_moved, 1.5)
				camera_tween.tween_property(camera, "size", camera_size_moved, 1.0)
				tutorial_point = Tutorial.CUTSCENE
				ui.visible = true
				GameState.current_state = GameState.State.WAIT
				ui.do_next_dialogue()
				ui.phone.visible = true
				pre_father_music.stop()
				father_audio.play()
		Tutorial.CUTSCENE:
			father_audio.stop()
			ui.visible = false
			bomb_timer.visible = true
			for door in the_doors:
					door.open()
			if camera_tween:
				camera_tween.kill()
			camera_tween = create_tween()
			camera_tween.set_parallel()
			camera_tween.tween_property(camera, "position", camera_position_default, 1.0)
			camera_tween.tween_property(camera, "rotation_degrees", camera_rotation_default, 1.5)
			camera_tween.tween_property(camera, "size", camera_size_default, 1.0)
			tutorial_point = Tutorial.REALLY_DONE
			GameState.tutorial_complete = true
			post_father_music.play(45.0)
		Tutorial.REALLY_DONE:
			pass


func _on_kill_zone_body_entered(body: Node3D) -> void:
	body.queue_free()
