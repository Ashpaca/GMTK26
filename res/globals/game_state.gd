extends Node

enum State{
	MENU,
	PLAY,
	PAUSE,
	END
}

var current_state : State = State.PLAY # will be menu later
var time_left : float = 60.0

func is_playing() -> bool:
	return current_state == State.PLAY


func _process(delta: float) -> void:
	if is_playing():
		time_left -= delta
		
