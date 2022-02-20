extends Node


const NimoResource = preload("res://Nimo.tscn")
const SuperNimoResource = preload("res://SuperNimo.tscn")
const BlockMakerResource = preload("res://BlockMaker.tscn")

export var DefualtDropSpeed = 1
export var DefualtHoldSpeed = 1

const MIN_WORD_LEN = 3

signal input_compelted

var curNimo
var ghostNimo
var holdNimo
var nextNimos = []
var rng = RandomNumberGenerator.new()
var validWords = {}

var superNimo
var blockMaker

var pointValues = [[],['E','A','I','O','N','R','T','L','S','U'],['D','G'],['B','C','M','P'],['F','H','V','W','Y'],['K'],[],[],['J','X'],[],['Q','Z']]
var score = 0
var neededScore = 0
var scoreAddition = 0.5;
var scoreCapTime = 0.0
var holdingTime = 5
var aicontrolled = true
var blockInput = false

func _ready():
	
	var file = File.new()
	file.open("res://Assets/Collins Scrabble Words.txt", File.READ)
	var words = file.get_as_text().split("\n")
	for word in words:
		validWords[word] = null
	
	rng.randomize()
	blockMaker = BlockMakerResource.instance()
	self.add_child(blockMaker)
	blockMaker.init()
	superNimo = SuperNimoResource.instance()
	self.add_child(superNimo)
	$PlaySpace.setScorePercent(0)
	$DroppingTimer.wait_time = DefualtDropSpeed
	createNimo(blockMaker.getNextNimo())
	if aicontrolled: $AIInputManager.init(self)
	

func createNimo(nimoDesc):
	$DroppingTimer.stop()
	curNimo = NimoResource.instance()
	curNimo.init(self, $PlaySpace.getOrigin(), nimoDesc)
	self.add_child(curNimo)
	for block in curNimo.blocks:
		if superNimo.checkCollision(block.coords):
			self.gameOver()
	
	ghostNimo = NimoResource.instance()
	ghostNimo.init(self, $PlaySpace.getOrigin(), nimoDesc)
	ghostNimo.enableGhostMode(curNimo)
	self.add_child(ghostNimo)
	ghostNimo.updateGhostPosition(curNimo)
	
	holdingTime = DefualtHoldSpeed
	$HoldingTimeLbl.text = str(holdingTime)
	$HoldingTimer.start()

func _input(event):
	if blockInput: return
	var invalidInput = false
	if event.is_action_pressed("move_block_right"):
		curNimo.move(1,0)
		ghostNimo.updateGhostPosition(curNimo)
	elif event.is_action_pressed("move_block_left"):
		curNimo.move(-1,0)
		ghostNimo.updateGhostPosition(curNimo)
	elif event.is_action_pressed("rotate_block_clockwise"):
		curNimo.rotate(1)
		ghostNimo.updateGhostPosition(curNimo)
	elif event.is_action_pressed("rotate_block_counterclockwise"):
		curNimo.rotate(-1)
		ghostNimo.updateGhostPosition(curNimo)
	elif event.is_action_pressed("slam_down"):
		curNimo.slamdown()
		$DroppingTimer.stop()
		_on_Timer_timeout()
	elif event.is_action_pressed("fast_fall"):
		if not $HoldingTimer.is_stopped():
			holdingTime = 1
			_on_HoldingTimer_timeout()
		$DroppingTimer.wait_time = DefualtDropSpeed/2.0
	elif event.is_action_released("fast_fall"):
		$DroppingTimer.wait_time = DefualtDropSpeed
	elif event.is_action_pressed("rotate_letters_left"):
		curNimo.rotateLetters(-1)
		ghostNimo.rotateLetters(-1)
	elif event.is_action_pressed("rotate_letters_right"):
		curNimo.rotateLetters(1)
		ghostNimo.rotateLetters(1)
	else:
		invalidInput = true
	if not invalidInput:
		emit_signal("input_compelted")


func _on_Timer_timeout():
	if not curNimo.move(0,1):
		checkClear()
		
func checkClear():
	#clear ghost nimo
	ghostNimo.deleteBlocks()
	ghostNimo.queue_free()
	#add nimo to the super nimo
	curNimo.submitToSuperNimo()
	
