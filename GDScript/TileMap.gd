extends TileMap


func _ready():
	randomize()
	fill_rooms(Vector2(4,0),10,10,20)

func fill_rooms(start,height,width,room):
	var drop
	var door
	var opening = randi() % 2
	if opening == 1 :
		door = randi() % int(height - 5)
	if opening == 0 :
		drop = randi() % int(width - 4)
	for w in range(width):
		for h in range(height):
			set_cell(start.x,start.y + h,62)
			set_cell(start.x + width,start.y + h,62)
			set_cell(start.x + w,start.y,62)
			set_cell(start.x + w,start.y + height,58)
			set_cell(start.x + w,start.y + h,-1)
			set_cell(start.x + w,start.y + h,-1)
	set_cell(start.x,start.y + height,62)
	set_cell(start.x + width, start.y + height,62)
	var next_height = int((randi() % 6) + 6)
	var next_width = int((randi() % 6) + 10)
	if opening == 1 :
		if room != 0 :
			# second vect is to ensure the opening is inside, the second is to be above the first room
			var next_offset = Vector2(width,0) + Vector2(1,randi() % int(height) ) + Vector2(0,-(randi() % int(next_height)))
			var next_start = start + next_offset
			if ( next_start.y ) > ( start.y - door + 2 ) :
				next_start.y += ( start.y - door + 2 ) - (next_start.y)
			if ( next_start.y + next_height ) < ( start.y + height - door ) :
				next_height += ( start.y + height - door ) - ( next_start.y + next_height )
			fill_rooms(next_start, next_height, next_width, room - 1)
		for h in range(4) :
			set_cell(start.x + width,start.y + height - h - 1 - door,-1)
			set_cell(start.x + width + 1,start.y + height - h - 1 - door,-1)
	if opening == 0 :
		if room != 0 :
			var next_offset = Vector2(0,height) + Vector2(randi() % int(width),1 ) + Vector2(-(randi() % int(next_width)),0)
			var next_start = start + next_offset
			if ( next_start.x ) > ( start.x + drop ) :
				next_start.x += ( start.x + drop ) - ( next_start.x )
			if ( next_start.x + next_width ) < ( start.x + drop + 4 ) :
				next_width += ( start.x + drop + 4 ) - ( next_start.x + next_width )
			fill_rooms(next_start, next_height, next_width, room - 1)
		for w in range (3) :
			set_cell(start.x + drop + w + 1,start.y + height,-1)
			set_cell(start.x + drop + w + 1,start.y + height + 1,-1)
