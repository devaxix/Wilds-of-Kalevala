extends Node2D

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI

# --- HEALTH UI REFERENCES (FIXED PATHS) ---
# We must look inside GameUI to find the HeartContainer
@onready var heart1 = $GameUI/HeartContainer/Heart1 if has_node("GameUI/HeartContainer/Heart1") else null
@onready var heart2 = $GameUI/HeartContainer/Heart2 if has_node("GameUI/HeartContainer/Heart2") else null
@onready var heart3 = $GameUI/HeartContainer/Heart3 if has_node("GameUI/HeartContainer/Heart3") else null

# Load heart textures (Ensure these match your files exactly)
const FULL_HEART: Texture2D = preload("res://Sprites/heart.png")
const EMPTY_HEART: Texture2D = preload("res://Sprites/empty heart 1.png")

# --- AMBIANCE REFERENCES ---
# AUTUMN
@onready var wind_ambiance = $WindAmbiance if has_node("WindAmbiance") else null
@onready var crow_ambiance = $CrowAmbiance if has_node("CrowAmbiance") else null
@onready var acorn_ambiance = $AcornAmbiance if has_node("AcornAmbiance") else null
@onready var leaves_blowing_ambiance = $LeavesBlowingAmbiance if has_node("LeavesBlowingAmbiance") else null

# SUMMER
@onready var bird_ambiance = $BirdAmbiance if has_node("BirdAmbiance") else null
@onready var timed_summer_sfx = $TimedSummerSFX if has_node("TimedSummerSFX") else null
@onready var summer_loop_ambiance_2 = $SummerLoopAmbiance2 if has_node("SummerLoopAmbiance2") else null
@onready var river_ambiance = $RiverAmbiance if has_node("RiverAmbiance") else null

# SPRING
@onready var spring_bird_ambiance = $SpringBirdAmbiance if has_node("SpringBirdAmbiance") else null
@onready var woodpecker_ambiance = $WoodpeckerAmbiance if has_node("WoodpeckerAmbiance") else null
@onready var woodpecker_sfx_timer = $WoodpeckerSFXTimer if has_node("WoodpeckerSFXTimer") else null

# RANDOM SFX
@onready var random_sfx_timer = $RandomSFXTimer if has_node("RandomSFXTimer") else null
@onready var random_sfx_1 = $RandomSFX1 if has_node("RandomSFX1") else null
@onready var random_sfx_2 = $RandomSFX2 if has_node("RandomSFX2") else null
@onready var random_sfx_3 = $RandomSFX3 if has_node("RandomSFX3") else null

func _ready():
    # 1. Start Ambiance
    if is_instance_valid(wind_ambiance): wind_ambiance.play()
    if is_instance_valid(crow_ambiance): crow_ambiance.play()
    if is_instance_valid(acorn_ambiance): acorn_ambiance.play()
    if is_instance_valid(leaves_blowing_ambiance): leaves_blowing_ambiance.play()
    
    if is_instance_valid(bird_ambiance): bird_ambiance.play()
    if is_instance_valid(summer_loop_ambiance_2): summer_loop_ambiance_2.play()
    if is_instance_valid(river_ambiance): river_ambiance.play()

    if is_instance_valid(spring_bird_ambiance): spring_bird_ambiance.play()
    
    # 1B. Reset Hearts
    update_hearts_ui(3)
    
    # 2. Spawn Player
    spawn_player()
    
    await get_tree().create_timer(0.7).timeout
    var lines: Array[String] = ["What was my name again?"]
    DialogueManager.start_dialogue($PlayerSpawnPoint.global_position, lines)

# --- TIMERS ---
func _on_summer_sfx_timer_timeout():
    if is_instance_valid(timed_summer_sfx): timed_summer_sfx.play()

func _on_woodpecker_sfx_timer_timeout():
    if is_instance_valid(woodpecker_ambiance): woodpecker_ambiance.play()

func _on_random_sfx_timer_timeout() -> void:
    var available_sfx: Array[AudioStreamPlayer] = []
    if is_instance_valid(random_sfx_1): available_sfx.append(random_sfx_1)
    if is_instance_valid(random_sfx_2): available_sfx.append(random_sfx_2)
    if is_instance_valid(random_sfx_3): available_sfx.append(random_sfx_3)
    
    if available_sfx.size() > 0:
        available_sfx.pick_random().play()

# --- UI UPDATE ---
func update_hearts_ui(current_health: int):
    if is_instance_valid(heart3):
        heart3.texture = FULL_HEART if current_health >= 3 else EMPTY_HEART
    if is_instance_valid(heart2):
        heart2.texture = FULL_HEART if current_health >= 2 else EMPTY_HEART
    if is_instance_valid(heart1):
        heart1.texture = FULL_HEART if current_health >= 1 else EMPTY_HEART

# --- SPAWN PLAYER ---
func spawn_player():
    var player_scene = load(GameManager.selected_character_path)
    var player_instance = player_scene.instantiate()
    
    if player_instance.has_signal("health_changed"):
        player_instance.health_changed.connect(update_hearts_ui)
    
    player_instance.position = spawn_point.position
    player_instance.name = "Player"
    player_instance.game_ui = game_ui
    add_child(player_instance)
