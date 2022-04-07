extends Node

var dist = []

func _ready():
	dist.resize(26)

func generateDistribution(validWords):
	var letterStore = {}
	for word in validWords:
		for letter in word:
			if not letter in letterStore:
				letterStore[letter] = 1
			else:
				letterStore[letter] = letterStore[letter] + 1
	var total = 0.0
	for letter in letterStore:
		total += letterStore[letter]
	for letter in letterStore:
		dist[ord(letter)-65] = letterStore[letter]/total

func getLetter(rng):
	var num = rng.randf()
	var total = 0
	for i in range(26):
		total += dist[i]
		if num <= total:
			return char(65 + i)
	return "?"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
