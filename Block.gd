extends Sprite


var letter = ""
var coords = Vector2(0,0)
var playOrigin
var BlockSize = 0

func init(playOrigin : Vector2, letter):
	self.playOrigin = playOrigin
	self.letter = letter
	$Label.text = self.letter
	self.BlockSize = self.texture.get_size().x

func setBlockPosition(x, y):
	coords = Vector2(x, y)
	_setPosition()

func setBlockPositionV(coord):
	coords = coord
	_setPosition()

func move(offset : Vector2):
	coords += offset
	coords.x = clamp(coords.x,0,9)
	coords.y = clamp(coords.y,0,19)
	_setPosition()
	
func _setPosition():
	transform.origin.x = int(playOrigin.x + (coords.x * self.BlockSize))
	transform.origin.y = int(playOrigin.y + (coords.y * self.BlockSize))
	#print("transform origin: " + str(transform.origin.x) + ", " + str(transform.origin.y))
