extends Node

#encoded as position of leftmost block of nimo
var position
#encoded as number of clockwise rotaitons from default
var rotation
#2d array (akin to super nimo) of potential board state
var state

#bonus ai specifc variables
var highestPoint
var heightList
var holeCount
var psuedoHoleCount
var balance
var lineScore
var score

func init(position : int, rotation : int, state):
	self.position = position
	self.rotation = rotation
	self.state = state

func toString():
	var toRe = "p: " + str(position) + " r: " + str(rotation)
	if heightList != null:
		toRe += "\nheightList: " + str(heightList)
	if highestPoint != null:
		toRe += "\nhighest: " + str(highestPoint)
	if holeCount != null:
		toRe += "\nhole count: " + str(holeCount)
	if psuedoHoleCount != null:
		toRe += "\npsuedo hole count: " + str(psuedoHoleCount)
	if balance != null:
		toRe += "\nbalance: " + str(balance)
	if lineScore != null:
		toRe += "\nline score: " + str(lineScore)
	if score != null:
		toRe += "\nBoard Score: " + str(score)
	for y in range(len(state[0])):
		toRe += "\n["
		for x in range(len(state)):
			if len(state[x][y]) == 1: toRe += str(state[x][y][0]) + " "
			elif len(state[x][y]) == 2: 
				if state[x][y][0] == 2:toRe += str(state[x][y][1]) + " "
				else: toRe += str(state[x][y][1]).to_lower() + " "
		toRe += "]"
	return toRe
