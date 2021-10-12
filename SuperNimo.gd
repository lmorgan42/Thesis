extends Node

#TODO replace with 2D array to make checks easier?
var blocks = {}

func addBlocks(blockArr):
	for block in blockArr:
		addBlock(block)

func addBlock(block):
	blocks[block.coords] = block
	add_child(block)

func checkCollision(coords):
	return coords in blocks

func deleteRow(row):
	for i in range(10):
		var coords = Vector2(i,row)
		if coords in blocks:
			blocks[coords].queue_free()
			blocks.erase(coords)
