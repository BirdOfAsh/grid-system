extends Node2D

@export var gridScale : float
@export var itemParent : Node2D

@onready var itemScene = preload("res://Scenes/item.tscn")

var gridPositionList: Array[Vector2] = []
var gridBoundriesList: Array[Vector2] = []
var itemPositionList: Array[Vector2] = []
var itemBoundriesList: Array[Vector2] = []
var inventory: Array[String] = []
var follow: bool = false
var index: int
var pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			for c in child.get_children():
				#sets all of the grids to the export scale variable
				if c is CollisionShape2D:
					c.scale.x = gridScale
					c.scale.y = gridScale
			#get the position of each grid and put it into a list to reference where to snap to
			gridPositionList.append(child.position)
			#set each inventory slot as "" to indicate a blank space
			inventory.append("")
	#calculates the borders for the grids and items that in immedietely present
	calculateBorderVector(gridPositionList,gridBoundriesList)
	calculateBorderVector(itemPositionList,itemBoundriesList)

#check every frame to see if an item should be following the mouse
func _process(_delta: float) -> void:
	followMouse(follow)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				#check to see if the mouse button has been pressed within the bounds of an item
				for i in range (0,itemBoundriesList.size()-1,2):
					if (isWithinBounds(itemBoundriesList,event,i)): 
						follow = true
						index = (i/2)
						pos = event.position
						setOverlayItemSprite(2)

			else:
				var tempIndex: int
				follow = false
				clearItemVectors()
				setOverlayItemSprite(0)
				#check to see if you released the mouse button while holding an item over a grid
				for i in range (0,gridBoundriesList.size()-1,2):
					if (isWithinBounds(gridBoundriesList,event,i) and (pos == event.position)):
						pos = gridPositionList[i/2]
						addItem(itemParent.get_child(index),(i/2))
						tempIndex = (i/2)
						break
				#if the item is already in the inventory but not being dragged into a grid, then snap the item back to its previous grid
				if itemParent.get_child(index) != null:
					for i in range(0,inventory.size()):
						if inventory[i] == itemParent.get_child(index).name:
							tempIndex = i
					itemParent.get_child(index).position = gridPositionList[tempIndex]
					clearItemVectors()

	#update the position continuously while holding the mouse down
	if event is InputEventMouseMotion:
		if follow == true:
			pos = event.position

func _on_item_parent_child_entered_tree(node: Node) -> void:
	#adds an item to the first available inventory slot
	for i in range (0,inventory.size()):
		if inventory[i] == "":
			node.scale.x = gridScale
			node.scale.y = gridScale
			addItem(node,i)
			break

#adds an item to the inventory and snaps it to that grid
func addItem(item,numIndex):
	if inventory[numIndex] == "":
		for i in range(0,inventory.size()):
			if item.name == inventory[i]:
				inventory[i] = ""
		inventory[numIndex] = item.name
		snapToGrid(item,numIndex)
	else:
		for i in range(0,inventory.size()):
			if item.name == inventory[i]:
				itemParent.get_child(index).position = gridPositionList[i]
				clearItemVectors()

#this fuction checks if the follow variable is true and sets the items position to the mouse if true
func followMouse(isTrue):
	if isTrue:
		itemParent.get_child(index).position = pos

#this function snaps an items position to the position of it's grid
func snapToGrid(item,numIndex):
	item.position = gridPositionList[numIndex]
	clearItemVectors()

#this function returns true or false if a specific item is in the inventory
func isInInventory(item):
	for i in range (0,inventory.size()):
		if item.name == inventory[i]:
			return true
	return false

func isWithinBounds(list,event,i):
	if (event.position.x > list[i].x and event.position.y > list[i].y) and (event.position.x < list[i+1].x and event.position.y < list[i+1].y):
		return true
	else:
		return false

#instantiates an item into itemParent as a child
func createItem():
	itemParent.add_child(itemScene.instantiate())

func setOverlayItemSprite(layer):
	itemParent.get_child(index).z_index = layer

#this function clears the lists for the item position and boundries and recalculates them again
func clearItemVectors():
	itemPositionList.clear()
	itemBoundriesList.clear()
	for item in itemParent.get_children():
		if item is Area2D:
			itemPositionList.append(item.position)
	calculateBorderVector(itemPositionList,itemBoundriesList)

#this function calculates the upper and lower bounds of each Area2D and appends them to their respective lists
func calculateBorderVector(positionList,boundryList):
	var scaleFactor = gridScale * 10
	var lowerBoundry: Vector2
	var upperBoundry: Vector2
	#testing purposes
	for itemPos in positionList:
		lowerBoundry = Vector2(itemPos.x - (scaleFactor), itemPos.y - (scaleFactor))
		upperBoundry = Vector2(itemPos.x + (scaleFactor), itemPos.y + (scaleFactor))
		boundryList.append(lowerBoundry)
		boundryList.append(upperBoundry)
