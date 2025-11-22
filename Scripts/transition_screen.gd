extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

var scene_to_load_path = ""

func _ready():
	# 1. SETUP FOR GAME LAUNCH
	color_rect.visible = true
	color_rect.modulate.a = 1.0
	
	# Ensure speed is Normal (1.0) for the 5-second startup
	animation_player.speed_scale = 1.0 
	
	animation_player.play("fade_to_normal")

func transition_to_scene(path: String):
	scene_to_load_path = path
	color_rect.visible = true
	
	# SPEED UP for normal scene changes!
	# 5.0 makes a 5-second animation take 1 second.
	animation_player.speed_scale = 5.0 
	
	animation_player.play("fade_to_black")

func _on_animation_finished(anim_name):
	print("Finished animation: ", anim_name)
	
	if anim_name == "fade_to_black":
		print("Changing scene...")
		get_tree().change_scene_to_file(scene_to_load_path)
		
		# Ensure the fade-in matches the fast speed
		animation_player.speed_scale = 5.0 
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
