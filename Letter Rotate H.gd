extends Node

var boardStatePre = preload("res://BoardState.tscn")

var GameManager
var highestPoints = []
var blocks = []
var blockBottom = []
var potentialBoards = []
var movementTracker = 0
var running = false

var logFile

const heightMult = 10.0
const holeMult = 2.0
const psuedoHoleMult = 0.2
const balanceMult = 0.2
const scoreMult = -0.1
const psuedoHoleCutoff = 3

func init(GameManager):
	running = true
	self.GameManager = GameManager
	solveForMove()

func solveForMove():
	getBlocks()
	generatePotentialBoards()
	generateHeightScore()
	resolveMovement(chooseBoard())

func getBlocks():
	blocks = []
	for block in GameManager.curNimo.blocks:
		blocks.append([block.coords, block.letter])

func letterRotateSort(a, b):
	if a[0].y == b[0].y:
		return a[0].x > b[0].x
	return a[0].y > b[0].y

func generatePotentialBoards():
	#create block rep to work with
	var nimoRef = []
	for block in blocks:
		nimoRef.append([Vector2(block[0].x, block[0].y), block[1]])
	var nimoWidth = 1
	
	#loop through possible rotations
	for i in range(4):
		#loop through possible letter rotations
		for l in range(4):
			#push nimoRef to far left an calculate width
			var leftmost = 20
			var rightmost = 0
			for block in nimoRef:
				if block[0].x < leftmost: leftmost = block[0].x
				if block[0].x > rightmost: rightmost = block[0].x
			for k in range(len(nimoRef)):
				nimoRef[k][0].x -= leftmost
			#print(nimoRef)
			nimoWidth = rightmost - leftmost + 1
			
			#loop through possible positions
			for j in range(10 - nimoWidth + 1):
				#create nimo from ref to simulate dropping
				var nimo = []
				for block in nimoRef:
					nimo.append([Vector2(block[0].x, block[0].y), block[1]])
				while not collisionCheckNimo(nimo):
					for k in range(len(nimo)):
						nimo[k][0].y += 1
				#create copy of super nimo
				var bState = []
				for elem in GameManager.superNimo.blocks:
					var temp = []
					for subElem in elem:
						if subElem != null: temp.append([1, subElem.letter])
						else: temp.append([0])
					bState.append(temp)
				#and add dropped nimo to it
				for block in nimo:
					bState[block[0].x][block[0].y] = [2, block[1]]
				#make new board state
				var temp = boardStatePre.instance()
				temp.init(j, i, l, bState)
				potentialBoards.append(temp)
				add_child(temp)
				#shift nimo over one
				for k in range(len(nimoRef)):
					nimoRef[k][0].x += 1
				
			#rotate letters on nimoRef
			#direc -1 left, 1 is right
			nimoRef.sort_custom(self, 'letterRotateSort')
			var a = 0
			var direc = 1
			var heldLet = ""
			for b in range(len(nimoRef) + 1):
				a = (a + direc)%len(nimoRef)
				var tempLet = nimoRef[a][1]
				nimoRef[a][1] = heldLet
				heldLet = tempLet
		
		#rotate nimoRef
		#determin pivot point (favour lower and right side)
		#determin min and max coords (create bounding box)
		var minCoord = Vector2(9,19)
		var maxCoord = Vector2(0,0)
		for block in nimoRef:
			if block[0].x > maxCoord.x:
				maxCoord.x = block[0].x
			if block[0].x < minCoord.x:
				minCoord.x = block[0].x
			if block[0].y > maxCoord.y:
				maxCoord.y = block[0].y
			if block[0].y < minCoord.y:
				minCoord.y = block[0].y
		#find middle of bounding box
		#TODO add support for 0.5,0.5 coordinates
		var pivotPoint = Vector2(0,0)
		var width = maxCoord.x - minCoord.x + 1
		pivotPoint.x = width - round(width/2.0) + minCoord.x
		width = maxCoord.y - minCoord.y + 1
		pivotPoint.y = width - round(width/2.0) + minCoord.y
		#for each block, transpose around that point
		for k in range(len(nimoRef)):
			var adjustedCoords = (nimoRef[k][0] - pivotPoint)
			var newLoc = Vector2(0,0)
			newLoc.x = -adjustedCoords.y
			newLoc.y = adjustedCoords.x
			newLoc += pivotPoint
			nimoRef[k][0] = newLoc

