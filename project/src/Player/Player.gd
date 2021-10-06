extends KinematicBody2D

const WALK_SPEED = 50
const TILE_SIZE = 16

var velocity = Vector2()
var last_dir = Vector2(-1,0)

func _physics_process(delta):
	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
		last_dir = Vector2(-1,0)
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
		last_dir = Vector2(1,0)
	else:
		velocity.x = 0
	if Input.is_action_pressed("ui_up"):
		velocity.y = -WALK_SPEED
		last_dir = Vector2(0,-1)
	elif Input.is_action_pressed("ui_down"):
		velocity.y =  WALK_SPEED
		last_dir = Vector2(0,1)
	else:
		velocity.y = 0
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("ui_bomb"):
#		var bomb = load("res://src/Maps/Bomb.tscn")
#		var instance = bomb.instance()
#		get_node("..").add_child(instance)
#		instance.set_global_position((self.get_global_position()/TILE_SIZE).floor()*TILE_SIZE + Vector2(TILE_SIZE/2,TILE_SIZE/2))
		var wave : RigidBody2D = load("res://src/Maps/Wave.tscn").instance()
		wave.init(last_dir,self)
		wave.set_global_position(self.get_global_position())
		if last_dir.x == 1:
			wave.set_rotation_degrees(0)
		elif last_dir.x == -1:
			wave.set_rotation_degrees(180)
		elif last_dir.y == 1:
			wave.set_rotation_degrees(90)
		elif last_dir.y == -1:
			wave.set_rotation_degrees(-90)
		wave.apply_impulse(Vector2(),last_dir*150)
		get_node("../../Projectiles").add_child(wave)
		
func hit(pos : Vector2):
	pass
