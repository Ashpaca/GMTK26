extends Node

enum State{
	MENU,
	PLAY,
	PAUSE,
	END
}

var current_state : State = State.PLAY # will be menu later
var time_left : float = 60.0
var spawn_shopper_at : float = 60.0
var spawn_shopper_speed : float = 1.0
var spawn_shopper_acceleration : float = 0.01

func is_playing() -> bool:
	return current_state == State.PLAY


func _process(delta: float) -> void:
	if is_playing():
		time_left -= delta
		if time_left <= spawn_shopper_at:
			EventBus.spawn_shopper.emit()
			spawn_shopper_at -= spawn_shopper_speed
			spawn_shopper_speed -= spawn_shopper_acceleration
		
