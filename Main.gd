extends Node


const NimoResource = preload("res://Nimo.tscn")
const SuperNimoResource = preload("res://SuperNimo.tscn")

var nimo
var superNimo

func _ready():
	createNimo([[0,1,0],[1,0,1]])
	superNimo = SuperNimoResource.instance()
	self.add_child(superNimo)
	$Timer.start()

func createNimo(nimoDesc):
	nimo = NimoResource.instance()
	nimo.init(self, $PlaySpace.getOrigin(), nimoDesc)
	self.add_child(nimo)

func _input(event):
	if event.is_action_pressed("move_block_right"):
		nimo.move(1,0)
	elif event.is_action_pressed("move_block_left"):
		nimo.move(-1,0)
	elif event.is_action_pressed("rotate_block_clockwise"):
		nimo.rotate(1)
	elif event.is_action_pressed("rotate_block_counterclockwise"):
		nimo.rotate(-1)


func _on_Timer_timeout():
	if not nimo.move(0,1):
		nimo.submitToSuperNimo()
		nimo.queue_free()
		createNimo([[0,1,0],[1,0,1]])
