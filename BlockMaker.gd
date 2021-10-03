extends Node

var possibleBlocks = [[[1],[1],[1],[1]],[[0,1],[0,1],[1,1]],[[1,0],[1,0],[1,1]],[[0,1,0],[1,1,1]],[[1,1],[1,1]],[[1,1,0],[0,1,1]],[[0,1,1],[1,1,0]]]
var nimoOrder = []

func init():
	createNimoOrder()

func getNextNimo():
	if len(nimoOrder) == 0:
		createNimoOrder()
	return possibleBlocks[nimoOrder.pop_back()]

func createNimoOrder():
	for i in range(len(possibleBlocks)):
		nimoOrder.append(i)
	nimoOrder.shuffle()
