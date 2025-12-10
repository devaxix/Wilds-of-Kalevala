extends Node

signal dialogue_finished

@onready var text_box_scene = preload("res://Scenes/Areas/text_box.tscn") 

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialogue_active = false
var can_advance_line = false
var is_typing = false 

# --- STYLE OVERRIDES ---
var custom_texture: Texture2D = null
var custom_pitch: float = 1.0
var use_custom_theme: bool = false

# --- NEW: POSITIONING FLAGS ---
var is_fixed_position: bool = false # If true, we NEVER convert coordinates

# FUNCTION 1: Standard Dialogue (Follows World Objects/Player)
func start_dialogue(position: Vector2, lines: Array[String]):
	if is_dialogue_active: return
	
	dialogue_lines = lines
	text_box_position = position
	is_fixed_position = false # Default: It's a world position
	
	show_text_box()
	is_dialogue_active = true

# FUNCTION 2: Screen Dialogue (For Cutscenes/Narrator/Fox)
# This forces the box to stay at specific screen coordinates (e.g. 960, 1000)
func start_screen_dialogue(screen_position: Vector2, lines: Array[String]):
	if is_dialogue_active: return
	
	dialogue_lines = lines
	text_box_position = screen_position
	is_fixed_position = true # FIXED: Do not move with camera
	
	show_text_box()
	is_dialogue_active = true

# --- STYLE FUNCTIONS ---
func set_custom_theme(texture: Texture2D, pitch: float):
	custom_texture = texture
	custom_pitch = pitch
	use_custom_theme = true

func reset_theme():
	use_custom_theme = false
	custom_texture = null
	custom_pitch = 1.0

func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	
	var layer = CanvasLayer.new()
	layer.layer = 128
	get_tree().root.add_child(layer)
	layer.add_child(text_box)
	
	# Apply Custom Theme
	if use_custom_theme:
		if text_box.has_method("set_dialogue_theme"):
			text_box.set_dialogue_theme(custom_texture, custom_pitch)
	
	# --- POSITIONING LOGIC ---
	var final_position = text_box_position
	
	# Only convert World->Screen if it is NOT a fixed position
	# (This allows Normal Levels to have fixed Narrator boxes now!)
	if not is_fixed_position and not use_custom_theme:
		final_position = get_viewport().get_canvas_transform() * text_box_position
		final_position.y -= 100 

	text_box.global_position = final_position
	
	# Wait 1 frame to center
	await get_tree().process_frame
	
	text_box.global_position.x -= text_box.size.x / 2
	text_box.global_position.y -= text_box.size.y / 2
	
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
