extends Area2D

@export var sprite: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			for c in child.get_children():
				if c is Sprite2D:
					c.texture = sprite
