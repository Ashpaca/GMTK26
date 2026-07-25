extends Node

enum State{
	MENU,
	PLAY,
	PAUSE,
	END
}

var current_state : State = State.MENU
var time_left : float = 60.0
var spawn_shopper_at : float = 60.0
var spawn_shopper_speed : float = 1.0
var spawn_shopper_acceleration : float = 0.01
var tutorial_complete : bool = true

func is_playing() -> bool:
	return current_state == State.PLAY

func _ready() -> void:
	EventBus.request_start_game.connect(_on_request_start_game)
	EventBus.request_quit_game.connect(_on_request_quit_game)

func _process(delta: float) -> void:
	if not is_playing():
		return
	if tutorial_complete:
		time_left -= delta
		if time_left <= spawn_shopper_at:
			EventBus.spawn_shopper.emit()
			spawn_shopper_at -= spawn_shopper_speed
			spawn_shopper_speed -= spawn_shopper_acceleration
		

func _on_request_start_game() -> void:
	current_state = State.PLAY

func _on_request_quit_game() -> void:
	current_state = State.END
	get_tree().quit()
