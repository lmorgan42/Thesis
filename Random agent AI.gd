extends Node

const Max_Moves = 8
const Possible_Moves = ["move_block_right", "move_block_left", "rotate_block_clockwise", "rotate_block_counterclockwise"]

var rng = RandomNumberGenerator.new()
var running = false

func init(GM):
	running = true
	createMoveSequence()

func createMoveSequence():
	var moves = rng.randi_range(1, Max_Moves)
	for i in range(moves):
		get_parent().addCommand(Possible_Moves[rng.randi_range(0, len(Possible_Moves) - 1)])
	get_parent().addCommand("slam_down")
	get_parent().start()

func _on_AIInputManager_finished():
	if not running: return
	createMoveSequence()
