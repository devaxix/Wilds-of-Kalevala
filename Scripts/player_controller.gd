class_name PlayerController
extends CharacterBody2D

# --- VARIABLES ---
@export var speed = 900 
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

# --- NODES ---
@onready var sprite = $PlayerAnimator/Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var wall_jump_check = $WallJumpCheck 

# JUMP SOUNDS (FIXED to 5 - matching the available nodes in the scene)
@onready var jump_sounds = [$JumpSound1, $JumpSound2, $JumpSound3, $JumpSound4, $JumpSound5]

# HURT SOUNDS (FIXED to 5 - matching the available nodes in the scene)
@onready var hurt_sounds = [$HurtSound1, $HurtSound2, $HurtSound3, $HurtSound4, $HurtSound5]

# ATTACK SOUNDS (FIXED to 4 - matching the available nodes in the scene)
@onready var attack_sounds = [$AttackSound1, $AttackSound2, $AttackSound3, $AttackSound4]

# SWORD SOUNDS (CORRECTED NAME: SwordSound, FIXED to 5)
@onready var sword_sounds = [$SwordSound1, $SwordSound2, $SwordSound3, $SwordSound4, $SwordSound5]

# FOOTSTEP SOUND NODE (Must be present in scene)
@onready var footstep_sound = $FootstepSound 

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
	if game_ui:
		game_ui.update_hearts(current_health)
		
func _physics_process(delta: float) -> void:
	if is_cutscene: 
		return

	# --- DASH PHYSICS ---
	if is_dashing:
		velocity.y = 0 
		velocity.x = look_dir_x * dash_speed
		move_and_slide()
		return 

	# 1. GRAVITY
	if not is_on_floor():
		velocity.y += 980 * delta
	else:
		jump_count = 0
		# Reset dash if timer is done and we are on floor
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

# --- AUDIO ACTIONS ---

func play_random_jump_sound():
	if not jump_sounds.is_empty():
		var random_index = randi() % jump_sounds.size()
		var selected_sound = jump_sounds[random_index]
		selected_sound.play()

func play_random_hurt_sound():
	if not hurt_sounds.is_empty():
		var random_index = randi() % hurt_sounds.size()
		var selected_sound = hurt_sounds[random_index]
		selected_sound.play()

func play_random_attack_sound():
	if not attack_sounds.is_empty():
		var random_index = randi() % attack_sounds.size()
		var selected_sound = attack_sounds[random_index]
		selected_sound.play()
		
# RENAMED FUNCTION to match new array name
func play_random_sword_sound():
	if not sword_sounds.is_empty():
		var random_index = randi() % sword_sounds.size()
		var selected_sound = sword_sounds[random_index]
		selected_sound.play()

func play_footstep_sound():
	if is_on_floor() and abs(velocity.x) > 10:
		if is_instance_valid(footstep_sound) and not footstep_sound.is_playing(): 
			footstep_sound.play()

# --- ACTIONS ---

func start_dash():
	print("Attempting to Dash...") 
	is_dashing = true
	can_dash = false
	
	# Flash White
	if sprite: sprite.modulate = Color(10, 10, 10)
	
	await get_tree().create_timer(dash_duration).timeout
	
	# Reset
	if sprite: sprite.modulate = Color(1, 1, 1)
	
	is_dashing = false
	velocity.x = 0 
	
	if has_node("DashTimer"):
		$DashTimer.start()
	else:
		print("ERROR: Missing DashTimer node!")

func attack():
	is_attacking = true
	# Play random attack sound (voice/grunt)
	play_random_attack_sound()
	# Play random sword sound (slash/hit) 
	play_random_sword_sound() # <-- Calling the corrected function
	
	if animation_player:
		animation_player.play("Attack")
		await animation_player.animation_finished
		is_attacking = false
		animation_player.play("Idle")

# --- MEMORY UNLOCKS ---
func unlock_sword_memory():
	has_sword_memory = true
	# GameManager.unlocked_sword = true
	print("MEMORY UNLOCKED: Sword!")

func unlock_wall_jump_memory():
	has_wall_jump_memory = true
	# GameManager.unlocked_wall_jump = true
	print("MEMORY UNLOCKED: Wall Jump!")

func unlock_double_jump_memory():
	has_double_jump_memory = true
	# GameManager.unlocked_double_jump = true
	max_jumps = 2 
	print("MEMORY UNLOCKED: Double Jump!")

func unlock_dash_memory():
	has_dash_memory = true
	# GameManager.unlocked_dash = true
	print("MEMORY UNLOCKED: Dash!")

# --- DAMAGE LOGIC ---
func take_damage(amount, enemy_pos = Vector2.ZERO):
	if is_hurt or is_dashing: 
		return 

	# PLAY RANDOM HURT SOUND HERE 
	play_random_hurt_sound() 
	
	current_health -= amount
	if game_ui: game_ui.update_hearts(current_health)
	
	if current_health <= 0:
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
	call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()

func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1, global_position) 
	elif area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, global_position)

func _on_dash_timer_timeout():
	print("Dash Cooldown Over.")
	can_dash = true
