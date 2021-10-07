extends TileMap

signal map_update
## Size of play area
const HEIGHT = 26
const WIDTH = 26

##Conway Rules
const DEATHS = [0,1,5,6,7,8]
const BIRTHS = [3]

##Size of tiles
const TILE_SIZE = 16

##Width of Border
const BORDER_SIZE = 3

## Delay between conway steps
export(int) var DELAY = 1
onready var timer = $Timer
onready var enemies = get_node("../../Enemies")
onready var player = get_node("../../Player")

var temp_field


func _ready():
	##Initialize Conway array from tilemap
	temp_field = []
	for x in range(WIDTH):
		var temp = []
		for y in range(HEIGHT):
			temp.append(get_cell(x+BORDER_SIZE,y+BORDER_SIZE))
		temp_field.append(temp)
	timer.start(DELAY)


## Iterate Conway
func _on_Timer_timeout():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			## Check for live neighbours
			var live_neighbours = 0
			for x_off in [-1,0,1]:
				for y_off in [-1,0,1]:
					if x_off != y_off or x_off != 0:
						if get_cell(x+BORDER_SIZE+x_off, y+BORDER_SIZE+y_off) > 0:
							live_neighbours +=1
			##Apply Conway Rules (Live cells)
			if get_cell(x+BORDER_SIZE,y+BORDER_SIZE) == 1:
				if live_neighbours in DEATHS:
					temp_field[x][y]=0
				else:
					temp_field[x][y]=1
			##Apply Conway Rules (Dead cells)
			var bodies = enemies.get_children()
			bodies.append(player)
			if get_cell(x+BORDER_SIZE,y+BORDER_SIZE) == 0:
				if live_neighbours in BIRTHS:
					temp_field[x][y]=1
					##Cells with a player cannot spawn
					for body in bodies:
						if (body.get_global_position() - Vector2(TILE_SIZE*(x+BORDER_SIZE)+TILE_SIZE/2,TILE_SIZE*(y+BORDER_SIZE)+TILE_SIZE/2)).length()<TILE_SIZE:
							temp_field[x][y]=0
							break	
				else:
					temp_field[x][y]=0
	
	##Update TileMap
	for x in range(WIDTH):
		for y in range(HEIGHT):
			set_cell(x+BORDER_SIZE,y+BORDER_SIZE,temp_field[x][y])
	## AutoTiles
	update_bitmask_region (Vector2( BORDER_SIZE, BORDER_SIZE ), Vector2(WIDTH+BORDER_SIZE,HEIGHT+BORDER_SIZE))
	##Restart Timer
	timer.start(DELAY)
	emit_signal("map_update")


## Run when collision is detected with a projectile
func hit(pos1 : Vector2, pos2 : Vector2):
	##Check for possible collsions in two cells and destroy
	if get_cellv(pos1)==1:
		set_cellv(pos1,0)
		temp_field[pos1.x-BORDER_SIZE][pos1.y-BORDER_SIZE]=0
	if get_cellv(pos2)==1:
		set_cellv(pos2,0)
		temp_field[pos2.x-BORDER_SIZE][pos2.y-BORDER_SIZE]=0
	##AutoTiles
	update_bitmask_region (pos1 - Vector2(4,4), pos1 + Vector2(4,4))
	emit_signal("map_update")
