extends Node

enum State{
	MENU,
	PLAY,
	PAUSE,
	END
}

var current_state : State = State.MENU
var time_left : float = 60.0

func is_playing() -> bool:
	return current_state == State.PLAY

func _ready() -> void:
	EventBus.request_start_game.connect(_on_request_start_game)
	EventBus.request_quit_game.connect(_on_request_quit_game)

func _process(delta: float) -> void:
	if is_playing():
		time_left -= delta
		

func _on_request_start_game() -> void:
	current_state = State.PLAY

func _on_request_quit_game() -> void:
	current_state = State.END
	get_tree().quit()
