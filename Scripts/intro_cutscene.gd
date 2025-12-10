extends Control

# --- CONFIGURATION ---
const GAME_SCENE = "res://Scenes/Areas/Area1.tscn"

# 1. The Opening Story
var intro_lines: Array[String] = [
	"Ouch...",
	"My head... it's throbbing.",
	"Wait... what was that warmth?",
	"It smells like home...",
	".......",
	"I... I can't remember.",
	"How did I get here? What was I chasing?",
	"A flash of white... No, it's gone now.",
	"This place... it's not familiar. What forest is this?",
	"What was my name?",
	"It's quiet... too quiet.",
	"But... I feel something.",
	"A gentle pull, right in my chest.",
	"Like the forest is waiting for me.",
	"If I follow it, maybe I'll remember.",
	"Maybe... I'll find my name there."
]

# 2. The Confirmation Text (After clicking a face)
var confirm_boy_lines: Array[String] = ["Yes... I remember him."]
var confirm_girl_lines: Array[String] = ["Yes... I remember her."]

# --- NODES ---
@onready var boy_btn = $HBoxContainer/BoyButton
@onready var girl_btn = $HBoxContainer/GirlButton
@onready var title_label = $Label

# --- SOUND NODES ---
@onready var owl_timer = $Owl_Timer              
@onready var owl_player = $Owlhooting            


func _ready():
	# 1. HIDE UI
	boy_btn.modulate.a = 0
	girl_btn.modulate.a = 0
	title_label.modulate.a = 0
	boy_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	girl_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 2. CONNECT SIGNALS
	boy_btn.pressed.connect(_on_boy_button_pressed)
	girl_btn.pressed.connect(_on_girl_button_pressed)
	
	# 3. CONNECT THE OWL TIMER
	owl_timer.timeout.connect(_on_owl_timer_timeout) 
	
	# 4. START DIALOGUE
	DialogueManager.dialogue_finished.connect(_on_intro_finished)
	
	await get_tree().create_timer(0.5).timeout
	
	# --- FIX 1: REMOVED POSITION ARGUMENT ---
	# We just send the text now!
	DialogueManager.start_dialogue(intro_lines)

# --- PHASE 2: REVEAL SELECTION ---
func _on_intro_finished():
	DialogueManager.dialogue_finished.disconnect(_on_intro_finished)
	
	# Fade In UI
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(boy_btn, "modulate:a", 1.0, 1.0)
	tween.tween_property(girl_btn, "modulate:a", 1.0, 1.0)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	
	# Enable Clicking
	boy_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	girl_btn.mouse_filter = Control.MOUSE_FILTER_STOP

# --- PHASE 3: HANDLE CHOICE ---
func _on_boy_button_pressed():
	choose_character(0, confirm_boy_lines)

func _on_girl_button_pressed():
	choose_character(1, confirm_girl_lines)

func choose_character(index, lines):
	# 1. Lock Choice
	boy_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	girl_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 2. SAVE THE PATH
	if index == 0:
		GameManager.selected_character_path = "res://Scenes/Player/player.tscn"
	else:
		GameManager.selected_character_path = "res://Scenes/Player/Player_Girl.tscn"
	
	# 3. Fade Out UI
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(boy_btn, "modulate:a", 0.0, 0.5)
	tween.tween_property(girl_btn, "modulate:a", 0.0, 0.5)
	tween.tween_property(title_label, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	
	# 4. Play "I Remember" Text
	DialogueManager.dialogue_finished.connect(_on_confirm_finished)
	
	# --- FIX 2: REMOVED POSITION ARGUMENT ---
	DialogueManager.start_dialogue(lines)

# --- PHASE 4: START GAME ---
func _on_confirm_finished():
	DialogueManager.dialogue_finished.disconnect(_on_confirm_finished)
	TransitionScreen.transition_to_scene(GAME_SCENE)

# --- SOUND REPEATER FUNCTION ---
func _on_owl_timer_timeout() -> void:
	owl_player.play()
