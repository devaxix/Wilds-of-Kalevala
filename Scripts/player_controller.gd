class_name PlayerController
extends CharacterBody2D

# --- VARIABLES ---
@export var speed = 900
@export var jump_power = -1200
@export var max_health = 3
@export var knockback_force = 300

# WALL JUMP SETTINGS
@export var wall_slide_gravity = 100
@export var wall_jump_push = 800
@export var wall_jump_force = -400

@export var game_ui : CanvasLayer 

# --- NODES ---
@onready var sprite = $PlayerAnimator/Sprite2D
@onready var animation_player = $AnimationPlayer

# --- STATE ---
var current_health = 3
var direction = 0

var has_sword_memory = false 
var has_wall_jump_memory = false 
var is_attacking = false
var is_hurt = false

# Wall Jump Logic
var look_dir_x = 1
var wall_jump_lock = 0.0

func _ready():
	current_health = max_health
	if has_node("Camera2D2"):
		$Camera2D2.reset_smoothing()
	if game_ui:
		game_ui.update_hearts(current_health)

func _physics_process(delta: float) -> void:
	# 1. GRAVITY
	if not is_on_floor():
		# Wall Slide Logic
		if has_wall_jump_memory and is_on_wall() and velocity.y > 0:
			velocity.y = wall_slide_gravity
		else:
			velocity.y += 980 * delta # Standard Gravity

	# 2. HURT LOCK
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, 10)
		move_and_slide()
		return 

	# 3. UPDATE LOOK DIRECTION
	if velocity.x != 0:
		look_dir_x = sign(velocity.x)

	# 4. JUMP & WALL JUMP
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			velocity.y = jump_power
		elif has_wall_jump_memory and is_on_wall():
			velocity.y = wall_jump_force 
			velocity.x = -look_dir_x * wall_jump_push
			wall_jump_lock = 0.8

	# 5. MOVEMENT
	direction = Input.get_axis("Move Left", "Move Right")
	
	if wall_jump_lock > 0:
		wall_jump_lock -= delta
	
	if wall_jump_lock <= 0:
		if direction:
			velocity.x = direction * speed
			
			# FLIP HITBOX (Crucial for hitting enemies behind you!)
			if has_node("SwordHitbox"):
				if direction > 0: $SwordHitbox.scale.x = 1
				else: $SwordHitbox.scale.x = -1
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# 6. ATTACK
	if Input.is_action_just_pressed("Attack") and has_sword_memory and not is_attacking:
		attack()

	move_and_slide()

# --- ACTIONS ---

func attack():
	is_attacking = true
	if animation_player:
		animation_player.play("Attack")
		await animation_player.animation_finished
		is_attacking = false
		animation_player.play("Idle")

func unlock_sword_memory():
	has_sword_memory = true
	print("MEMORY UNLOCKED: Sword!")

func unlock_wall_jump_memory():
	has_wall_jump_memory = true
	print("MEMORY UNLOCKED: Wall Jump!")

# --- DAMAGE LOGIC ---

func take_damage(amount, enemy_pos = Vector2.ZERO):
	if is_hurt: return
	
	current_health -= amount
	if game_ui: game_ui.update_hearts(current_health)
		
	if current_health <= 0:
		die()
	else:
		apply_knockback(enemy_pos)

func apply_knockback(enemy_pos):
	is_hurt = true
	is_attacking = false
	if sprite: sprite.modulate = Color(1, 0, 0) # RED
	
	var dir = (enemy_pos.x - global_position.x)
	if dir > 0: velocity.x = -knockback_force
	else: velocity.x = knockback_force
	velocity.y = -200
	
	await get_tree().create_timer(0.4).timeout
	is_hurt = false
	if sprite: sprite.modulate = Color(1, 1, 1) # WHITE

func die():
	print("Player Died.")
	get_tree().reload_current_scene()

# --- COMBAT SIGNAL (This kills the Skeleton) ---
func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	print("⚔️ HIT AREA: ", area.name)
	
	# Hit the Hurtbox?
	if area.has_method("take_damage"):
		area.take_damage(1)
	# Hit the Enemy Root?
	elif area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1)
