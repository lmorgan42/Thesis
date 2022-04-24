extends Node

var recordFile
var runs

func init(runs):
	self.runs = runs
	recordFile = File.new()
	recordFile.open("res://Testing/" + str(OS.get_unix_time()) + ".txt", File.WRITE)
	recordFile.store_string("score,blocks_placed\n")

func recordRun(score, blocks_placed):
	recordFile.store_string(str(score) + "," + str(blocks_placed) + "\n")
	recordFile.flush()
	runs -= 1
	if runs > 0:
		return true
	else:
		recordFile.close()
		return false
		
