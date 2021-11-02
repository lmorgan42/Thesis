extends Node

const BlockResource = preload("res://Block.tscn")
const BlockSize = 50

var GM
var origin = Vector2(0,0)
var playOrigin : Vector2
var nimoDesc
var blocks = []
var ghostMode = false

func init(GM, playOrigin : Vector2, nimoDesc):
	self.GM = GM
	self.playOrigin = playOrigin
	self.nimoDesc = nimoDesc
	createBlocks()

func createBlocks():
	#determine middle
	var midOffset = int(-(len(nimoDesc[0])/2)) + 4
	#create and place blocks
	var x = midOffset
	var y = 0
	for i in nimoDesc:
		for k in i:
			if k == 1:
				var block = BlockResource.instance()
				block.init(playOrigin, GM.getBlockLetters(1))
				block.setBlockPosition(x,y)
				add_child(block)
				blocks.append(block)
			x += 1
		x = midOffset
		y += 1

func move(x, y):
	return moveV(Vector2(x, y))

func moveV(offset):
	for block in blocks:
		if checkCollide(block.coords + offset):
			return false
	for block in blocks:
		#collision check
		block.move(offset)
	return true
#TODO add another timer that activates when collisoin occurs that allows block to slide around until person stops pressing buttons
func checkCollide(coords):
	if coords.x > 9 or coords.x < 0 or coords.y > 19 or coords.y < 0:
		return true
	return self.GM.superNimo.checkCollision(coords)

func rotate(direction):
	#rotation: 1 = clockwise, -1 = counterclockwise
	#determin pivot point (favour lower and right side)
	#determin min and max coords (create bounding box)
	var minCoord = Vector2(9,19)
	var maxCoord = Vector2(0,0)
	for block in blocks:
		if block.coords.x > maxCoord.x:
			maxCoord.x = block.coords.x
		if block.coords.x < minCoord.x:
			minCoord.x = block.coords.x
		if block.coords.y > maxCoord.y:
			maxCoord.y = block.coords.y
		if block.coords.y < minCoord.y:
			minCoord.y = block.coords.y
	#find middle of bounding box
	#TODO add support for 0.5,0.5 coordinates
	var pivotPoint = Vector2(0,0)
	var width = maxCoord.x - minCoord.x + 1
	pivotPoint.x = width - round(width/2.0) + minCoord.x
	width = maxCoord.y - minCoord.y + 1
	pivotPoint.y = width - round(width/2.0) + minCoord.y
	#for each block, transpose around that point
	var proposedTranspose = {}
	for block in blocks:
		var adjustedCoords = (block.coords - pivotPoint)
		var newLoc = Vector2(0,0)
		if direction == 1:
			newLoc.x = -adjustedCoords.y
			newLoc.y = adjustedCoords.x
		else:
			newLoc.y = -adjustedCoords.x
			newLoc.x = adjustedCoords.y
		newLoc += pivotPoint
		if checkCollide(newLoc):
			return false
		proposedTranspose[block.coords] = newLoc
	#now apply roation if no blocks collide
	for block in blocks:
		block.setBlockPositionV(proposedTranspose[block.coords])
		
func slamdown():
	while move(0,1):
		pass

func enableGhostMode(parentNimo):
	ghostMode = true
	for i in range(len(blocks)):
		blocks[i].letter = parentNimo.blocks[i].letter
		blocks[i].enableGhostMode()
		
func updateGhostPosition(parentNimo):
	for i in range(len(blocks)):
		blocks[i].setBlockPositionV(parentNimo.blocks[i].coords)
	slamdown()

func submitToSuperNimo():
	for block in blocks:
		remove_child(block)
		self.GM.superNimo.addBlock(block)

func deleteBlocks():
	for block in blocks:
		remove_child(block)
