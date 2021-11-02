extends Node


const NimoResource = preload("res://Nimo.tscn")
const SuperNimoResource = preload("res://SuperNimo.tscn")
const BlockMakerResource = preload("res://BlockMaker.tscn")

const MIN_WORD_LEN = 3

var curNimo
var ghostNimo
var holdNimo
var nextNimos = []
var rng = RandomNumberGenerator.new()
var validWords = {}

var superNimo
var blockMaker

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
	createNimo(blockMaker.getNextNimo())
	$Timer.start()
	

func createNimo(nimoDesc):
	curNimo = NimoResource.instance()
	curNimo.init(self, $PlaySpace.getOrigin(), nimoDesc)
	self.add_child(curNimo)
	
	ghostNimo = NimoResource.instance()
	ghostNimo.init(self, $PlaySpace.getOrigin(), nimoDesc)
	ghostNimo.enableGhostMode(curNimo)
	self.add_child(ghostNimo)
	ghostNimo.updateGhostPosition(curNimo)

func _input(event):
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
		$Timer.stop()
		_on_Timer_timeout()
		$Timer.start()


func _on_Timer_timeout():
	if not curNimo.move(0,1):
		checkClear()
		
func checkClear():
	#clear ghost nimo
	ghostNimo.deleteBlocks()
	ghostNimo.queue_free()
	#add nimo to the super nimo
	curNimo.submitToSuperNimo()
	
	#figure out which rows and columns should be checked
	var rows = []
	var cols = []
	var toClearRows = []
	for block in curNimo.blocks:
		if not block.coords.x in cols: cols.append(block.coords.x)
		if not block.coords.y in rows: rows.append(block.coords.y)
	#check each consecutive chunk of blocks for words
	#check rows
	for row in rows:
		var toCheck = ""
		for i in range(10):
			if superNimo.blocks[i][row] == null: toCheck += " "
			else: toCheck += superNimo.blocks[i][row].letter
		var subString = checkForWords(toCheck)
		if subString.y != -1:
			if not row in toClearRows: toClearRows.append(row)
			if subString.z == -1: $Label.text = ("Last Word: " + invertString(toCheck.substr(subString.x, subString.y)))
			else: $Label.text = ("Last Word: " + toCheck.substr(subString.x, subString.y))
	#check columns
	for col in cols:
		var toCheck = ""
		for i in range(20):
			if superNimo.blocks[col][i] == null: toCheck += " "
			else: toCheck += superNimo.blocks[col][i].letter
		var subString = checkForWords(toCheck)
		if subString.y != -1:
			for i in range(subString.y):
				if not subString.x + i in toClearRows: toClearRows.append(subString.x + i)
			if subString.z == -1: $Label.text = ("Last Word: " + invertString(toCheck.substr(subString.x, subString.y)))
			else: $Label.text = ("Last Word: " + toCheck.substr(subString.x, subString.y))
		
	#clear any rows that include words found
	for row in toClearRows:
		superNimo.deleteRow(row)
	superNimo.dropRows()
	
	
	#check every row and delete them all if cleared
#	for i in range(20):
#		var filled = true
#		for k in range(10):
#			if not superNimo.checkCollision(Vector2(k,i)):
#				filled = false
#				break
#		if filled:
#			print("deleting row " + str(i))
#			superNimo.deleteRow(i)
#			superNimo.dropRows()

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
	
