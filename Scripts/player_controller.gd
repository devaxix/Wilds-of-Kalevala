class_name PlayerController
extends CharacterBody2D

# --- VARIABLES ---
@export var speed = 10
@export var jump_power = 10
@export var max_health = 3
@export var knockback_force = 300

# Drag your GameUI node here in the Inspector!
@export var game_ui : CanvasLayer 

var current_health = 3
var speed_multiplier = 30
var jump_multiplier = -30
var direction = 0

# Logic States
var has_sword_memory = false 
var is_attacking = false
var is_hurt = false # For knockback

func _ready():
	current_health = max_health
	# Reset camera smoothing so it doesn't swoop at start
	if has_node("Camera2D2"):
		$Camera2D2.reset_smoothing()
	
	# Update the UI immediately when the game starts
	if game_ui:
		game_ui.update_hearts(current_health)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 1. KNOCKBACK CHECK: If hurt, don't allow movement
	if is_hurt:
		# Slide slightly while being knocked back
		velocity.x = move_toward(velocity.x, 0, 10)
		move_and_slide()
		return # STOP HERE! Don't let the player move or attack.

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# Movement
	direction = Input.get_axis("Move Left", "Move Right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	# Sword Attack (Only if memory is unlocked!)
	if Input.is_action_just_pressed("Attack") and has_sword_memory and not is_attacking:
		attack()

	move_and_slide()

# --- COMBAT ACTIONS ---

func attack():
	is_attacking = true
	# Assuming you have an AnimationPlayer. Make sure "Attack" exists!
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("Attack")
		await $AnimationPlayer.animation_finished
		is_attacking = false
		$AnimationPlayer.play("Idle")

func unlock_sword_memory():
	has_sword_memory = true
	print("MEMORY UNLOCKED: I remember how to fight...")
	# Optional: Add a sound effect here

# --- DAMAGE LOGIC ---

# Accept amount AND enemy position for knockback
func take_damage(amount, enemy_pos = Vector2.ZERO):
	if is_hurt: return # Invincibility frame (can't get hit twice instantly)
	
	current_health -= amount
	print("Player Health: ", current_health)
	
	# Update the UI!
	if game_ui:
		game_ui.update_hearts(current_health)
		
	if current_health <= 0:
		die()
	else:
		apply_knockback(enemy_pos)

func apply_knockback(enemy_pos):
	is_hurt = true
	is_attacking = false # Cancel any active attack
	
	# 1. Turn Red
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 0, 0)
	
	# 2. Push away from enemy
	# If enemy is to my Right, push Left.
	var direction_away = (global_position.x - enemy_pos.x)
	
	if direction_away > 0:
		velocity.x = knockback_force # Fly Right
	else:
		velocity.x = -knockback_force # Fly Left
	
	velocity.y = -200 # Little hop up
	
	# 3. Wait 0.4 seconds
	await get_tree().create_timer(0.4).timeout
	
	# 4. Reset
	is_hurt = false
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 1) # Back to normal color

func die():
	print("I remember... A sweet bliss.")
	get_tree().reload_current_scene()


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1) # Kill the skeleton!
