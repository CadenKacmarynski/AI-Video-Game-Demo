class_name Player
extends CharacterBody3D
## Player controller with full animation system.

# Movement parameters
@export_group("Movement")
@export var WALK_SPEED: float = 3.0
@export var CATWALK_SPEED: float = 1.5
@export var RUN_SPEED: float = 6.0
@export var JUMP_VELOCITY: float = 4.5
@export var GRAVITY: float = 9.8

# Character selection
@export_group("Character Skins")
@export var character_skins: Array[PackedScene] = []
@export var character_scales: Array[float] = [100.0]  # Per-character scale (match array order)
@export var current_skin_index: int = 0

# Animation offset fix
@export_group("Animation Fixes")
@export var idle_y_offset: float = 1.0
@export var action_y_offset: float = 1.0

# =====================
# ANIMATION SOURCES
# =====================

# Locomotion
@export_group("Locomotion Animations")
@export var anim_idle: PackedScene  # Happy Idle
@export var anim_walk: PackedScene  # Walking
@export var anim_catwalk: PackedScene  # Catwalk Walking
@export var anim_run: PackedScene  # Running
@export var anim_jump: PackedScene  # Jumping (from idle)
@export var anim_run_jump: PackedScene  # Running Jump
@export var anim_flip: PackedScene  # Running Forward Flip
@export var anim_backflip: PackedScene  # Backflip (Q)

# Actions (Combat)
@export_group("Action Animations")
@export var anim_punch: PackedScene  # Punching (F)
@export var anim_block: PackedScene  # Body Block (G)
@export var anim_dodge: PackedScene  # Dodging (V)
@export var anim_headbutt: PackedScene  # Headbutt (R)
@export var anim_boxing: PackedScene  # Boxing (Q)

# Emotes (B wheel + 1-9 direct)
@export_group("Emote Animations")
@export var anim_wave: PackedScene  # Waving (1)
@export var anim_swing_dance: PackedScene  # Swing Dancing (2)
@export var anim_ymca: PackedScene  # YMCA Dance (3)
@export var anim_salsa: PackedScene  # Salsa Dancing (4)
@export var anim_hip_hop: PackedScene  # Wave Hip Hop Dance (5)
@export var anim_flair: PackedScene  # Flair breakdance (6)
@export var anim_arrow: PackedScene  # Shooting Arrow (7)
@export var anim_punching_bag: PackedScene  # Punching Bag (8)
@export var anim_dribble: PackedScene  # Dribble (9)

# Animation name constants
const ANIM_IDLE: String = "Idle"
const ANIM_WALK: String = "Walk"
const ANIM_CATWALK: String = "Catwalk"
const ANIM_RUN: String = "Run"
const ANIM_JUMP: String = "Jump"
const ANIM_RUN_JUMP: String = "RunJump"
const ANIM_FLIP: String = "Flip"
const ANIM_BACKFLIP: String = "Backflip"
# Actions
const ANIM_PUNCH: String = "Punch"
const ANIM_BLOCK: String = "Block"
const ANIM_DODGE: String = "Dodge"
const ANIM_HEADBUTT: String = "Headbutt"
const ANIM_BOXING: String = "Boxing"
# Emotes
const ANIM_WAVE: String = "Wave"
const ANIM_SWING_DANCE: String = "SwingDance"
const ANIM_YMCA: String = "YMCA"
const ANIM_SALSA: String = "Salsa"
const ANIM_HIP_HOP: String = "HipHop"
const ANIM_FLAIR: String = "Flair"
const ANIM_ARROW: String = "Arrow"
const ANIM_PUNCHING_BAG: String = "PunchingBag"
const ANIM_DRIBBLE: String = "Dribble"

# Node references
var _animation_player: AnimationPlayer = null
var _current_character: Node3D = null
var _locked_xz: Vector2 = Vector2.ZERO
var _emote_wheel: EmoteWheel = null

# State
var _is_sprinting: bool = false
var _is_catwalking: bool = false
var _is_jumping: bool = false
var _playing_action: bool = false
var _emote_wheel_open: bool = false

# Lists for animation categorization
var _action_anims: Array[String] = [ANIM_PUNCH, ANIM_BLOCK, ANIM_DODGE, ANIM_HEADBUTT, ANIM_BOXING, ANIM_BACKFLIP]
var _emote_anims: Array[String] = [ANIM_WAVE, ANIM_SWING_DANCE, ANIM_YMCA, ANIM_SALSA, ANIM_HIP_HOP, ANIM_FLAIR, ANIM_ARROW, ANIM_PUNCHING_BAG, ANIM_DRIBBLE]
var _jump_anims: Array[String] = [ANIM_JUMP, ANIM_RUN_JUMP, ANIM_FLIP]


