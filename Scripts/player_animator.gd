extends Node2D

@export var player_controller : PlayerController
@export var animation_player : AnimationPlayer
@export var Sprite : Sprite2D

func _process(_delta):
	# 1. --- SPRITE FLIP (Separate and independent) ---
	# This should always run at the start of _process
	if player_controller.direction == 1:
		Sprite.flip_h = false
	elif player_controller.direction == -1:
		Sprite.flip_h = true

	# 2. --- AIRBORNE VS. GROUNDED LOGIC ---
	
	# Check if the player is NOT on the floor (i.e., airborne)
	# ASSUMPTION: PlayerController is a CharacterBody2D or exposes this function.
	if not player_controller.is_on_floor(): 
		
		# Character is moving UP (Jumping) - velocity.y is negative
		if player_controller.velocity.y < 0.0:
			if animation_player.current_animation != "Jump":
				animation_player.play("Jump")
		
		# Character is moving DOWN (Falling) - velocity.y is positive
		elif player_controller.velocity.y > 0.0:
			# Play the static fall animation
			if animation_player.current_animation != "Fall Still":
				animation_player.play("Fall Still")
	
	# Player IS on the ground (is_on_floor() is true)
	else:
		# --- HORIZONTAL (GROUND) ANIMATIONS ---
		if abs(player_controller.velocity.x) > 0.0:
			# Character is walking
			if animation_player.current_animation != "Walk":
				animation_player.play("Walk") 
		else:
			# Character is idle
			if animation_player.current_animation != "Idle":
				animation_player.play("Idle")
