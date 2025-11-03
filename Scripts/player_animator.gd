extends Node2D

@export var player_controller : PlayerController
@export var animation_player : AnimationPlayer
@export var Sprite : Sprite2D

func _process(_delta):
	if player_controller.direction == 1:
		Sprite.flip_h = false
	elif player_controller.direction == -1:
		Sprite.flip_h = true
