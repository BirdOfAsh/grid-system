extends Node2D

@export var itemParent : Node2D
@export var gridScale : float
@export var gridsPerRow: int
@export var numOfRows: int

@onready var itemScene = preload("res://Scenes/item.tscn")
@onready var gridScene = preload("res://Scenes/grid.tscn")

var gridPositionList: Array[Vector2] = []
var gridBoundriesList: Array[Vector2] = []
var itemPositionList: Array[Vector2] = []
var itemBoundriesList: Array[Vector2] = []
var inventory: Array[String] = []
var follow: bool = false
var index: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calculateGridLayout()
	#sets all of the grids to the export scale variable
	for child in get_children():
		if child is InventoryGrid:
			child.scale.x = gridScale
			child.scale.y = gridScale
			#gets the position of each grid and puts it into a list to reference where to snap to
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#check to see if the mouse button has been pressed within the bounds of an item
			for i in range (0,itemBoundriesList.size()-1,2):
				if (isWithinBounds(itemBoundriesList,event,i)): 
					follow = true
					@warning_ignore("integer_division") index = (i/2)
					setOverlayItemSprite(2)

		else:
			var tempIndex: float
			#check to see if you released the mouse button while holding an item over a grid
			if follow:
				follow = false
				setOverlayItemSprite(0)
				for i in range (0,gridBoundriesList.size()-1,2):
					if (isWithinBounds(gridBoundriesList,event,i)):
						addItem(itemParent.get_child(index),(float(i)/2))
						#tempIndex = (float(i)/2) keep for later to make swap mechanic - where the item wants to go
						break
				#if the item is already in the inventory but not being dragged into a grid, then snap the item back to its previous grid
				if itemParent.get_child(index) != null:
					for i in range(0,inventory.size()):
						if inventory[i] == itemParent.get_child(index).name:
							tempIndex = i # use for swap mechanic later - where the item actually goes back to
					itemParent.get_child(index).position = gridPositionList[tempIndex]
					clearItemVectors()


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
	if item != null:
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
		itemParent.get_child(index).position = get_local_mouse_position()


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


func createInventoryGrid():
	self.add_child(gridScene.instantiate())


func setOverlayItemSprite(layer):
	if itemParent.get_child(index):
		itemParent.get_child(index).z_index = layer


#this function clears the lists for the item position and boundries and recalculates them again
func clearItemVectors():
	itemPositionList.clear()
	itemBoundriesList.clear()
	for item in itemParent.get_children():
		if item is Item:
			itemPositionList.append(item.position)
	calculateBorderVector(itemPositionList,itemBoundriesList)


#this function calculates the upper and lower bounds of each Area2D and appends them to their respective lists
func calculateBorderVector(positionList,boundryList):
	var scaleFactor = gridScale * 10
	var lowerBoundry: Vector2
	var upperBoundry: Vector2
	for itemPos in positionList:
		lowerBoundry = Vector2(itemPos.x - (scaleFactor), itemPos.y - (scaleFactor))
		upperBoundry = Vector2(itemPos.x + (scaleFactor), itemPos.y + (scaleFactor))
		boundryList.append(lowerBoundry)
		boundryList.append(upperBoundry)


func calculateGridLayout():
	var gridSpacingX = get_viewport().size.x / gridsPerRow
	var gridSpacingY = get_viewport().size.y / numOfRows
	var tempPosY: int = -gridSpacingY / 2
	var gridIndex: int = 1
	for i in range(0,numOfRows):
		var tempPosX: int = -gridSpacingX / 2
		tempPosY += gridSpacingY
		for j in range(0,gridsPerRow):
			tempPosX += gridSpacingX
			createInventoryGrid()
			get_child(gridIndex).position = Vector2(tempPosX,tempPosY)
			gridIndex+=1
