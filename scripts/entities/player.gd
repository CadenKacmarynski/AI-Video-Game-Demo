class_name Player
extends CharacterBody3D
## Player controller with exposed parameters for live editing.
## Phase 1: Foundation - WASD movement with animation hooks.

# Movement parameters exposed for Phase 2 live editing
@export var SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var GRAVITY: float = 9.8

# Node references (safe - may be null)
@onready var _animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	move_and_slide()
	_update_animation()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func _handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func _update_animation() -> void:
	# Safe animation hook - won't crash if AnimationPlayer is missing
	if _animation_player == null:
		return
	
	var is_moving: bool = Vector2(velocity.x, velocity.z).length() > 0.1
	var target_anim: String = "Run" if is_moving else "Idle"
	
	# Only change animation if it exists and isn't already playing
	if _animation_player.has_animation(target_anim):
		if _animation_player.current_animation != target_anim:
			_animation_player.play(target_anim)
