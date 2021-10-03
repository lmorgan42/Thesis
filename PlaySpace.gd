extends Node

func getOrigin():
	return $Playspace.transform.get_origin()
func getDimensions():
	return $Playspace.scale
	
