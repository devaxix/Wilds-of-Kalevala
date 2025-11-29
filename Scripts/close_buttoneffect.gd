extends TextureButton

# --- SETTINGS ---
@export var hover_scale := Vector2(1.1, 1.1)
@export var click_scale := Vector2(0.95, 0.95)
@export var tween_speed := 0.1

# --- AUDIO SETTINGS ---
@export_group("Audio")
@export var hover_sound : AudioStream
@export_range(-80, 24) var hover_volume_db := -10.0 # Individual Volume!

@export var click_sound : AudioStream
@export_range(-80, 24) var click_volume_db := 0.0   # Louder default for clicks!

# --- INTERNAL VARIABLES ---
var original_y = 0
var default_scale := Vector2(1, 1)
var tween : Tween
var audio_player : AudioStreamPlayer

func _ready():
	original_y = position.y
	default_scale = scale
	pivot_offset = size / 2
	
	# Create the player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Connect signals
	button_down.connect(_on_pressed)
	button_up.connect(_on_released)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	animate_scale(hover_scale)
	play_sound(hover_sound, hover_volume_db)

func _on_exit():
	animate_scale(default_scale)

func _on_pressed():
	position.y = original_y + 4
	animate_scale(click_scale)
	play_sound(click_sound, click_volume_db)

func _on_released():
	position.y = original_y
	if is_hovered():
		animate_scale(hover_scale)
	else:
		animate_scale(default_scale)

func animate_scale(target_val):
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_val, tween_speed)

# Update helper to accept volume!
func play_sound(stream, volume):
	if stream:
		audio_player.stream = stream
		audio_player.volume_db = volume # Set volume before playing
		audio_player.pitch_scale = randf_range(0.95, 1.05)
		audio_player.play()
