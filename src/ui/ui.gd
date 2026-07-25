extends CanvasLayer

@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichTextLabel = $TextureRect/RichTextLabel
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var textbox_component: TextboxComponent = $NinePatchRect/TextboxComponent
@onready var label: RichTextLabel = $Label
var dialogue_index : int = -1
var dialogues_in_order : Array[String] = [
	"Testing, Testing \nPress 'X' to proceed\nEveryones favourite grocery store, COUNTDOWN, is about to open for a completely normal day... \nUse your arrow keys to move around.",
	"Please be careful to not run into each other by pressing 'Z'",
	"Any workers in the store please make your way to an apple supply and pick up a box by pressing 'X'.",
	"And place it on the nearest shelf with 'x'.\nOr just put it back where you found it, I don't care...\nBut our loyal customers sure do!",
	"Even though this is a prerecorded message you have heard every day that you have worked here, and I have no way of knowing what is currently happening, I'm sure the first customer of the day is just arriving. Give them some space to do their shopping!\n\nNo seriously, let's not run into them like Gerald would always do. I mean he's gone now and all, but I still had to record this message because of what happend."
]

func do_next_dialogue() -> void:
	dialogue_index += 1
	textbox_component.set_message(dialogues_in_order[dialogue_index])


func _on_game_over(_good_ending : bool) -> void:
	nine_patch_rect.visible = false
	label.visible = false
	visible = true
	texture_rect.visible = true
	rich_text_label.text = "You were able to give the gift of apples to [shake]" + str(GameState.score) + "[/shake] people before you all died"


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.State.WAIT:
		return
	label.text = str(textbox_component.message_pages.size() - textbox_component.page_num)
	if Input.is_action_just_pressed("interact"):
		if not textbox_component.is_fully_displayed():
			textbox_component.display_all_text()
		elif not textbox_component.get_next_page():
			GameState.current_state = GameState.State.PLAY


func _ready() -> void:
	EventBus.game_over.connect(_on_game_over)
