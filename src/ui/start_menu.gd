extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.current_state != GameState.State.MENU:
		visible = false


func _on_start_button_pressed() -> void:
	EventBus.request_start_game.emit()


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	EventBus.request_quit_game.emit()