func _ready() -> void:
	for child in get_children():
		if child is Node3D and child.name != "CollisionShape3D" and child.name != "CameraPivot":
			_current_character = child
			break
	
	if _current_character:
		_locked_xz = Vector2(_current_character.position.x, _current_character.position.z)
		_animation_player = _find_animation_player(_current_character)
		if _animation_player:
			print("[Player] Using character: ", _current_character.name)
			_import_all_animations()
			print("[Player] Loaded animations: ", _animation_player.get_animation_list())
			_animation_player.play(ANIM_IDLE)
			_apply_y_offset(ANIM_IDLE)
			_animation_player.animation_finished.connect(_on_animation_finished)
		else:
			print("[Player] Warning: No AnimationPlayer found")
	else:
		_load_character(current_skin_index)
	
	# Setup emote wheel
	_setup_emote_wheel()


func _setup_emote_wheel() -> void:
	var wheel_scene: PackedScene = preload("res://scenes/ui/emote_wheel.tscn")
	_emote_wheel = wheel_scene.instantiate()
	
	# Add to CanvasLayer so it's always on top
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "EmoteWheelLayer"
	add_child(canvas)
	canvas.add_child(_emote_wheel)
	
	_emote_wheel.emote_selected.connect(_on_emote_wheel_selected)


func _on_emote_wheel_selected(emote_id: String) -> void:
	_emote_wheel_open = false
	_play_action(emote_id)


func _load_character(index: int) -> void:
	# Disconnect old signal if exists
	if _animation_player and _animation_player.animation_finished.is_connected(_on_animation_finished):
		_animation_player.animation_finished.disconnect(_on_animation_finished)
	
	if _current_character:
		_current_character.queue_free()
		_current_character = null
		_animation_player = null
	
	if character_skins.size() > 0 and index < character_skins.size():
		var skin_scene: PackedScene = character_skins[index]
		if skin_scene:
			_current_character = skin_scene.instantiate()
			_current_character.name = "CharacterModel"
			# Use per-character scale if available, otherwise default to 100
			var scale_value: float = character_scales[index] if index < character_scales.size() else 100.0
			_current_character.scale = Vector3(scale_value, scale_value, scale_value)
			add_child(_current_character)
			
			_locked_xz = Vector2(_current_character.position.x, _current_character.position.z)
			_animation_player = _find_animation_player(_current_character)
			
			if _animation_player:
				print("[Player] Loaded character: ", index)
				_import_all_animations()
				print("[Player] Animations: ", _animation_player.get_animation_list())
				_animation_player.play(ANIM_IDLE)
				_apply_y_offset(ANIM_IDLE)
				_animation_player.animation_finished.connect(_on_animation_finished)
			else:
				print("[Player] Warning: No AnimationPlayer in character ", index)


func _import_all_animations() -> void:
	# Locomotion
	_import_anim(anim_idle, ANIM_IDLE)
	_import_anim(anim_walk, ANIM_WALK)
	_import_anim(anim_catwalk, ANIM_CATWALK)
	_import_anim(anim_run, ANIM_RUN)
	_import_anim(anim_jump, ANIM_JUMP)
	_import_anim(anim_run_jump, ANIM_RUN_JUMP)
	_import_anim(anim_flip, ANIM_FLIP)
	_import_anim(anim_backflip, ANIM_BACKFLIP)
	# Actions
	_import_anim(anim_punch, ANIM_PUNCH)
	_import_anim(anim_block, ANIM_BLOCK)
	_import_anim(anim_dodge, ANIM_DODGE)
	_import_anim(anim_headbutt, ANIM_HEADBUTT)
	_import_anim(anim_boxing, ANIM_BOXING)
	# Emotes
	_import_anim(anim_wave, ANIM_WAVE)
	_import_anim(anim_swing_dance, ANIM_SWING_DANCE)
	_import_anim(anim_ymca, ANIM_YMCA)
	_import_anim(anim_salsa, ANIM_SALSA)
	_import_anim(anim_hip_hop, ANIM_HIP_HOP)
	_import_anim(anim_flair, ANIM_FLAIR)
	_import_anim(anim_arrow, ANIM_ARROW)
	_import_anim(anim_punching_bag, ANIM_PUNCHING_BAG)
	_import_anim(anim_dribble, ANIM_DRIBBLE)


func _import_anim(scene: PackedScene, anim_name: String) -> void:
	if not scene or not _animation_player:
		return
	
	var temp: Node = scene.instantiate()
	var src_player: AnimationPlayer = _find_animation_player(temp)
	
	if src_player:
		for src_name in src_player.get_animation_list():
			var anim: Animation = src_player.get_animation(src_name)
			if anim:
				var cleaned: Animation = anim.duplicate()
				_strip_root_motion(cleaned)
				
				var lib: AnimationLibrary
				if _animation_player.has_animation_library(""):
					lib = _animation_player.get_animation_library("")
				else:
					lib = AnimationLibrary.new()
					_animation_player.add_animation_library("", lib)
				
				if not lib.has_animation(anim_name):
					lib.add_animation(anim_name, cleaned)
	
	temp.queue_free()


