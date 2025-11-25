class_name PlayerController
extends CharacterBody2D

# --- VARIABLES ---
@export var speed = 10
@export var jump_power = 10
@export var max_health = 3
@export var knockback_force = 300
@export var game_ui : CanvasLayer

# --- NODE REFERENCES ---
# (Update these paths if you moved nodes!)
@onready var sprite = $PlayerAnimator/Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sword_hitbox = $SwordHitbox

var current_health = 3
var speed_multiplier = 30
var jump_multiplier = -30
var direction = 0

# --- STATE VARIABLES (These were missing!) ---
var has_sword_memory = false
var is_attacking = false
var is_hurt = false

func _ready():
	current_health = max_health
	# Reset camera smoothing
	if has_node("Camera2D2"):
		$Camera2D2.reset_smoothing()
	
	if game_ui:
		game_ui.update_hearts(current_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 1. HURT LOCK
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, 10)
		move_and_slide()
		return

	# 2. JUMP
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# 3. MOVE
	direction = Input.get_axis("Move Left", "Move Right")
	
	if direction:
		velocity.x = direction * speed * speed_multiplier
		
		# --- FIX: FLIP THE SWORD HITBOX ---
		if direction > 0:
			# Facing Right: Normal
			sword_hitbox.scale.x = 1 
		elif direction < 0:
			# Facing Left: Flip the hitbox to the left!
			sword_hitbox.scale.x = -1 
			
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)
		
	# 4. ATTACK INPUT
	if Input.is_action_just_pressed("Attack"):
		# This print will help us debug!
		print("Attack Button Pressed. Memory:", has_sword_memory, " Attacking:", is_attacking)
		
	if Input.is_action_just_pressed("Attack") and has_sword_memory and not is_attacking:
		attack()

	move_and_slide()

# --- ACTIONS ---

func attack():
	is_attacking = true
	
	if animation_player:
		print("PLAYING ATTACK ANIMATION NOW!") # <--- Look for this
		animation_player.play("Attack")
		await animation_player.animation_finished
		is_attacking = false
		animation_player.play("Idle")
	else:
		print("ERROR: AnimationPlayer NOT FOUND!") # <--- This is likely what is happening

func unlock_sword_memory():
	has_sword_memory = true
	print("MEMORY UNLOCKED!")

# --- DAMAGE & DEATH ---

func take_damage(amount, enemy_pos = Vector2.ZERO):
	if is_hurt: return
	
	current_health -= amount
	print("Player Health: ", current_health)
	
	if game_ui:
		game_ui.update_hearts(current_health)
		
	if current_health <= 0:
		die()
	else:
		apply_knockback(enemy_pos)

func apply_knockback(enemy_pos):
	is_hurt = true
	is_attacking = false
	
	if sprite: sprite.modulate = Color(1, 0, 0)
	
	var dir = (enemy_pos.x - global_position.x)
	if dir > 0:
		velocity.x = -knockback_force
	else:
		velocity.x = knockback_force
	velocity.y = -200
	
	await get_tree().create_timer(0.4).timeout
	
	is_hurt = false
	if sprite: sprite.modulate = Color(1, 1, 1)

func die():
	print("Player Died.")
	get_tree().reload_current_scene()

# --- SIGNAL ---
# --- SIGNAL ---
func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	# DEBUG PRINT
	print("⚔️ HITBOX TOUCHED: ", body.name)
	
	if body.has_method("take_damage"):
		print("   -> DEALING DAMAGE!")
		body.take_damage(1)
		
		


func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	print("HIT AN AREA: ", area.name)
	
	if area.has_method("take_damage"):
		print("   -> HURTBOX FOUND! ATTACKING!")
		area.take_damage(1)
		
	elif area.get_parent().has_method("take_damage"):
		print("   -> PARENT ENEMY FOUND! ATTACKING!")
		area.get_parent().take_damage(1)
