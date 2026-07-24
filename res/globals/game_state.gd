extends Node

enum State{
	MENU,
	PLAY,
	PAUSE,
	END
}

var current_state : State = State.PLAY # will be menu later
var time_left : float = 60.0
var time_test : float = 50.0

func is_playing() -> bool:
	return current_state == State.PLAY


func _process(delta: float) -> void:
	if is_playing():
		time_left -= delta
		if time_left < time_test:
			time_test -= 10.0
			EventBus.test_signal.emit()
		
