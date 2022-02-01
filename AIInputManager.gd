extends Node

signal finished

var commandQueue = []
var inputting = false
var stopOnEmpty = true
var delay = true

func init():
	$"Random agent AI".init()

func executeNext():
	if commandQueue.empty(): return false
	var ev = InputEventAction.new()
	ev.action = commandQueue.pop_front()
	ev.pressed = true
	Input.parse_input_event(ev)
	return true

func addCommand(command):
	commandQueue.push_back(command)

func start(stopOnEmpty = true):
	self.inputting = true
	self.stopOnEmpty = stopOnEmpty
	#yield(get_tree().create_timer(1.0), "timeout")
	executeNext()

func _on_Main_input_compelted():
	if self.inputting:
		yield(get_tree().create_timer(0.2), "timeout")
		var full = executeNext()
		if not full and self.stopOnEmpty:
			self.inputting = false
			emit_signal("finished")
