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
	label.text = text_to_display 
	
	await get_tree().process_frame
	
	# 2. POP-UP ANIMATION
	# Set pivot to center so it grows from the middle
	pivot_offset = size / 2 
	
	var tween = create_tween()
	# "Back" transition makes it overshoot/bounce slightly
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)
	
	# 3. Reset Indicator
	next_indicator.visible = false # Hide arrow while typing
	
	label.text = "" 
	letter_index = 0
	display_letter()

func display_letter():
	label.text += text[letter_index]
	
	letter_index += 1
	if letter_index >= text.length():
		# 4. SHOW INDICATOR
		next_indicator.visible = true # Text done? Show arrow!
		finished_displaying.emit()
		return
	
	# (Sound logic stays here...)
	if text[letter_index - 1] != " ":
		letter_sound.pitch_scale = randf_range(0.9, 1.1)
		letter_sound.play()
	
	# (Timing logic stays here...)
	match text[letter_index]:
		"!", ".", "?": timer.start(0.6)
		",": timer.start(0.2)
		" ": timer.start(0.06)
		_: timer.start(0.04)

func _on_letter_display_timer_timeout():
	display_letter()

func close():
	var tween = create_tween()
	# Scale down to (0, 0)
	# EASE_IN makes it start slow and zoom out fast
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Wait for the animation to finish
	await tween.finished
	
	# Delete the object
	queue_free()
