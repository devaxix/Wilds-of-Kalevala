class_name PlayerController
extends CharacterBody2D

# --- VARIABLES ---
@export var speed = 500
@export var jump_power = -500
@export var max_health = 3
@export var knockback_force = 300

# WALL JUMP SETTINGS
@export var wall_slide_gravity = 100
@export var wall_jump_push = 500
@export var wall_jump_force = -400

# --- DASH SETTINGS ---
@export var dash_speed = 2500
@export var dash_duration = 0.2
@export var dash_cooldown = 1.0

@export var game_ui : CanvasLayer

# --- HEALTH SIGNALS ---
signal health_changed(new_health)
signal player_died

# --- NODES ---
@onready var sprite = $PlayerAnimator/Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var wall_jump_check = $WallJumpCheck
@onready var game_manager = get_tree().root.get_node("GameManager")

# --- SEASONAL FOOTSTEPS & VOLUME ---
@onready var footstep_player = $FootstepSound # Make sure this matches your node name

# 1. Sound Files
@export_group("Footstep Sounds")
@export var steps_spring : AudioStream
@export var steps_summer : AudioStream 
@export var steps_autumn : AudioStream 
@export var steps_winter : AudioStream 

# 2. Volume Sliders (in Decibels)
# 0.0 is normal, -10.0 is quiet, +5.0 is loud
@export_group("Footstep Volume")
@export_range(-40.0, 10.0) var vol_spring_db : float = 0.0
@export_range(-40.0, 10.0) var vol_summer_db : float = 0.0
@export_range(-40.0, 10.0) var vol_autumn_db : float = 0.0
@export_range(-40.0, 10.0) var vol_winter_db : float = 0.0

# JUMP SOUNDS 
@onready var jump_sounds = [
	$JumpSound1, $JumpSound2, $JumpSound3,
	$JumpSound4 if has_node("JumpSound4") else null,
	$JumpSound5 if has_node("JumpSound5") else null
]

# HURT SOUNDS 
@onready var hurt_sounds = [
	$HurtSound1, $HurtSound2, $HurtSound3, $HurtSound4,
	$HurtSound5 if has_node("HurtSound5") else null
]

# ATTACK SOUNDS 
@onready var attack_sounds = [
	$AttackSound1, $AttackSound2, $AttackSound3,
	$AttackSound4 if has_node("AttackSound4") else null
]

# SWORD SOUNDS - CHECK BOTH NAMES (FIXED)
@onready var sword_sounds = _get_sword_sounds()

func _get_sword_sounds():
	# Check for "FSword" (Girl Player)
	if has_node("FSwordSound1"):
		return [
			$FSwordSound1, $FSwordSound2, $FSwordSound3, 
			$FSwordSound4 if has_node("FSwordSound4") else null,
			$FSwordSound5 if has_node("FSwordSound5") else null
		]
	# Check for "Sword" (Boy Player)
	elif has_node("SwordSound1"):
		return [
			$SwordSound1, $SwordSound2, $SwordSound3, 
			$SwordSound4 if has_node("SwordSound4") else null,
			$SwordSound5 if has_node("SwordSound5") else null
		]
	return []

# FOOTSTEP SOUND NODE (Must be present for the @onready to work)
@onready var footstep_sound = $FootstepSound if has_node("FootstepSound") else null

# --- STATE ---
var current_health = 3
var direction = 0
var look_dir_x = 1

# MEMORIES
var has_sword_memory = false
var has_wall_jump_memory = false
var has_double_jump_memory = false
var has_dash_memory = false

var is_attacking = false
var is_hurt = false
var is_dashing = false
var can_dash = true

# CUTSCENE STATE
var is_cutscene = false

# Wall Jump & Double Jump Logic
var wall_jump_lock = 0.0
var jump_count = 0
var max_jumps = 1

func _ready():
	current_health = max_health
	if has_node("Camera2D2"):
		$Camera2D2.reset_smoothing()
		
	# CRITICAL: Load saved memories from the Game Manager
	if is_instance_valid(game_manager):
		has_sword_memory = game_manager.unlocked_sword
		has_wall_jump_memory = game_manager.unlocked_wall_jump
		has_double_jump_memory = game_manager.unlocked_double_jump
		if has_double_jump_memory:
			max_jumps = 2
		has_dash_memory = game_manager.unlocked_dash

