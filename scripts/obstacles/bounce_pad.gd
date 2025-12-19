class_name BouncePad
extends Area3D
## Bounce pad that launches the player upward.

@export var bounce_force: float = 15.0
@export var bounce_color: Color = Color(1.0, 0.3, 0.3, 1.0)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Set material color on CSG or MeshInstance3D
	for child in get_children():
		if child is CSGShape3D:
			var mat: StandardMaterial3D = StandardMaterial3D.new()
			mat.albedo_color = bounce_color
			child.material = mat
			break
		elif child is MeshInstance3D:
			var mat: StandardMaterial3D = StandardMaterial3D.new()
			mat.albedo_color = bounce_color
			child.material_override = mat
			break


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.velocity.y = bounce_force
		_play_bounce_effect()


func _play_bounce_effect() -> void:
	# Quick scale animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 0.5, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.2)
