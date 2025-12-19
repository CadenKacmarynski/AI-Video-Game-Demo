class_name MovingPlatform
extends AnimatableBody3D
## Platform that moves between two points.

@export var move_offset: Vector3 = Vector3(0, 5, 0)
@export var move_duration: float = 2.0
@export var pause_duration: float = 0.5

var _start_pos: Vector3
var _end_pos: Vector3


func _ready() -> void:
	_start_pos = global_position
	_end_pos = _start_pos + move_offset
	_start_movement()


func _start_movement() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "global_position", _end_pos, move_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(pause_duration)
	tween.tween_property(self, "global_position", _start_pos, move_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(pause_duration)