# --- PHYSICS PROCESS (MOVEMENT & INPUT) ---
func _physics_process(delta: float) -> void:
	if is_cutscene:
		return

	# --- DASH PHYSICS ---
	if is_dashing:
		velocity.y = 0
		velocity.x = look_dir_x * dash_speed
		move_and_slide()
		return
		
# 2. DIALOGUE LOCK (Soft Freeze) <--- ADD THIS BLOCK
	if DialogueManager.is_dialogue_active:
		# Apply gravity so we land safely if in air
		if not is_on_floor():
			velocity.y += 980 * delta
			
		# Slow down horizontal movement to 0
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		
		move_and_slide()
		return # STOP READING! No Jump, Dash, or Attack allowed.
		
	# 1. GRAVITY
	if not is_on_floor():
		velocity.y += 980 * delta
	else:
		jump_count = 0
		if not is_dashing and has_node("DashTimer") and $DashTimer.time_left == 0:
			can_dash = true

	# 2. HURT LOCK
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, 10)
		move_and_slide()
		return

	# 3. UPDATE DIRECTION & SENSORS
	direction = Input.get_axis("Move Left", "Move Right")

	if velocity.x != 0:
		look_dir_x = sign(velocity.x)

	if direction != 0:
		wall_jump_check.target_position.x = 15 * direction

	# 4. WALL SLIDE LOGIC
	if has_wall_jump_memory and wall_jump_check.is_colliding() and not is_on_floor() and velocity.y > 0:
		velocity.y = wall_slide_gravity
		jump_count = 0

	# 5. JUMP & WALL JUMP & DOUBLE JUMP
	if Input.is_action_just_pressed("Jump"):
		# A. Wall Jump
		if not is_on_floor() and has_wall_jump_memory and wall_jump_check.is_colliding():
			velocity.y = wall_jump_force
			velocity.x = -look_dir_x * wall_jump_push
			wall_jump_lock = 0.2
			play_random_jump_sound()

		# B. Normal & Double Jump
		elif jump_count < max_jumps:
			velocity.y = jump_power
			jump_count += 1
			play_random_jump_sound()

	# --- DASH INPUT ---
	if Input.is_action_just_pressed("Dash") and has_dash_memory and can_dash:
		start_dash()

	# 6. MOVEMENT
	if wall_jump_lock > 0:
		wall_jump_lock -= delta

	if wall_jump_lock <= 0:
		if direction:
			velocity.x = direction * speed
			if has_node("SwordHitbox"):
				$SwordHitbox.scale.x = 1 if direction > 0 else -1
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# 7. ATTACK
	if Input.is_action_just_pressed("Attack") and has_sword_memory and not is_attacking:
		attack()

	move_and_slide()

# --- AUDIO ACTIONS (All previous logic) ---

func play_random_jump_sound():
	var available_sounds = jump_sounds.filter(func(sound): return is_instance_valid(sound))
	if not available_sounds.is_empty():
		var random_index = randi() % available_sounds.size()
		available_sounds[random_index].play()

func play_random_hurt_sound():
	var available_sounds = hurt_sounds.filter(func(sound): return is_instance_valid(sound))
	if not available_sounds.is_empty():
		var random_index = randi() % available_sounds.size()
		available_sounds[random_index].play()

func play_random_attack_sound():
	var available_sounds = attack_sounds.filter(func(sound): return is_instance_valid(sound))
	if not available_sounds.is_empty():
		var random_index = randi() % available_sounds.size()
		available_sounds[random_index].play()

func play_random_sword_sound():
	# Use the pre-filtered sword_sounds array
	var available_sounds = sword_sounds.filter(func(sound): return is_instance_valid(sound))
	if not available_sounds.is_empty():
		var random_index = randi() % available_sounds.size()
		available_sounds[random_index].play()

