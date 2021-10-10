extends TileMap

class_name Level

signal map_update
## Size of play area
const HEIGHT = 26
const WIDTH = 26

##Conway Rules
var DEATHS = [0,1,4,5,6,7,8]
var BIRTHS = [3]

##Size of tiles
const TILE_SIZE = 16

##Width of Border
const BORDER_SIZE = 3

## Delay between conway steps
export(float) var DELAY = 1
onready var timer = $Timer


export(Array) var live_ids = [1,2]
export(int) var var_live_id =1
export(int) var var_dead_id = 0
export(Array) var water_tiles = [3]

var enemies
var player : Player

var temp_field
var burning_cells = []

func load_level():
	##Initialize Conway array from tilemap
	temp_field = []
	for x in range(WIDTH):
		var temp = []
		for y in range(HEIGHT):
			temp.append(get_cell(x+BORDER_SIZE,y+BORDER_SIZE))
		temp_field.append(temp)
	
	enemies = get_node("../../Enemies")
	player = get_node("../../Player")
	player.global_position = $PlayerSpawn.global_position
	player.velocity = Vector2.ZERO
	player.last_dir = Vector2.DOWN
	player.TILE_SIZE=TILE_SIZE
	$PlayerSpawn.queue_free()
	for spawn in $EnemyPositions.get_children():
		print(spawn.name,"-",spawn.enemy_type)
		var enemy = load(spawn.enemy_type).instance()
		enemy.global_position = spawn.global_position
		enemy.nav = get_parent()
		enemies.add_child(enemy)
		spawn.queue_free()
	$EnemyPositions.queue_free()
	timer.start(DELAY)

## Iterate Conway
func _on_Timer_timeout():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell_pos = Vector2(x+BORDER_SIZE,y+BORDER_SIZE)
			## Check for live neighbours
			var live_neighbours = 0
			for x_off in [-1,0,1]:
				for y_off in [-1,0,1]:
					if x_off != y_off or x_off != 0:
						if get_cell(x+BORDER_SIZE+x_off, y+BORDER_SIZE+y_off) in live_ids:
							live_neighbours +=1
			##Apply Conway Rules (Live cells)
			if get_cellv(cell_pos) == var_live_id:
				if live_neighbours in DEATHS and !(cell_pos in burning_cells):
					temp_field[x][y]=var_dead_id
				else:
					temp_field[x][y]=var_live_id
			##Apply Conway Rules (Dead cells)
			var bodies = enemies.get_children()
			bodies.append(player)
			if get_cell(x+BORDER_SIZE,y+BORDER_SIZE) == var_dead_id:
				if live_neighbours in BIRTHS:
					temp_field[x][y]=var_live_id
					##Cells with a player cannot spawn
					for body in bodies:
						if (body.get_global_position() - Vector2(TILE_SIZE*(x+BORDER_SIZE)+TILE_SIZE/2,TILE_SIZE*(y+BORDER_SIZE)+TILE_SIZE/2)).length()<TILE_SIZE:
							temp_field[x][y]=var_dead_id
							break	
				else:
					temp_field[x][y]=var_dead_id
	
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
	if get_cellv(pos1)==1 and !(pos1 in burning_cells):
		set_cellv(pos1,0)
		temp_field[pos1.x-BORDER_SIZE][pos1.y-BORDER_SIZE]=0
	if get_cellv(pos2)==1 and !(pos2 in burning_cells):
		set_cellv(pos2,0)
		temp_field[pos2.x-BORDER_SIZE][pos2.y-BORDER_SIZE]=0
	##AutoTiles
	update_bitmask_region (pos1 - Vector2(4,4), pos1 + Vector2(4,4))
	emit_signal("map_update")
