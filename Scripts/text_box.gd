extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer
@onready var letter_sound = $LetterSound 

# --- VISUALS ---
@onready var standard_bg = $StandardBackground
@onready var fox_bg = $FoxBackground

# FIXED PATH: Matches your Scene Tree
@onready var next_indicator = $IndicatorPosition/NextIndicator

var text = ""
var letter_index = 0
var base_pitch: float = 1.0

# ANIMATION VARIABLES
var indicator_tween: Tween 
var indicator_start_y: float = 0.0 

signal finished_displaying()

func _ready():
	scale = Vector2.ZERO
	
	# Save the initial Y position so the arrow doesn't drift away
	if next_indicator:
		indicator_start_y = next_indicator.position.y
		next_indicator.visible = false

func set_fox_mode(active: bool):
	if active:
		if standard_bg: standard_bg.visible = false
		if fox_bg: fox_bg.visible = true
		base_pitch = 1.5 
	else:
		if standard_bg: standard_bg.visible = true
		if fox_bg: fox_bg.visible = false
		base_pitch = 1.0 

func display_text(text_to_display: String):
	text = text_to_display
	label.text = "" 
	letter_index = 0
	pivot_offset = size / 2 
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)
	
	# Hide indicator & reset position while typing
	if next_indicator: 
		next_indicator.visible = false
		if indicator_tween: indicator_tween.kill() 
		next_indicator.position.y = indicator_start_y
	
	display_letter()

func display_letter():
	label.text += text[letter_index]
	letter_index += 1
	
	if letter_index >= text.length():
		finish_displaying_logic()
		return
	
	if text[letter_index - 1] != " ":
		letter_sound.pitch_scale = randf_range(base_pitch - 0.1, base_pitch + 0.1)
		letter_sound.play()
	
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
	if next_indicator: 
		next_indicator.visible = true
		_animate_arrow() # START BOUNCING!
	finished_displaying.emit()

# --- BOUNCING ANIMATION ---
func _animate_arrow():
	if indicator_tween: indicator_tween.kill()
	
	indicator_tween = create_tween().set_loops()
	
	# Move DOWN 5 pixels from ORIGINAL start, then back UP
	indicator_tween.tween_property(next_indicator, "position:y", indicator_start_y + 5, 0.5).set_trans(Tween.TRANS_SINE)
	indicator_tween.tween_property(next_indicator, "position:y", indicator_start_y, 0.5).set_trans(Tween.TRANS_SINE)

func close():
	if indicator_tween: indicator_tween.kill()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