func play_footstep_sound():
	# --- 1. Safety Checks ---
	if not is_instance_valid(footstep_player): return
	if not is_on_floor(): return
	if abs(velocity.x) < 10: return 

	# --- 2. Determine Sound & Volume ---
	var sound_to_play = steps_spring # Default
	var volume_to_use = vol_spring_db # Default Volume
	
	match GameManager.current_season:
		"Summer":
			sound_to_play = steps_summer
			volume_to_use = vol_summer_db
		"Autumn":
			sound_to_play = steps_autumn
			volume_to_use = vol_autumn_db
		"Winter":
			sound_to_play = steps_winter
			volume_to_use = vol_winter_db
		"Spring", "Area1":
			sound_to_play = steps_spring
			volume_to_use = vol_spring_db

	# --- 3. Apply Changes ---
	if sound_to_play != null:
		# Only swap the stream if it's different to prevent stuttering
		if footstep_player.stream != sound_to_play:
			footstep_player.stream = sound_to_play
		
		# Always update volume (it changes instantly)
		footstep_player.volume_db = volume_to_use
	
	# --- 4. Play ---
	footstep_player.pitch_scale = randf_range(0.9, 1.1)
	footstep_player.play()

# --- ACTIONS (All previous logic) ---

func start_dash():
	print("Attempting to Dash...")
	is_dashing = true
	can_dash = false

	if sprite: sprite.modulate = Color(10, 10, 10)

	await get_tree().create_timer(dash_duration).timeout

	if sprite: sprite.modulate = Color(1, 1, 1)

	is_dashing = false
	velocity.x = 0

	if has_node("DashTimer"):
		$DashTimer.start()
	else:
		print("ERROR: Missing DashTimer node!")

func attack():
	is_attacking = true
	play_random_attack_sound()
	play_random_sword_sound()

	if animation_player:
		animation_player.play("Attack")
		await animation_player.animation_finished
		is_attacking = false
		animation_player.play("Idle")

# --- MEMORY UNLOCKS (All previous logic) ---
func unlock_sword_memory():
	has_sword_memory = true
	# CRITICAL: Update the permanent storage
	if is_instance_valid(game_manager):
		game_manager.unlocked_sword = true 
	print("MEMORY UNLOCKED: Sword!")

func unlock_wall_jump_memory():
	has_wall_jump_memory = true
	if is_instance_valid(game_manager):
		game_manager.unlocked_wall_jump = true
	print("MEMORY UNLOCKED: Wall Jump!")

func unlock_double_jump_memory():
	has_double_jump_memory = true
	max_jumps = 2 
	if is_instance_valid(game_manager):
		game_manager.unlocked_double_jump = true
	print("MEMORY UNLOCKED: Double Jump!")

func unlock_dash_memory():
	has_dash_memory = true
	if is_instance_valid(game_manager):
		game_manager.unlocked_dash = true
	print("MEMORY UNLOCKED: Dash!")

# --- DAMAGE LOGIC (All previous logic) ---
func take_damage(amount, enemy_pos = Vector2.ZERO):
	if is_hurt or is_dashing:
		return

	play_random_hurt_sound()

	current_health -= amount
	health_changed.emit(current_health)

	if current_health <= 0:
		player_died.emit()
		die()
	else:
		apply_knockback(enemy_pos)

func apply_knockback(enemy_pos):
	is_hurt = true
	is_attacking = false
	if sprite: sprite.modulate = Color(1, 0, 0)

	var dir = (enemy_pos.x - global_position.x)
	if dir > 0: velocity.x = -knockback_force
	else: velocity.x = knockback_force
	velocity.y = -200

	await get_tree().create_timer(0.4).timeout
	is_hurt = false
	if sprite: sprite.modulate = Color(1, 1, 1)

func die():
	print("Player Died.")
	# DELETE or COMMENT OUT this line:
	# call_deferred("_reload_scene") 
	
	# Instead, we just emit the signal and stop moving
	player_died.emit()
	set_physics_process(false) # Stop the player from moving/falling
	if animation_player: animation_player.pause() # Freeze animation

func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1, global_position)
	elif area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, global_position)

func _on_dash_timer_timeout():
	print("Dash Cooldown Over.")
	can_dash = true
