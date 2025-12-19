class_name EmoteWheel
extends Control
## Radial emote selection wheel - opens with B key.

signal emote_selected(emote_id: String)

# Emote data: [id, display_name]
var _emotes: Array[Array] = [
	["Wave", "Wave"],
	["SwingDance", "Swing Dance"],
	["YMCA", "YMCA"],
	["Salsa", "Salsa"],
	["HipHop", "Hip Hop"],
	["Flair", "Flair"],
	["Arrow", "Arrow"],
	["PunchingBag", "Punching Bag"],
	["Dribble", "Dribble"],
]

var _selected_index: int = -1
var _is_open: bool = false

@onready var background: ColorRect = $Background
@onready var center_label: Label = $CenterLabel
@onready var segments_container: Control = $Segments


func _ready() -> void:
	visible = false
	_create_segments()


func _create_segments() -> void:
	var segment_count: int = _emotes.size()
	var angle_step: float = TAU / segment_count
	var radius: float = 120.0
	var center: Vector2 = size / 2
	
	for i in range(segment_count):
		var angle: float = angle_step * i - PI / 2  # Start from top
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
		
		var label: Label = Label.new()
		label.text = _emotes[i][1]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.position = pos - Vector2(50, 12)
		label.custom_minimum_size = Vector2(100, 24)
		label.name = "Segment" + str(i)
		label.add_theme_font_size_override("font_size", 14)
		segments_container.add_child(label)


func open() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	_selected_index = -1
	center_label.text = "Select Emote"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Center wheel on screen
	global_position = get_viewport().get_visible_rect().size / 2 - size / 2


func close(trigger_emote: bool = true) -> void:
	if not _is_open:
		return
	_is_open = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if trigger_emote and _selected_index >= 0 and _selected_index < _emotes.size():
		emote_selected.emit(_emotes[_selected_index][0])


func _process(_delta: float) -> void:
	if not _is_open:
		return
	
	var mouse_pos: Vector2 = get_local_mouse_position()
	var center: Vector2 = size / 2
	var direction: Vector2 = mouse_pos - center
	var distance: float = direction.length()
	
	# Only select if mouse is far enough from center
	if distance > 40.0:
		var angle: float = direction.angle() + PI / 2  # Adjust for top start
		if angle < 0:
			angle += TAU
		
		var segment_count: int = _emotes.size()
		var angle_step: float = TAU / segment_count
		_selected_index = int(angle / angle_step) % segment_count
		
		center_label.text = _emotes[_selected_index][1]
		_update_highlights()
	else:
		_selected_index = -1
		center_label.text = "Select Emote"
		_update_highlights()


func _update_highlights() -> void:
	for i in range(segments_container.get_child_count()):
		var label: Label = segments_container.get_child(i) as Label
		if label:
			if i == _selected_index:
				label.add_theme_color_override("font_color", Color.YELLOW)
			else:
				label.add_theme_color_override("font_color", Color.WHITE)


func _input(event: InputEvent) -> void:
	if not _is_open:
		return
	
	# Click to select
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			close(true)
