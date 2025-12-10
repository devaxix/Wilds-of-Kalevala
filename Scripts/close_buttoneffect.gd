extends TextureButton

# --- SETTINGS ---
@export var hover_scale := Vector2(1.1, 1.1)
@export var click_scale := Vector2(0.95, 0.95)
@export var tween_speed := 0.1

# --- AUDIO SETTINGS ---
@export_group("Audio")
@export var hover_sound : AudioStream
@export_range(-80, 24) var hover_volume_db := -10.0
@export var click_sound : AudioStream
@export_range(-80, 24) var click_volume_db := 0.0

# --- INTERNAL VARIABLES ---
var original_y = 0
var default_scale := Vector2(1, 1)
var tween : Tween
var audio_player : AudioStreamPlayer

func _ready():
	original_y = position.y
	default_scale = scale
	pivot_offset = size / 2
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	button_down.connect(_on_pressed)
	button_up.connect(_on_released)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	animate_scale(hover_scale)
	# Default behavior: Pitch variation is ON (true)
	play_sound(hover_sound, hover_volume_db)

func _on_exit():
	animate_scale(default_scale)

func _on_pressed():
	position.y = original_y + 4
	animate_scale(click_scale)
	# CHANGED: Added 'false' to disable pitch variation for clicks
	play_sound(click_sound, click_volume_db, false)

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

# CHANGED: Added 'vary_pitch = true' as an optional argument
func play_sound(stream, volume, vary_pitch: bool = true):
	if stream:
		audio_player.stream = stream
		audio_player.volume_db = volume
		
		# Only randomize if requested
		if vary_pitch:
			audio_player.pitch_scale = randf_range(0.95, 1.05)
		else:
			audio_player.pitch_scale = 1.0 # Strict normal pitch
			
		audio_player.play()
