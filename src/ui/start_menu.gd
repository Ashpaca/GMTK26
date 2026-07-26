extends Control

@onready var start_button: Button = $MetaMarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/MenuOptions/StartLabel/StartLabelShadow/StartButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var select_player: AudioStreamPlayer = $select_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.grab_focus()
	EventBus.play_switch.connect(_on_switch)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameState.current_state != GameState.State.MENU:
		visible = false


func _on_start_button_pressed() -> void:
	select_player.play()
	EventBus.request_start_game.emit()


func _on_options_button_pressed() -> void:
	select_player.play()


func _on_quit_button_pressed() -> void:
	select_player.play()
	EventBus.request_quit_game.emit()


func _on_switch() -> void:
	audio_stream_player.play()
