extends TileMap

const HEIGHT = 26
const WIDTH = 26
const DEATHS = [0,1,5,6,7,8]
const BIRTHS = [3]
const DELAY = 2
const TILE_SIZE = 16
const BORDER_SIZE = 3

onready var timer = $Timer
onready var players = get_node("../Players")

var temp_field
# Called when the node enters the scene tree for the first time.
func _ready():
	temp_field = []
	for x in range(WIDTH):
		var temp = []
		for y in range(HEIGHT):
			temp.append(get_cell(x+BORDER_SIZE,y+BORDER_SIZE))
		temp_field.append(temp)
	timer.start(DELAY)



func _on_Timer_timeout():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var live_neighbours = 0
			for x_off in [-1,0,1]:
				for y_off in [-1,0,1]:
					if x_off != y_off or x_off != 0:
						if get_cell(x+BORDER_SIZE+x_off, y+BORDER_SIZE+y_off) > 0:
							live_neighbours +=1
			if get_cell(x+BORDER_SIZE,y+BORDER_SIZE) == 1:
				if live_neighbours in DEATHS:
					temp_field[x][y]=0
				else:
					temp_field[x][y]=1
			if get_cell(x+BORDER_SIZE,y+BORDER_SIZE) == 0:
				if live_neighbours in BIRTHS:
					temp_field[x][y]=1
					for player in players.get_children():
						if (player.get_global_position() - Vector2(TILE_SIZE*(x+BORDER_SIZE)+TILE_SIZE/2,TILE_SIZE*(y+BORDER_SIZE)+TILE_SIZE/2)).length()<TILE_SIZE:
							temp_field[x][y]=0
							break
				else:
					temp_field[x][y]=0
				
	for x in range(WIDTH):
		for y in range(HEIGHT):
			set_cell(x+BORDER_SIZE,y+BORDER_SIZE,temp_field[x][y])
	update_bitmask_region (Vector2( BORDER_SIZE, BORDER_SIZE ), Vector2(WIDTH+BORDER_SIZE,HEIGHT+BORDER_SIZE))
	timer.start(DELAY)

func hit(id : int):
	print(id)
	var cells = get_used_cells()
	var cells_passable = get_used_cells_by_id(0)
	for cell in cells_passable:
		cells.erase(cell)
	var pos = cells[id]
	if get_cellv(pos)==1:
		set_cellv(pos,0)
		temp_field[pos.x-BORDER_SIZE][pos.y-BORDER_SIZE]=0
	update_bitmask_region (pos - Vector2(2,2), pos + Vector2(2,2))
