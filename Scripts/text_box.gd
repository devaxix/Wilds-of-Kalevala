extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer
@onready var letter_sound = $LetterSound 

# --- NEW NODES ---
@onready var standard_bg = $StandardBackground
@onready var fox_bg = $FoxBackground
@onready var next_indicator = $StandardBackground/IndicatorPosition/NextIndicator # Adjust path if needed!

var text = ""
var letter_index = 0
var base_pitch: float = 1.0

signal finished_displaying()

func _ready():
	# We rely on the Editor's position, but we still animate the scale
	scale = Vector2.ZERO

# --- NEW: TOGGLE FUNCTION ---
func set_fox_mode(active: bool):
	if active:
		standard_bg.visible = false
		fox_bg.visible = true
		base_pitch = 1.5 # High pitch for Fox
	else:
		standard_bg.visible = true
		fox_bg.visible = false
		base_pitch = 1.0 # Normal pitch

func display_text(text_to_display: String):
	text = text_to_display
	label.text = "" 
	letter_index = 0
	
	# Reset pivot to center for the pop-up animation
	pivot_offset = size / 2 
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)
	
	if next_indicator: next_indicator.visible = false 
	
	display_letter()

func display_letter():
	label.text += text[letter_index]
	letter_index += 1
	
	if letter_index >= text.length():
		finish_displaying_logic()
		return
	
	# SOUND LOGIC
	if text[letter_index - 1] != " ":
		# Randomize around the base pitch
		letter_sound.pitch_scale = randf_range(base_pitch - 0.1, base_pitch + 0.1)
		letter_sound.play()
	
	# TIMING LOGIC
	match text[letter_index]:
		"!", ".", "?": timer.start(0.6)
		",": timer.start(0.2)
		" ": timer.start(0.06)
		_: timer.start(0.04)

func _on_letter_display_timer_timeout():
	display_letter()

func skip_typing():
	timer.stop()
	label.text = text
	finish_displaying_logic()

func finish_displaying_logic():
	if next_indicator: next_indicator.visible = true 
	finished_displaying.emit()

func close():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
