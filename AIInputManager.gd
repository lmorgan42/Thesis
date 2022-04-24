extends Node

signal finished


var commandQueue = []
var inputting = false
var stopOnEmpty = true
var delay = true
var midPlacing = false
var placingPosition = -1
var delayTime = 0.2

func init(GameManager):
	$"Letter Rotate H".init(GameManager)

func reset():
	print(inputting)
	if inputting:
		inputting = false
		commandQueue.clear()
	midPlacing = false
	emit_signal("finished")

func executeNext():
	if commandQueue.empty(): 
		inputting = false
		return false
	var ev = InputEventAction.new()
	ev.action = commandQueue.pop_front()
	ev.pressed = true
	Input.parse_input_event(ev)
	return true

func addCommand(command):
	commandQueue.push_back(command)

func placeBlock(position, rotation, letterRotation):
	#print("placing block")
	placingPosition = position
	midPlacing = true
	if rotation > 0 or letterRotation > 0:
		for i in range(rotation): self.addCommand("rotate_block_clockwise")
		for i in range(letterRotation): self.addCommand("rotate_letters_right")
		self.start()
	else:
		placeBlockFinish()

func placeBlockFinish():
	midPlacing = false
	var neededMovement = placingPosition - getCurrentBlockLeftmost()
	var moveString
	if neededMovement < 0:
		moveString = "move_block_left"
		neededMovement *= -1
	else:
		moveString = "move_block_right"
	for i in range(neededMovement):
		self.addCommand(moveString)
	self.addCommand("slam_down")
	self.start()

func getCurrentBlockLeftmost():
	var leftmost = 20
	for block in get_parent().curNimo.blocks:
		if block.coords.x < leftmost: leftmost = block.coords.x
	return leftmost

func start(stopOnEmpty = true):
	self.inputting = true
	self.stopOnEmpty = stopOnEmpty
	#yield(get_tree().create_timer(1.0), "timeout")
	executeNext()

func _on_Main_input_compelted():
	if self.inputting:
		if delay: yield(get_tree().create_timer(delayTime), "timeout")
		var full = executeNext()
		if not full and self.stopOnEmpty:
			if midPlacing:
				placeBlockFinish()
			else:
				yield(get_tree(),"idle_frame")
				emit_signal("finished")
