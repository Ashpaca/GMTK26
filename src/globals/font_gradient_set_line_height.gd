extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("line_height", get_theme_font_size("normal_font_size") + 2.0)
