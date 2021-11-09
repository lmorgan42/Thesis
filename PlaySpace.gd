extends Node

func getOrigin():
	return $Playspace.transform.get_origin()
func getDimensions():
	return $Playspace.scale
	
func setScorePercent(percent):
	percent = min(1, percent)
	$ScoreBackground.scale.y = -1000 * (percent)
