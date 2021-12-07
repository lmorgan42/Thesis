extends Node

func getOrigin():
	return $Playspace.transform.get_origin()
func getDimensions():
	return $Playspace.scale
	
func setScorePercent(percent):
	percent = clamp(percent, 0.0, 1.0)
	$ScoreBackground.scale.y = -1000 * (percent)
