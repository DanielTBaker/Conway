extends KinematicBody2D

var nav = null setget set_nav
var speed = 75
var path = []
var goal = Vector2()
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
var spawn : Vector2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum States {MOVING, KNOCKBACK, BURNING}

var _state : int = States.MOVING
var _random_move = false
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawn =  global_position
	pass # Replace with function body.

func set_nav(new_nav):
	nav = new_nav
	
func update_path(new_goal):
	path = nav.get_simple_path(global_position,new_goal,false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	if _state == States.KNOCKBACK:
		knockback = knockback.move_toward(Vector2.ZERO,100*delta)
		knockback = move_and_slide(knockback)
		if get_slide_count() > 0:
			var hit_player = false
			for i in range(get_slide_count()):
				if get_slide_collision(i).collider.name =='Player' and !hit_player:
					get_slide_collision(i).collider.hit()
					global_position = spawn
					update_path(goal)
					hit_player = !hit_player
				if get_slide_collision(i).collider.name =='TileMap':
					var collision = get_slide_collision(i)
					var tile_map : TileMap = collision.collider
					var cell_id = tile_map.get_cellv(tile_map.world_to_map(collision.position-collision.normal))
					if cell_id in tile_map.water_tiles:
						queue_free()
					if cell_id == tile_map.var_live_id and !(tile_map.world_to_map(collision.position-collision.normal) in tile_map.burning_cells):
						_burn_start(tile_map.world_to_map(collision.position-collision.normal),tile_map)
		if knockback == Vector2.ZERO and _state != States.BURNING:
			_state = States.MOVING
	elif _state == States.MOVING:
		if _random_move:
			var tileMap : TileMap = nav.get_node("TileMap")
			var tileV = tileMap.world_to_map(global_position)
			if velocity == Vector2.ZERO:
				if tileMap.get_cellv(tileV+Vector2.UP) == tileMap.var_dead_id:
					velocity = Vector2.UP
				elif tileMap.get_cellv(tileV+Vector2.RIGHT)  == tileMap.var_dead_id:
					velocity = Vector2.RIGHT
				elif tileMap.get_cellv(tileV+Vector2.DOWN)  == tileMap.var_dead_id:
					velocity = Vector2.DOWN
				elif tileMap.get_cellv(tileV+Vector2.LEFT)  == tileMap.var_dead_id:
					velocity = Vector2.LEFT
				else:
					velocity=Vector2.ZERO
				velocity *= speed
			else:
				var probs = [0,0,0,0]
				var facing: Vector2
				if abs(velocity.x)>=abs(velocity.y):
					facing= Vector2.RIGHT*sign(velocity.x)
				else:
					facing= Vector2.DOWN*sign(velocity.y)
				
				if fmod(floor((facing*global_position).length()),16)==8:
					var turn = Vector2(1-abs(facing.x),1-abs(facing.y))
					if tileMap.get_cellv(tileV+facing)  == tileMap.var_dead_id:
						probs[0] = 40
					if tileMap.get_cellv(tileV+turn)  == tileMap.var_dead_id:
						probs[1] = 25
					if tileMap.get_cellv(tileV-facing)  == tileMap.var_dead_id:
						probs[2] = 25
					if tileMap.get_cellv(tileV-turn)  == tileMap.var_dead_id:
						probs[3] = 10
					var probs_cumsum = [probs[0],probs[0]+probs[1],probs[0]+probs[1]+probs[2],probs[0]+probs[1]+probs[2]+probs[3]]
					if probs_cumsum[3]==0:
						velocity = Vector2.ZERO
					else:
						var rand = rng.randi_range(0,probs[0]+probs[1]+probs[2]+probs[3]-1)
						if rand < probs_cumsum[0]:
							velocity = facing
						elif rand < probs_cumsum[1]:
							velocity = turn
						elif rand < probs_cumsum[2]:
							velocity = - facing
						else:
							velocity = -turn
					velocity *= speed
		else:
			if path.size()>1:
				var d = global_position.distance_to(path[0])
				if d>2:
					velocity = speed*(path[0]-global_position)/d	
				else:
					velocity = Vector2.ZERO
					path.remove(0)
			else:
				velocity = Vector2.ZERO
		velocity = move_and_slide(velocity)
		if get_slide_count() > 0:
			var hit_player = false
			for i in range(get_slide_count()):
				if get_slide_collision(i).collider.name =='Player' and !hit_player:
					get_slide_collision(i).collider.hit()
					global_position = spawn
					update_path(goal)
					hit_player = !hit_player

func _burn_start(cellv : Vector2, tileMap : TileMap):
	_state = States.BURNING
	tileMap.burning_cells.append(cellv)
	$CollisionShape2D.disabled = true
	move_and_collide(tileMap.map_to_world(cellv)+Vector2.ONE*tileMap.TILE_SIZE/2-global_position)
	yield(get_tree().create_timer(2.0), "timeout")
	tileMap.burning_cells.erase(cellv)
	$CollisionShape2D.disabled = false
	tileMap.hit(cellv,cellv)
	_state=States.MOVING
	update_path(goal)
	

func hit(dir):
	if _state == States.MOVING:
		knockback = 100*dir
		_state = States.KNOCKBACK

