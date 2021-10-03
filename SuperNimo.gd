extends Node

var blocks = {}

func addBlocks(blockArr):
	for block in blockArr:
		addBlock(block)

func addBlock(block):
	blocks[block.coords] = block
	add_child(block)

func checkCollision(coords):
	return coords in blocks
