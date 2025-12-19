class_name RotatingObstacle
extends Node3D
## Rotating obstacle (hammer, wipeout balls) that can knock the player.

@export var rotation_speed: float = 1.0  # Radians per second
@export var rotation_axis: Vector3 = Vector3.UP
@export var knockback_force: float = 8.0


func _ready() -> void:
	# Connect all Area3D children
	for child in get_children():
		if child is Area3D:
			child.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	rotate(rotation_axis.normalized(), rotation_speed * delta)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Calculate knockback direction from center
		var direction: Vector3 = (body.global_position - global_position).normalized()
		direction.y = 0.3  # Add upward component
		body.velocity = direction * knockback_force
