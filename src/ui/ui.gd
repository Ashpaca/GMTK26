extends CanvasLayer

@onready var textbox_component: TextboxComponent = $NinePatchRect/TextboxComponent
var dialogue_index : int = -1
var dialogues_in_order : Array[String] = [
	"Testing, Testing \nPress 'X' to proceed\nEveryones favourite grocery store, COUNTDOWN, is about to open for a completely normal day... \nUse your arrow keys to move around.",
	"Please be careful to not run into each other by pressing 'Z'",
	"Any workers in the store please make your way to an apple supply and pick up a box by pressing 'X'.",
	"And place it on the nearest shelf with 'x'.\nOr just put it back where you found it, I don't care...\nBut our loyal customers sure do!"
]

func do_next_dialogue() -> void:
	dialogue_index += 1
	textbox_component.set_message(dialogues_in_order[dialogue_index])


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.State.WAIT:
		return
	if Input.is_action_just_pressed("interact"):
		if not textbox_component.is_fully_displayed():
			textbox_component.display_all_text()
		elif not textbox_component.get_next_page():
			GameState.current_state = GameState.State.PLAY
