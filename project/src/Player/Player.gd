extends KinematicBody2D

const WALK_SPEED = 50
onready var TILE_SIZE = get_node("../../TileMap").TILE_SIZE

export(float) var bomb_delay = 1
export(float) var shot_delay = 1
export(float) var shot_velocity = 150

var velocity = Vector2()
var last_dir = Vector2.UP

func _physics_process(delta):
	## Set Velocity and Facing if arrow key pressed
	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
		last_dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
		last_dir = Vector2.RIGHT
	else:
		velocity.x = 0
	if Input.is_action_pressed("ui_up"):
		velocity.y = -WALK_SPEED
		last_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		velocity.y =  WALK_SPEED
		last_dir = Vector2.DOWN
	else:
		velocity.y = 0
	
	## Move and Slide
	velocity = move_and_slide(velocity)
	
	##Drop Bomb if timer expired
	if Input.is_action_pressed("ui_bomb"):
		if $BombTimer.is_stopped():
			var bomb = load("res://src/Attacks/Bomb.tscn")
			var instance = bomb.instance()
			get_node("..").add_child(instance)
			##Place Bomb on grid
			instance.set_global_position((self.get_global_position()/TILE_SIZE).floor()*TILE_SIZE + Vector2(TILE_SIZE/2,TILE_SIZE/2))
			$BombTimer.start(bomb_delay)
	
	##Shoot if timer expired	
	if Input.is_action_pressed("ui_shot"):
		if $ShotTimer.is_stopped():
			var wave : RigidBody2D = load("res://src/Attacks/Wave.tscn").instance()
			wave.init(last_dir,self)
			wave.set_global_position(self.get_global_position())
			## Set Shot Direction
			if last_dir.x == 1:
				wave.set_rotation_degrees(0)
			elif last_dir.x == -1:
				wave.set_rotation_degrees(180)
			elif last_dir.y == 1:
				wave.set_rotation_degrees(90)
			elif last_dir.y == -1:
				wave.set_rotation_degrees(-90)
			wave.apply_impulse(Vector2(),last_dir*shot_velocity)
			get_node("../../Projectiles").add_child(wave)
			$ShotTimer.start(shot_delay)
		
func hit(pos : Vector2):
	pass
