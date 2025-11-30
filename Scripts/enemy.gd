extends CharacterBody2D

@export var speed: int = 60
@export var max_health: int = 3
@export var direction: int = 1 
@export var patrol_distance: int = 200
@export var knockback_force: int = 150

var current_health: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dying = false
var start_x = 0.0

enum {WALK, ATTACK, HURT, DIE, IDLE_WAIT}
var state = WALK

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var detection_area = $DetectionArea 
@onready var body_collision = $BodyCollision
@onready var attack_area = $AttackArea

# Store the original position of the sword so we know where to flip it to
@onready var default_attack_x = attack_area.position.x

func _ready():
	current_health = max_health
	start_x = position.x
	anim_player.play("Walk")

# --- VISUALS ONLY ---
func _process(_delta):
	if is_dying: return
	
	# We flip the SPRITE, not the BODY. This saves the physics.
	if direction == 1:
		sprite.scale.x = 1
		attack_area.position.x = default_attack_x
		attack_area.scale.x = 1 # Keep sword facing right
	elif direction == -1:
		sprite.scale.x = -1
		attack_area.position.x = -default_attack_x
		attack_area.scale.x = -1 # Flip sword to face left

# --- PHYSICS ---
func _physics_process(delta):
	if is_dying: return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		WALK:
			move_logic()
			check_for_player()
		ATTACK, IDLE_WAIT:
			velocity.x = 0
		HURT:
			velocity.x = move_toward(velocity.x, 0, speed * delta)
	
	move_and_slide()

func move_logic():
	velocity.x = direction * speed
	
	# Patrol Logic
	if (position.x > start_x + patrol_distance and direction == 1) or \
	   (position.x < start_x - patrol_distance and direction == -1):
		start_idle_wait()
		
	# Wall Logic (Safe to use now!)
	if is_on_wall():
		start_idle_wait()

func start_idle_wait():
	state = IDLE_WAIT
	anim_player.play("Idle")
	
	await get_tree().create_timer(2.0).timeout
	
	if is_dying: return
	
	direction *= -1
	state = WALK
	anim_player.play("Walk")

# --- COMBAT ---

func check_for_player():
	var bodies = detection_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player") or body.name == "Player":
			start_attack(body)
			return 

func start_attack(target):
	state = ATTACK
	
	# Determine direction
	var dir_to_player = target.global_position.x - global_position.x
	direction = 1 if dir_to_player > 0 else -1
	
	anim_player.play("Attack 1" if randi() % 2 == 0 else "Attack 2")
	await anim_player.animation_finished
	
	if is_dying: return
	state = WALK
	anim_player.play("Walk")

func take_damage(amount, source_pos = Vector2.ZERO):
	if is_dying or state == DIE: return
	
	current_health -= amount
	
	if current_health <= 0:
		start_death_sequence()
	else:
		state = HURT
		if anim_player.has_animation("Hurt"):
			anim_player.play("Hurt")
		
		sprite.modulate = Color(1, 0.3, 0.3)
		
		if source_pos != Vector2.ZERO and not is_on_wall():
			var knock_dir = 1 if (global_position.x - source_pos.x) > 0 else -1
			velocity.x = knock_dir * knockback_force
			velocity.y = -100 
		
		await get_tree().create_timer(0.4).timeout
		
		sprite.modulate = Color.WHITE
		if not is_dying:
			state = WALK
			anim_player.play("Walk")

func start_death_sequence():
	is_dying = true
	state = DIE
	sprite.modulate = Color.WHITE
	anim_player.stop()
	anim_player.play("Die")
	
	if has_node("DetectionArea"): $DetectionArea.set_deferred("monitoring", false)
	if has_node("AttackArea"): $AttackArea.set_deferred("monitoring", false)
	if has_node("HurtBox"): $HurtBox/CollisionShape2D.set_deferred("disabled", true)
	body_collision.set_deferred("disabled", true)
	
	await anim_player.animation_finished
	await get_tree().create_timer(2.0).timeout
	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
# Check if the body that entered is the Player
	if body.name == "Player" or body.is_in_group("player"):
		# Check if the player has the 'take_damage' function we just wrote
		if body.has_method("take_damage"):
			body.take_damage(1) # Deal 1 damage
