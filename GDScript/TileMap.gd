extends TileMap

#checks if cell should not be filled !
const EMPTY = 64

const oneAbove = [20,21,22,23,28,29,57]
const table = [30,31]
const twoAbove = 24
const threeAbove = [25,36]
const hanging = [32,33,34,35]
const onRoof = [26,27]

func _ready():
	randomize()
	set_tile_origin(1)
	fill_rooms(Vector2(4,0),10,10,20)

func fill_rooms(start,height,width,room):
	get_parent().get_node("background").fill_background(start,height,width)
	var clutter = []
	var drop
	var door
	var opening = randi() % 2
#	var opening = 0
#	var opening = 1
	if opening == 1 or opening == 2 :
		door = randi() % int(height - 5)
	if opening == 0 or opening == 2 :
		drop = randi() % int(width - 4)
	for w in range(width):
		for h in range(height):
			var ground_clutter =  randi() % 500
			set_cell(start.x,start.y + h,62)
			set_cell(start.x + width,start.y + h,62)
			set_cell(start.x + w,start.y,62)
			if !(w in range(5)) and !(w in range(width-3,width+2)) and height > 10 and ground_clutter in [23,24] :
				if height > 14 :
					clutter.append([start.x + w,start.y + 3,27])
				else :
					clutter.append([start.x + w,start.y + 2,26 ])
			set_cell(start.x + w,start.y + height,58)
			if !(w in range(5)) and !(w in range(width-3,width+2)) :
				if ground_clutter in range(10) :
					var clutter_num = randi() % oneAbove.size()
					clutter.append([start.x + w,start.y + height - 1,oneAbove[clutter_num] ])
				elif ground_clutter in range(10,14) :
					var clutter_num = randi() % table.size()
					clutter.append([start.x + w,start.y + height - 1,table[clutter_num] ])
				elif ground_clutter in range(14,18) :
					clutter.append([start.x + w,start.y + height - 2,twoAbove ])
				elif ground_clutter in range(18,22) :
					var clutter_num = randi() % threeAbove.size()
					clutter.append([ start.x + w,start.y + height - 3,threeAbove[clutter_num] ])
				elif ground_clutter in range(25,30) and height > 8 :
					var clutter_num = randi() % hanging.size()
					clutter.append([ start.x + w,start.y + height - 3 - (randi() % 4),hanging[clutter_num] ])
			set_cell(start.x + w,start.y + h,-1)
			set_cell(start.x + w,start.y + h,-1)
	set_cell(start.x,start.y + height,62)
	set_cell(start.x + width, start.y + height,62)
	var next_height = int((randi() % 6) + 8)
	var next_width = int((randi() % 30) + 10)
	if opening == 1 or opening == 2 :
		for h in range(4) :
			set_cell(start.x + width -2,start.y + height - h - 1 - door,EMPTY)
			set_cell(start.x + width -1,start.y + height - h - 1 - door,EMPTY)
			set_cell(start.x + width,start.y + height - h - 1 - door,EMPTY)
	if opening == 0 or opening == 2 :
		for w in range (3) :
			set_cell(start.x + drop + w + 1,start.y + height - 2,EMPTY)
			set_cell(start.x + drop + w + 1,start.y + height - 1,EMPTY)
			set_cell(start.x + drop + w + 1,start.y + height,EMPTY)
	for element in clutter :
		if ( element[2] in table ) and check_for_empty(element,2,2) :
			for i in range(3) :
				for j in range(-3,4) :
					set_cell(element[0] + j, element[1] - i, EMPTY)
			set_cell(element[0] ,element[1] ,element[2])
			var ground_clutter = randi() % oneAbove.size()
			set_cell(element[0],element[1] - 2,oneAbove[ground_clutter])
#			clutter.append([element[0],element[1] - 2,oneAbove[ground_clutter] ])
		elif (element[2] in oneAbove) and get_cell(element[0],element[1]) != EMPTY and !(get_cell(element[0],element[1]) in table):
			set_cell(element[0],element[1],element[2])
			set_cell(element[0],element[1]-1,EMPTY)
		elif (element[2] == twoAbove) and check_for_empty(element,2,0) and !(get_cell(element[0],element[1]) in table):
			set_cell(element[0],element[1],element[2])
			set_cell(element[0],element[1]+1,EMPTY)
		elif (element[2] in threeAbove) and check_for_empty(element,3,0) and !(get_cell(element[0],element[1]) in table):
			set_cell(element[0],element[1],element[2])
			set_cell(element[0],element[1]+1,EMPTY)
			set_cell(element[0],element[1]+2,EMPTY)
		elif (element[2] in onRoof):
			set_cell(element[0],element[1],element[2])
			set_cell(element[0],element[1]+1,EMPTY)
			set_cell(element[0],element[1]+2,EMPTY)
		elif (element[2] in hanging):
			set_cell(element[0],element[1],element[2])
			set_cell(element[0],element[1]+1,EMPTY)
			set_cell(element[0],element[1]-1,EMPTY)
	if opening == 1 or opening == 2 :
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
				set_cell(start.x + width + 1,start.y + height - h - 1 - door,EMPTY)
				set_cell(start.x + width + 2,start.y + height - h - 1 - door,EMPTY)
				set_cell(start.x + width + 3,start.y + height - h - 1 - door,EMPTY)
	if opening == 0 or opening == 2 :
		if room != 0 :
			var next_offset = Vector2(0,height) + Vector2(randi() % int(width),1 ) + Vector2(-(randi() % int(next_width)),0)
			var next_start = start + next_offset
			if ( next_start.x ) > ( start.x + drop ) :
				next_start.x += ( start.x + drop ) - ( next_start.x )
			if ( next_start.x + next_width ) < ( start.x + drop + 4 ) :
				next_width += ( start.x + drop + 4 ) - ( next_start.x + next_width )
			fill_rooms(next_start, next_height, next_width, room - 1)
			for w in range (3) :
				set_cell(start.x + drop + w + 1,start.y + height + 1,EMPTY)
				set_cell(start.x + drop + w + 1,start.y + height + 2,EMPTY)
				set_cell(start.x + drop + w + 1,start.y + height + 3,EMPTY)

func check_for_empty(pos,height,width):
	height += 1
	width += 1
	for i in range(-height,height) :
		for j in range(-width,width+1) :
			if get_cell(pos[0] + j,pos[1] - i) == EMPTY :
				return 0
	return 1
