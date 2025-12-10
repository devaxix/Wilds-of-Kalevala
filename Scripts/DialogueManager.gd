extends Node

signal dialogue_finished

@onready var text_box_scene = preload("res://Scenes/Areas/text_box.tscn") 

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var is_dialogue_active = false
var can_advance_line = false
var is_typing = false 

# --- MODE FLAGS ---
var is_fox_mode: bool = false

# 1. Standard Dialogue (Wood Box, Fixed Position)
# REMOVED: The "position" argument. It now always stays in the .tscn position.
func start_dialogue(lines: Array[String]):
	if is_dialogue_active: return
	
	dialogue_lines = lines
	is_fox_mode = false # Use Wood Box
	
	show_text_box()
	is_dialogue_active = true

# 2. Fox Dialogue (Blue Box, Fixed Position)
func start_fox_dialogue(lines: Array[String]):
	if is_dialogue_active: return
	
	dialogue_lines = lines
	is_fox_mode = true # Use Blue Box
	
	show_text_box()
	is_dialogue_active = true

func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	
	var layer = CanvasLayer.new()
	layer.layer = 128
	get_tree().root.add_child(layer)
	layer.add_child(text_box)
	
	# Apply Visuals (Fox vs Wood)
	if text_box.has_method("set_fox_mode"):
		text_box.set_fox_mode(is_fox_mode)
	
	# --- POSITIONING REMOVED ---
	# We deleted all the code that moves the box.
	# It will now appear exactly where you placed it in text_box.tscn!
	
	is_typing = true 
	can_advance_line = false
	text_box.display_text(dialogue_lines[current_line_index])

func _on_text_box_finished_displaying():
	is_typing = false
	can_advance_line = true

func _input(event):
	var is_mouse_click = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	var is_key_press = (event.is_action_pressed("Attack") or event.is_action_pressed("Jump") or event.is_action_pressed("ui_accept"))
	
	if is_dialogue_active and (is_mouse_click or is_key_press):
		if is_typing:
			if text_box.has_method("skip_typing"):
				text_box.skip_typing()
				is_typing = false
				can_advance_line = true
			get_viewport().set_input_as_handled()
			return 

		if can_advance_line:
			get_viewport().set_input_as_handled()
			can_advance_line = false
			
			if text_box:
				await text_box.close() 
			
			await get_tree().create_timer(0.2).timeout
			
			current_line_index += 1
			if current_line_index >= dialogue_lines.size():
				is_dialogue_active = false
				current_line_index = 0
				dialogue_finished.emit() 
				return
				
			show_text_box()
