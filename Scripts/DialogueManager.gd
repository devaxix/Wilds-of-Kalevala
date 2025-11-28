extends Node

signal dialogue_finished
@onready var text_box_scene = preload("res://Scenes/Areas/text_box.tscn") # CHECK YOUR PATH!

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialogue_active = false
var can_advance_line = false

func start_dialogue(position: Vector2, lines: Array[String]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	text_box_position = position
	show_text_box()
	is_dialogue_active = true

func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	
	# OLD: get_tree().root.add_child(text_box)
	
	# NEW: Add to a temporary CanvasLayer to force it on top!
	var layer = CanvasLayer.new()
	layer.layer = 100 # Very high number
	get_tree().root.add_child(layer)
	layer.add_child(text_box)
	
	text_box.display_text(dialogue_lines[current_line_index])
	can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true

func _unhandled_input(event):
	if (
		event.is_action_pressed("Attack") or 
		event.is_action_pressed("Jump")
	) and is_dialogue_active and can_advance_line:
		
		# --- CHANGED CODE START ---
		# Instead of instantly deleting, we play the animation
		if text_box:
			text_box.close() 
		# --- CHANGED CODE END ---
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			# Signal that we are fully done
			dialogue_finished.emit() 
			return
		
		show_text_box()
