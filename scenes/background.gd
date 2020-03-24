extends TileMap

var backtiles = [45,46,47,48,49,50]
var backtiles2 = [51,52,53,54,55,56]
var tiles = [backtiles,backtiles2]

func fill_background(start,height,width) :
	randomize()
	var i = randi() % 2
	for w in range(width + 1):
		for h in range(height + 1):
			var k = randi() % tiles[i].size()
			set_cell(start.x + w,start.y + h,tiles[i][k])