func _strip_root_motion(anim: Animation) -> void:
	for i in range(anim.get_track_count() - 1, -1, -1):
		var path: String = String(anim.track_get_path(i))
		if anim.track_get_type(i) == Animation.TYPE_POSITION_3D:
			if "Hips" in path or "mixamorig" in path.get_slice(":", 0):
				anim.remove_track(i)


func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found: AnimationPlayer = _find_animation_player(child)
		if found:
			return found
	return null


func _on_animation_finished(anim_name: String) -> void:
	if anim_name in _action_anims or anim_name in _emote_anims or anim_name in _jump_anims:
		_playing_action = false
		_is_jumping = false


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	move_and_slide()
	_update_animation()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif _is_jumping:
		_is_jumping = false
		_playing_action = false


func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not _is_jumping:
		velocity.y = JUMP_VELOCITY
		_is_jumping = true
		_playing_action = true
		
		var is_moving: bool = Vector2(velocity.x, velocity.z).length() > 0.1
		if _is_sprinting and is_moving and _animation_player.has_animation(ANIM_RUN_JUMP):
			# Running + Space = Running Jump
			_play_anim(ANIM_RUN_JUMP)
		elif _animation_player.has_animation(ANIM_JUMP):
			_play_anim(ANIM_JUMP)
		else:
			_play_anim(ANIM_IDLE)


func _handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	_is_sprinting = Input.is_key_pressed(KEY_SHIFT)
	_is_catwalking = Input.is_key_pressed(KEY_CTRL)
	
	var speed: float = WALK_SPEED
	if _is_sprinting:
		speed = RUN_SPEED
	elif _is_catwalking:
		speed = CATWALK_SPEED
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if _current_character:
			var target_angle: float = atan2(direction.x, direction.z)
			_current_character.rotation.y = lerp_angle(_current_character.rotation.y, target_angle, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


func _update_animation() -> void:
	if not _animation_player:
		return
	
	# Lock XZ position
	if _current_character:
		_current_character.position.x = _locked_xz.x
		_current_character.position.z = _locked_xz.y
	
	# Don't interrupt actions/emotes/jumps
	if _playing_action:
		return
	
	var is_moving: bool = Vector2(velocity.x, velocity.z).length() > 0.1
	var target: String = ANIM_IDLE
	
	if is_moving:
		if _is_sprinting:
			target = ANIM_RUN
		elif _is_catwalking:
			target = ANIM_CATWALK
		else:
			target = ANIM_WALK
	
	if _animation_player.has_animation(target) and _animation_player.current_animation != target:
		_animation_player.play(target)
		_apply_y_offset(target)


func _apply_y_offset(anim_name: String) -> void:
	if not _current_character:
		return
	_current_character.position.y = idle_y_offset if anim_name == ANIM_IDLE else action_y_offset


func _play_anim(anim_name: String) -> void:
	if _animation_player and _animation_player.has_animation(anim_name):
		_animation_player.play(anim_name)
		_apply_y_offset(anim_name)


func _play_action(anim_name: String) -> void:
	if _is_jumping:
		return
	# Cancel current action/emote and start new one
	_playing_action = true
	_play_anim(anim_name)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	# Emote wheel: B to open, release to close and trigger
	if event.keycode == KEY_B:
		if event.pressed and not _emote_wheel_open:
			_emote_wheel_open = true
			if _emote_wheel:
				_emote_wheel.open()
		elif not event.pressed and _emote_wheel_open:
			_emote_wheel_open = false
			if _emote_wheel:
				_emote_wheel.close(true)
		return
	
	# Skip other keys if wheel is open or key not pressed
	if _emote_wheel_open or not event.pressed:
		return
	
	match event.keycode:
		# Actions (Combat)
		KEY_Q:
			_play_action(ANIM_BACKFLIP)
		KEY_F:
			_play_action(ANIM_PUNCH)
		KEY_G:
			_play_action(ANIM_BOXING)
		KEY_H:
			_play_action(ANIM_BLOCK)
		KEY_V:
			_play_action(ANIM_DODGE)
		KEY_R:
			_play_action(ANIM_HEADBUTT)
		KEY_E:
			_play_action(ANIM_FLIP)
		# Emotes (direct keys 1-9)
		KEY_1:
			_play_action(ANIM_WAVE)
		KEY_2:
			_play_action(ANIM_SWING_DANCE)
		KEY_3:
			_play_action(ANIM_YMCA)
		KEY_4:
			_play_action(ANIM_SALSA)
		KEY_5:
			_play_action(ANIM_HIP_HOP)
		KEY_6:
			_play_action(ANIM_FLAIR)
		KEY_7:
			_play_action(ANIM_ARROW)
		KEY_8:
			_play_action(ANIM_PUNCHING_BAG)
		KEY_9:
			_play_action(ANIM_DRIBBLE)
		# Character switch
		KEY_TAB:
			next_character()


func switch_character(index: int) -> void:
	if index >= 0 and index < character_skins.size():
		current_skin_index = index
		_load_character(index)


func next_character() -> void:
	var next_index: int = (current_skin_index + 1) % max(character_skins.size(), 1)
	switch_character(next_index)
