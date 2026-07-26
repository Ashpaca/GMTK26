extends CanvasLayer

@onready var phone: AnimatedSprite2D = $Phone
@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichTextLabel = $TextureRect/RichTextLabel
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var textbox_component: TextboxComponent = $NinePatchRect/TextboxComponent
@onready var label: RichTextLabel = $Label
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var dialogue_index : int = -1
var dialogues_in_order : Array[String] = [
	"Testing, Testing \nPress 'X' to proceed\nEveryones favourite grocery store, COUNTDOWN, is about to open for a completely normal day... \nUse your arrow keys to move around.",
	"Please be careful to not run into each other by pressing 'Z'",
	"Any workers in the store please make your way to an apple supply and pick up a box by pressing 'X'.",
	"And place it on the nearest shelf with 'x'.\nOr just put it back where you found it, I don't care...\nBut our loyal customers sure do!",
	"Even though this is a prerecorded message you have heard every day that you have worked here, and I have no way of knowing what is currently happening, I'm sure the first customer of the day is just arriving. Give them some space to do their shopping!\n\nNo seriously, let's not run into them like Gerald would always do. I mean he's gone now and all, but I still had to record this message because of what happend.",
	"Courtney! It's me, your father. You don't have much time, there is a bomb in that COUNTDOWN. The explosion will be big enough that there is no hope of escape. You might as well provide the best customer survice you can for your last few customers. Run! Run, to the shelves to stock them, people will get out of your way when you run. And you know what? Maybe sometimes they'll be pushed over by you, but it'll be worth it to get their products in stock. But I'm sorry to say, this may be the end of COUNTDOWN as we know it. Darn those Australians..."
]
var game_over_tween : Tween
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound


func do_next_dialogue() -> void:
	dialogue_index += 1
	textbox_component.set_message(dialogues_in_order[dialogue_index])


func _on_game_over(_good_ending : bool) -> void:
	if game_over_tween:
		game_over_tween.kill()
	game_over_tween = create_tween()
	game_over_tween.set_parallel()
	game_over_tween.tween_property(nine_patch_rect, "visible", false, 0).set_delay(1)
	game_over_tween.tween_property(label, "visible", false, 0).set_delay(1)
	game_over_tween.tween_property(phone, "visible", false, 0).set_delay(1)
	game_over_tween.tween_callback(explosion_sound.play).set_delay(1)
	game_over_tween.tween_property(self, "visible", true, 0).set_delay(2)
	game_over_tween.tween_property(texture_rect, "visible", true, 0).set_delay(2)
	game_over_tween.tween_property(rich_text_label, "text", "You were able to give the gift of apples to [shake]" + str(GameState.score) + "[/shake] people before you all died", 0).set_delay(2)
	game_over_tween.tween_property(rich_text_label, "text", "In loving memory of COUNTDOWN, the New Zealand grocery store.", 1).set_delay(5)
	
	nine_patch_rect.visible = false
	label.visible = false
	phone.visible = false
	visible = true
	texture_rect.visible = true
	rich_text_label.text = "You were able to give the gift of apples to [shake]" + str(GameState.score) + "[/shake] people before you all died"


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.State.WAIT:
		return
	if textbox_component.message_pages.size() - textbox_component.page_num > 9:
		label.text = str(textbox_component.message_pages.size() - textbox_component.page_num)
	else:
		label.text = "  " + str(textbox_component.message_pages.size() - textbox_component.page_num)
	if Input.is_action_just_pressed("interact"):
		if not textbox_component.is_fully_displayed():
			textbox_component.display_all_text()
		elif not textbox_component.get_next_page():
			audio_stream_player.play()
			GameState.current_state = GameState.State.PLAY
		else:
			audio_stream_player.play()


func _ready() -> void:
	EventBus.game_over.connect(_on_game_over)
