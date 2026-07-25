extends Node

@export var scroll_speed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material.set_shader_parameter("scroll_speed", scroll_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
