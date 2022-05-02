extends Node

var boardStatePre = preload("res://BoardState.tscn")

var GameManager
var highestPoints = []
var blocks = []
var blockBottom = []
var potentialBoards = []
var movementTracker = 0
var running = false

func init(GameManager):
	running = true
	self.GameManager = GameManager
	solveForMove()

func solveForMove():
	getBlocks()
	#checkLowestPoint()
	generatePotentialBoards()
	findHighestPointOnBoards()
	resolveMovement(chooseBoard())

func getBlocks():
	blocks = []
	for block in GameManager.curNimo.blocks:
		blocks.append(block.coords)

func checkForXInBlocks(xValue):
	for coord in blocks:
		if coord.x == xValue: return true
	return false

func generatePotentialBoards():
	#create block rep to work with
	var nimoRef = []
	for block in blocks:
		nimoRef.append(Vector2(block.x, block.y))
	var nimoWidth = 1
	
	#loop through possible rotations
	for i in range(4):
		#push nimoRef to far left an calculate width
		var leftmost = 20
		var rightmost = 0
		for block in nimoRef:
			if block.x < leftmost: leftmost = block.x
			if block.x > rightmost: rightmost = block.x
		for k in range(len(nimoRef)):
			nimoRef[k].x -= leftmost
		#print(nimoRef)
		nimoWidth = rightmost - leftmost + 1
		
		#loop through possible positions
		for j in range(10 - nimoWidth + 1):
			#create nimo from ref to simulate dropping
			var nimo = []
			for block in nimoRef:
				nimo.append(Vector2(block.x, block.y))
			while not collisionCheckNimo(nimo):
				for k in range(len(nimo)):
					nimo[k].y += 1
			#create copy of super nimo
			var bState = []
			for elem in GameManager.superNimo.blocks:
				var temp = []
				for subElem in elem:
					if subElem != null: temp.append(1)
					else: temp.append(0)
				bState.append(temp)
			#and add dropped nimo to it
			for block in nimo:
				bState[block.x][block.y] = 1
			#make new board state
			var temp = boardStatePre.instance()
			temp.init(j, i, 0, bState)
			potentialBoards.append(temp)
			add_child(temp)
			#shift nimo over one
			for k in range(len(nimoRef)):
				nimoRef[k].x += 1
		
		#rotate nimoRef
		#determin pivot point (favour lower and right side)
		#determin min and max coords (create bounding box)
		var minCoord = Vector2(9,19)
		var maxCoord = Vector2(0,0)
		for block in nimoRef:
			if block.x > maxCoord.x:
				maxCoord.x = block.x
			if block.x < minCoord.x:
				minCoord.x = block.x
			if block.y > maxCoord.y:
				maxCoord.y = block.y
			if block.y < minCoord.y:
				minCoord.y = block.y
		#find middle of bounding box
		#TODO add support for 0.5,0.5 coordinates
		var pivotPoint = Vector2(0,0)
		var width = maxCoord.x - minCoord.x + 1
		pivotPoint.x = width - round(width/2.0) + minCoord.x
		width = maxCoord.y - minCoord.y + 1
		pivotPoint.y = width - round(width/2.0) + minCoord.y
		#for each block, transpose around that point
		for k in range(len(nimoRef)):
			var adjustedCoords = (nimoRef[k] - pivotPoint)
			var newLoc = Vector2(0,0)
			newLoc.x = -adjustedCoords.y
			newLoc.y = adjustedCoords.x
			newLoc += pivotPoint
			nimoRef[k] = newLoc

func findHighestPointOnBoards():
	for board in potentialBoards:
		var highest = 0
		var hitOne = false
		for y in range(len(board.state[0])):
			for x in range(len(board.state)):
				if board.state[x][y] == 1: 
					hitOne = true
					break
			if not hitOne: highest = y
			else: break
		board.highestPoint = highest
		#print(board.toString())
			
func collisionCheckNimo(nimo):
	for block in nimo:
		if block.y == 19: return true
		if GameManager.superNimo.checkCollision(Vector2(block.x, block.y + 1)): return true
	return false

func chooseBoard():
	var chosen = 0
	var bestHighest = 0
	for i in range(len(potentialBoards)):
		if potentialBoards[i].highestPoint > bestHighest:
			bestHighest = potentialBoards[i].highestPoint
			chosen = i
	#print("----------------- Chosen -----------------")
	#print(potentialBoards[chosen].toString())
	return chosen

func generateBlockBottom():
	blockBottom = []
	#find range of x values
	var lowestX = 9
	var highestX = 0
	for coord in blocks:
		if coord.x < lowestX: lowestX = coord.x
		if coord.x > highestX: highestX = coord.x
	#use the info to prepare for movement and coord translation
	movementTracker = -1 * lowestX
	for i in range(highestX - lowestX + 1):
		blockBottom.append(0)
	#find lowest block for each x value
	for coord in blocks:
		var adjusted = lowestX - coord.x 
		if coord.y > blockBottom[adjusted]: blockBottom[adjusted] = coord.y

func checkLowestPoint():
	#fill out highestPoints
	highestPoints = []
	for i in range(10):
		var curHeight = 0
		while not GameManager.superNimo.checkCollision(Vector2(i,curHeight)):
			curHeight += 1
			if curHeight > 19:
				curHeight = 20
				break
		highestPoints.append(curHeight - 1)
	generateBlockBottom()
	#find furthest down block could move in each position and save best
	var leftXPos = 0
	var bestDistance = 0
	for i in range(10 - len(blockBottom) + 1):
		var bestSubDistance = 20
		for j in range(len(blockBottom)):
			var distance = highestPoints[i + j] - blockBottom[j]
			#print("distance: " + str(distance))
			if distance < bestSubDistance: bestSubDistance = distance
		if bestSubDistance > bestDistance: 
			bestDistance = bestSubDistance
			leftXPos = i
	movementTracker += leftXPos

func resolveMovement(boardIndex):
	var board = potentialBoards[boardIndex]
	get_parent().placeBlock(board.position, board.rotation, 0)
#	for i in range(board.rotation):
#		get_parent().addCommand("rotate_block_clockwise")
#	for i in range(6):
#		get_parent().addCommand("move_block_left")
#	for i in range(board.position):
#		get_parent().addCommand("move_block_right")
#	get_parent().addCommand("slam_down")
	for lilboard in potentialBoards:
		lilboard.queue_free()
	potentialBoards.clear()
#	get_parent().start()


func _on_AIInputManager_finished():
	if not running: return
	solveForMove()
