class_name CustomButtonComponent
extends Button

## Custom button class that all normal buttons should be replaced by. Makes the focus mode and 
## hover mode equivilant i.e. If the mouse is hovering over a button, that should be the same as 
## the controller having the focus on a button.

## Further functionality can be added.

func _on_mouse_entered() -> void:
	grab_focus()


func _physics_process(_delta: float) -> void:
	# Not quite working as I want in all cases
	# Essentially what I want: hide over effect if something else has the focus
	if not has_focus():
		add_theme_color_override("font_hover_color", get_theme_color("font_color"))
	else:
		add_theme_color_override("font_hover_color", get_theme_color("font_focus_color"))


func _on_focus() -> void:
	EventBus.play_switch.emit()


func _ready() -> void:
	focus_entered.connect(_on_focus)
	mouse_entered.connect(_on_mouse_entered)
	add_theme_stylebox_override("focus", get_theme_stylebox("hover"))
	add_theme_stylebox_override("hover", get_theme_stylebox("normal"))
