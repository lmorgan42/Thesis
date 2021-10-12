extends Node


const NimoResource = preload("res://Nimo.tscn")
const SuperNimoResource = preload("res://SuperNimo.tscn")
const BlockMakerResource = preload("res://BlockMaker.tscn")

var curNimo
var holdNimo
var nextNimos = []

var superNimo
var blockMaker

func _ready():
	blockMaker = BlockMakerResource.instance()
	self.add_child(blockMaker)
	blockMaker.init()
	createNimo(blockMaker.getNextNimo())
	superNimo = SuperNimoResource.instance()
	self.add_child(superNimo)
	$Timer.start()

func createNimo(nimoDesc):
	curNimo = NimoResource.instance()
	curNimo.init(self, $PlaySpace.getOrigin(), nimoDesc)
	self.add_child(curNimo)

func _input(event):
	if event.is_action_pressed("move_block_right"):
		curNimo.move(1,0)
	elif event.is_action_pressed("move_block_left"):
		curNimo.move(-1,0)
	elif event.is_action_pressed("rotate_block_clockwise"):
		curNimo.rotate(1)
	elif event.is_action_pressed("rotate_block_counterclockwise"):
		curNimo.rotate(-1)


func _on_Timer_timeout():
	if not curNimo.move(0,1):
		checkClear()
		
func checkClear():
	#add nimo to the super nimo
	curNimo.submitToSuperNimo()
	
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
	
	curNimo.queue_free()
	createNimo(blockMaker.getNextNimo())