func generateHeightScore():
	for board in potentialBoards:
		var heightScore = 0
		var holeCount = 0
		var psuedoHoleCount = 0
		var heightList = []
		var clearList = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
		heightList.resize(10)
		#move from top to bottom of each column, when hitting the top, add that to height list
		#	then count each hole under the top in that column
		#	then count each height disparity and add that to psuedoHole
		var hitTop = false
		for x in range(len(board.state)):
			hitTop = false
			for y in range(len(board.state[x])):
				if board.state[x][y][0] == 2:
					heightScore += y
				elif board.state[x][y][0] == 0 and y in clearList:
					clearList.erase(y)
				if not hitTop and board.state[x][y][0] > 0: 
					hitTop = true
					heightList[x] = y
				elif hitTop and board.state[x][y][0] == 0:
					holeCount += 1
				elif not hitTop and y == 19:
					heightList[x] = 20
		heightScore = (80 - heightScore)/80.0
		for h in range(len(heightList) - 1):
			var diff = abs(heightList[h] - heightList[h + 1])
			if diff > psuedoHoleCutoff: psuedoHoleCount += diff
		var heightSum = 0
		for h in heightList:
			heightSum += h
		var avgH = float(heightSum) / len(heightList)
		var stdev = 0
		for h in heightList:
			stdev += pow(h - avgH, 2)
		stdev = sqrt(float(stdev) / len(heightList))
		#calculate score of any clearing lines
		for height in clearList:
			var toCheck = ""
			for x in range(len(board.state)):
				toCheck += board.state[x][height][1]
			var subString = GameManager.checkForWords(toCheck)
			if subString.y != -1:
				var foundWord = ""
				if subString.z == -1: foundWord = GameManager.invertString(toCheck.substr(subString.x, subString.y))
				else: foundWord = toCheck.substr(subString.x, subString.y)
				board.lineScore += GameManager.calcWordScore(foundWord)
		board.lineScore *= len(clearList)
		board.balance = stdev
		board.highestPoint = heightScore
		board.heightList = heightList
		board.holeCount = holeCount
		board.psuedoHoleCount = psuedoHoleCount
		board.score = calcBoardScore(board)
		#saveToLogFile(board.toString())
			
func collisionCheckNimo(nimo):
	for block in nimo:
		if block[0].y == 19: return true
		if GameManager.superNimo.checkCollision(Vector2(block[0].x, block[0].y + 1)): return true
	return false

func chooseBoard():
	var chosen = 0
	var bestScore = 99999999
	for i in range(len(potentialBoards)):
		if potentialBoards[i].score < bestScore:
			bestScore = potentialBoards[i].score
			chosen = i
	#print("----------------- Chosen -----------------")
	#print(potentialBoards[chosen].toString())
	return chosen

func calcBoardScore(board):
	return (board.highestPoint * heightMult) + (board.holeCount * holeMult) + (board.psuedoHoleCount * psuedoHoleMult) + (board.balance * balanceMult) + (board.lineScore * scoreMult)

func resolveMovement(boardIndex):
	var board = potentialBoards[boardIndex]
	get_parent().placeBlock(board.position, board.rotation, board.letterRotation)
#	for i in range(board.rotation):
#		get_parent().addCommand("rotate_block_clockwise")
#	for i in range(6):
#		get_parent().addCommand("move_block_left")
#	for i in range(board.position):
#		get_parent().addCommand("move_block_right")
#	get_parent().addCommand("slam_down")
	potentialBoards = []
#	get_parent().start()

func saveToLogFile(text):
	if logFile == null:
		logFile = "res://Testing/Log " + str(OS.get_unix_time()) + ".txt"
		var temp = File.new()
		temp.open(logFile, File.WRITE)
		temp.close()
	var recordFile = File.new()
	recordFile.open(logFile, File.READ_WRITE)
	recordFile.seek_end()
	recordFile.store_string(text)
	recordFile.close()

func _on_AIInputManager_finished():
	if not running: return
	solveForMove()
