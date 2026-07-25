class_name WallDoor
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func open() -> void:
	animation_player.play("open")


func close() -> void:
	animation_player.play("close")
