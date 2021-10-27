extends Node

#TODO replace with 2D array to make checks easier?
var blocks = []

func _enter_tree():
	for i in range(10):
		var temp = []
		for k in range(20):
			temp.append(null)
		blocks.append(temp)

func addBlocks(blockArr):
	for block in blockArr:
		addBlock(block)

func addBlock(block):
	blocks[block.coords.x][block.coords.y] = block
	add_child(block)

func checkCollision(coords):
	return blocks[coords.x][coords.y] != null

func deleteRow(row):
	for i in range(10):
		var coords = Vector2(i,row)
		if checkCollision(coords):
			blocks[coords.x][coords.y].queue_free()
			blocks[coords.x][coords.y] = null
		
func dropRows(startRow:int = 0):
	print("dropping")
	var blocksToMove = []
	var x = 0
	var y = startRow
	#find first row with blocks
	while not checkCollision(Vector2(x, y)):
		x += 1
		if x >= 10:
			x = 0
			y += 1
			if y == 20: return
	print("first block row is: " + str(y))
	#find next empty row
	var emptyRow = true
	while true:
		if checkCollision(Vector2(x, y)): 
			blocksToMove.append(blocks[x][y])
			emptyRow = false
		x += 1
		if x >= 10:
			if emptyRow:
				break
			emptyRow = true
			x = 0
			y += 1
			if y == 20:
				return
	print("first empty row is: " + str(y))
	#move all above blocks
	for block in blocksToMove:
		if blocks[block.coords.x][block.coords.y] == block:
			blocks[block.coords.x][block.coords.y] = null
		block.move(Vector2(0,1))
		blocks[block.coords.x][block.coords.y] = block
	dropRows()
		
func sortByRow(a, b):
	return a.y > b.y
