extends Node2D

@onready var itemScene = preload("res://Scenes/item.tscn")
@onready var sprite1 = preload("res://Item1.png")
@onready var sprite2 = preload("res://Item2.png")
@onready var sprite3 = preload("res://Item3.png")

var spriteList: Array = []
var itemTexture


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spriteList.append(sprite1)
	spriteList.append(sprite2)
	spriteList.append(sprite3)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CreateItem"):
		createItem()

func createItem():
	add_child(itemScene.instantiate())


func _on_child_entered_tree(node: Node) -> void:
	itemTexture = spriteList[randi_range(0,spriteList.size())-1]
	node.setTexture(itemTexture)