#	#figure out which rows and columns should be checked
#	var rows = []
#	var cols = []
#	var toClearRows = []
#	for block in curNimo.blocks:
#		if not block.coords.x in cols: cols.append(block.coords.x)
#		if not block.coords.y in rows: rows.append(block.coords.y)
#	#check each consecutive chunk of blocks for words
#	#check rows
#	for row in rows:
#		var toCheck = ""
#		for i in range(10):
#			if superNimo.blocks[i][row] == null: toCheck += " "
#			else: toCheck += superNimo.blocks[i][row].letter
#		var subString = checkForWords(toCheck)
#		if subString.y != -1:
#			if not row in toClearRows: toClearRows.append(row)
#			var foundWord = ""
#			if subString.z == -1: foundWord = invertString(toCheck.substr(subString.x, subString.y))
#			else: foundWord = toCheck.substr(subString.x, subString.y)
#			$LastWord.text = "Last Word: " + foundWord
#			self.score += calcWordScore(foundWord)
#			updateScore()
#	#check columns
#	for col in cols:
#		var toCheck = ""
#		for i in range(20):
#			if superNimo.blocks[col][i] == null: toCheck += " "
#			else: toCheck += superNimo.blocks[col][i].letter
#		var subString = checkForWords(toCheck)
#		if subString.y != -1:
#			for i in range(subString.y):
#				if not subString.x + i in toClearRows: toClearRows.append(subString.x + i)
#			if subString.z == -1: $LastWord.text = ("Last Word: " + invertString(toCheck.substr(subString.x, subString.y)))
#			else: $LastWord.text = ("Last Word: " + toCheck.substr(subString.x, subString.y))
#
#	#clear any rows that include words found
#	for row in toClearRows:
#		superNimo.deleteRow(row)
#	superNimo.dropRows()
	
	
	#check every row and delete them all if cleared
	for i in range(20):
		var filled = true
		for k in range(10):
			if not superNimo.checkCollision(Vector2(k,i)):
				filled = false
				break
		if filled:
			print("deleting row " + str(i))
			superNimo.deleteRow(i)
			superNimo.dropRows()

	curNimo.queue_free()
	createNimo(blockMaker.getNextNimo())

func checkForWords(toCheck):
	var toRe = Vector3(0,-1, 1)
	for i in range(len(toCheck), MIN_WORD_LEN - 1, -1):
		for k in range(len(toCheck) - i + 1):
			if toCheck.substr(k, i) in validWords:
				toRe.x = k
				toRe.y = i
				return toRe
			if invertString(toCheck.substr(k,i)) in validWords:
				toRe.x = k
				toRe.y = i
				toRe.z = -1
				return toRe
	return toRe

func invertString(toInvert):
	var chars = []
	for i in range(len(toInvert)):
		chars.append(toInvert[i])
	chars.invert()
	toInvert = ""
	for i in range(len(chars)):
		toInvert += chars[i]
	return toInvert

func getBlockLetters(num):
	var toRe = ""
	for i in range(num):
		toRe += "%c" % rng.randi_range(65,90)
	return toRe
	


func _on_HoldingTimer_timeout():
	holdingTime -= 1
	if holdingTime > 0:
		$HoldingTimeLbl.text = str(holdingTime)
	else:
		$HoldingTimeLbl.text = str(0)
		$HoldingTimer.stop()
		_on_Timer_timeout()
		$DroppingTimer.start()

func updateScore():
	$ScoreLbl.text = "Score: " + str(score)

func calcWordScore(word):
	var toRe = 0
	word = word.to_upper()
	for i in word:
		for k in range(len(pointValues)):
			if i in  pointValues[k]:
				toRe += k
				break
	return toRe


func _on_ScoreBuildupTimer_timeout():
	neededScore += scoreAddition * ($ScoreBuildupTimer.wait_time/1.0)
	recalcScoreTracker()

func recalcScoreTracker():
	var scoreCap = (neededScore * 0.5) + 50
	$PlaySpace.setScorePercent((neededScore - score)/scoreCap)

func gameOver():
	print("game over")
	blockInput = true
	$DroppingTimer.stop()
	$HoldingTimer.stop()
	$ScoreBuildupTimer.stop()
	$HoldingTimeLbl.text = "GAME OVER"
