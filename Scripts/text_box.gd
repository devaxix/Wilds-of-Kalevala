extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer
@onready var letter_sound = $LetterSound 
@onready var next_indicator = $NinePatchRect/IndicatorPosition/NextIndicator

const MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying()

func _ready():
	# 1. Start invisible/tiny for the pop-up
	scale = Vector2.ZERO

func display_text(text_to_display: String):
	text = text_to_display
	label.text = "" # Start empty!
	letter_index = 0
	
	# 2. POP-UP ANIMATION
	# Set pivot to center so it grows from the middle
	pivot_offset = size / 2 
	
	var tween = create_tween()
	# "Back" transition makes it overshoot/bounce slightly
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)
	
	# 3. Reset Indicator
	next_indicator.visible = false 
	
	display_letter()

func display_letter():
	# Add one letter to the label
	label.text += text[letter_index]
	
	letter_index += 1
	
	# CHECK IF DONE
	if letter_index >= text.length():
		finish_displaying_logic()
		return
	
	# SOUND LOGIC
	if text[letter_index - 1] != " ":
		letter_sound.pitch_scale = randf_range(0.9, 1.1)
		letter_sound.play()
	
	# TIMING LOGIC (Punctuation Pauses)
	match text[letter_index]:
		"!", ".", "?": timer.start(0.6)
		",": timer.start(0.2)
		" ": timer.start(0.06)
		_: timer.start(0.04)

func _on_letter_display_timer_timeout():
	display_letter()

# --- SKIP FUNCTION ---
func skip_typing():
	# 1. Stop the timer so it doesn't keep trying to add letters
	timer.stop()
	
	# 2. Force the label to show the FULL text immediately
	label.text = text
	
	# 3. Trigger the finish logic
	finish_displaying_logic()

func finish_displaying_logic():
	next_indicator.visible = true # Show arrow
	finished_displaying.emit()

func close():
	var tween = create_tween()
	# Scale down to (0, 0)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	queue_free()
