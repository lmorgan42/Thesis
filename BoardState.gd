extends Node

#encoded as position of leftmost block of nimo
var position
#encoded as number of clockwise rotaitons from default
var rotation
#2d array (akin to super nimo) of potential board state
var state

#bonus ai specifc variables
var highestPoint
var holeCount

func init(position : int, rotation : int, state):
	self.position = position
	self.rotation = rotation
	self.state = state

func toString():
	var toRe = "p: " + str(position) + " r: " + str(rotation)
	if highestPoint != null:
		toRe += "\nhighest: " + str(highestPoint)
	if holeCount != null:
		toRe += "\nhole count: " + str(holeCount)
	for y in range(len(state[0])):
		toRe += "\n["
		for x in range(len(state)):
			toRe += str(state[x][y]) + " "
		toRe += "]"
	return toRe
