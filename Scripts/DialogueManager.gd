extends Node

signal dialogue_finished

# Check your path!
@onready var text_box_scene = preload("res://Scenes/Areas/text_box.tscn") 

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialogue_active = false
var can_advance_line = false
var is_typing = false # NEW: Tracks if letters are still appearing

func start_dialogue(position: Vector2, lines: Array[String]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	text_box_position = position
	show_text_box()
	is_dialogue_active = true

func show_text_box():
	text_box = text_box_scene.instantiate()
	
	# Connect to the custom signal in your TextBox script (see step 2 below!)
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	
	var layer = CanvasLayer.new()
	layer.layer = 128
	get_tree().root.add_child(layer)
	layer.add_child(text_box)
	
	# Tell the system we are typing
	is_typing = true 
	can_advance_line = false
	
	text_box.display_text(dialogue_lines[current_line_index])

func _on_text_box_finished_displaying():
	# Called when the typewriter effect ends naturally
	is_typing = false
	can_advance_line = true

func _input(event):
	# 1. Define what counts as a "Next" signal
	var is_mouse_click = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	var is_key_press = (event.is_action_pressed("Attack") or event.is_action_pressed("Jump") or event.is_action_pressed("ui_accept"))
	
	if is_dialogue_active and (is_mouse_click or is_key_press):
		
		# SCENARIO A: Text is still typing -> SKIP IT!
		if is_typing:
			if text_box.has_method("skip_typing"):
				text_box.skip_typing()
				is_typing = false
				can_advance_line = true
			# We set the input as handled so the player doesn't swing their sword
			get_viewport().set_input_as_handled()
			return 

		# SCENARIO B: Text is finished -> NEXT LINE
		if can_advance_line:
			# Stop sword swings
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
