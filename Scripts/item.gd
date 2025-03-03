extends Area2D
class_name Item

@export var spriteTexture: Texture

@onready var itemSprite: Sprite2D = $CollisionShape2D/ItemSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	itemSprite.texture = spriteTexture


func setTexture(texture: Texture):
	spriteTexture = texture
