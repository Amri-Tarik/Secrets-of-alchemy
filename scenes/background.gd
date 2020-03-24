extends TileMap

var backtiles = [45,46,47]
var moss = [48,49,50]
var backtiles2 = [51,52,53]
var moss2 = [54,55,56]
var tiles = [backtiles,backtiles2]
var mosstiles = [moss,moss2]

func fill_background(start,height,width) :
	randomize()
	var i = randi() % 2
	for w in range(width + 1):
		for h in range(height + 1):
			var k = randi() % tiles[i].size()
			var mossy = randi() % 4
			if mossy == 3 :
				set_cell(start.x + w,start.y + h,mosstiles[i][k])
			else :
				set_cell(start.x + w,start.y + h,tiles[i][k])
