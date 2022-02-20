extends Node

var GameManager
var highestPoints = []
var blocks = []
var blockBottom = []
var movementTracker = 0

func init(GameManager):
	self.GameManager = GameManager
	solveForMove()

func solveForMove():
	getBlocks()
	checkLowestPoint()
	resolveMovement()

func getBlocks():
	blocks = []
	for block in GameManager.curNimo.blocks:
		blocks.append(block.coords)

func checkForXInBlocks(xValue):
	for coord in blocks:
		if coord.x == xValue: return true
	return false
	
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
			print("distance: " + str(distance))
			if distance < bestSubDistance: bestSubDistance = distance
		if bestSubDistance > bestDistance: 
			bestDistance = bestSubDistance
			leftXPos = i
	movementTracker += leftXPos

func resolveMovement():
	var moveString = ""
	if movementTracker < 0: 
		moveString = "move_block_left"
		movementTracker *= -1
	else: moveString = "move_block_right"
	for i in range(movementTracker):
		get_parent().addCommand(moveString)
	get_parent().addCommand("slam_down")
	get_parent().start()


func _on_AIInputManager_finished():
	solveForMove()
