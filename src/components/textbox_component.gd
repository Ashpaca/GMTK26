class_name TextboxComponent
extends RichTextLabel

## Displays text within a set bounding box, splitting it up into readable chunks. Simply give it a 
## string, and it will work out where it needs to be split up line by line, and then box by box. 
## Displays characters one by one and can handle BBCode.
##
## Hopefully you never have to look through the code that makes this magic work. It is kind of a 
## headache.

## Number of lines of text to display. This could be made variable if we end up using this 
## component in different places that have differing requirements.
const LINES_PER_PAGE: int = 2
## How much time should there be between one character and the next when dispalying text. Could be 
## made variable if we want to make it a setting.
const TIME_PER_CHAR: float = 0.02
## Input string that will be displayed in the textbox. This string may have BBCode within it.
var current_message: String
## A list that maps visible character indices to their corrisponding indices in 
## [member current_message]. Put in the visible character index and get back the location in the 
## original input string.
var visible_to_message_mapping: Array[int]
## Index of the current page being displayed.
var page_num: int
## List containing the message split up into pages that fit in the textbox.
var message_pages: Array[String]
## Timer variable that counts up to display more of the current page of text.
var character_display_timer: float


## Updates the text field to be the current page of the current message.
func update_display() -> void:
	text = message_pages[page_num]
	character_display_timer = 0.0


## Creates an array where the printeable character indexes corrispond to their total character 
## indexes allowing for BBCode.
func set_message_char_array() -> void:
	var non_printing: bool
	visible_to_message_mapping.clear()
	for i in range(current_message.length()):
		if non_printing:
			if current_message[i] == "]":
				non_printing = false
		elif current_message[i] == "[":
			non_printing = true
		else:
			visible_to_message_mapping.append(i)


## Takes the current message and splits it into seperate messages based on how many lines of text 
## fit in the textbox. To do this it does replace the displayed text, and so update_display should 
## be called after to have a valid textbox layout.
func split_message_to_pages() -> void:
	message_pages.clear()
	text = current_message
	var num_characters: int = get_total_character_count()
	var previous_page_ending_index: int = 0
	var current_line: int = 0
	for i in range(num_characters):
		if get_character_line(i) > current_line:
			current_line += 1
			if current_line % LINES_PER_PAGE == 0 and current_line != 0:
				message_pages.append(
					current_message.substr(
						previous_page_ending_index,
						visible_to_message_mapping[i - 1] + 1 - previous_page_ending_index
					)
				)
				previous_page_ending_index = visible_to_message_mapping[i - 1] + 1
	message_pages.append(current_message.substr(previous_page_ending_index))


## updates the message displayed by this textbox. Automatically splits longer dialogues into
## seperate pages.
## [br][param new_message]: the message as one long string.
func set_message(new_message: String) -> void:
	current_message = new_message
	page_num = 0
	set_message_char_array()
	split_message_to_pages()
	update_display()


## If the current message doesn't fit all at once, this will display the next page, and return true.
## If there is no next page, this will return false and not change the message.
func get_next_page() -> bool:
	if page_num >= message_pages.size() - 1:
		text = ""
		return false
	page_num += 1
	update_display()
	return true


## Makes all text in the current page display. That is, skips the character by character display.
func display_all_text() -> void:
	character_display_timer = TIME_PER_CHAR * get_total_character_count()


## Returns whether all the text in the current page has been displayed, as they are shown one at a 
## time.
func is_fully_displayed() -> bool:
	return visible_characters >= get_total_character_count()


func _process(delta: float) -> void:
	if text == "":
		return
	character_display_timer += delta
	# visible_characters is a built in variable for RichTextLabels that determines how many characters are displayed
	visible_characters = int(character_display_timer / TIME_PER_CHAR)


func _ready() -> void:
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING 
