extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

var scene_to_load_path = ""

# The actual length of your animation in the editor (in seconds)
const BASE_ANIM_LENGTH = 5.0 

func _ready():
	# 1. SETUP FOR GAME LAUNCH
	color_rect.visible = true
	color_rect.modulate.a = 1.0
	
	# Startup is slow (Normal 1.0 speed = 5 seconds)
	animation_player.speed_scale = 1.0 
	animation_player.play("fade_to_normal")

# UPDATED: Added 'duration' parameter. default is 1.0 second (Fast).
func transition_to_scene(path: String, duration: float = 1.0):
	scene_to_load_path = path
	color_rect.visible = true
	
	# --- THE MATH ---
	# If animation is 5s and we want it done in 1s: 5 / 1 = 5.0 (Speed Scale)
	# If animation is 5s and we want it done in 5s: 5 / 5 = 1.0 (Speed Scale)
	var new_speed = BASE_ANIM_LENGTH / duration
	
	animation_player.speed_scale = new_speed
	
	animation_player.play("fade_to_black")

func _on_animation_finished(anim_name):
	print("Finished animation: ", anim_name)
	
	if anim_name == "fade_to_black":
		print("Changing scene...")
		get_tree().change_scene_to_file(scene_to_load_path)
		
		# NOTE: We do NOT reset speed_scale here. 
		# We keep the same speed so the Fade IN takes the same time as the Fade OUT.
		animation_player.play("fade_to_normal")
		
	elif anim_name == "fade_to_normal":
		print("Hiding transition screen")
		color_rect.visible = false

# Connect the signal safely
func _enter_tree():
	if not animation_player:
		await ready
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
