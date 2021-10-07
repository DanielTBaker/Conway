extends KinematicBody2D

onready var TILE_SIZE = get_node("../../TileMap").TILE_SIZE

const MAX_HEALTH = 3

export(float) var bomb_delay = 1
export(float) var shot_delay = .5
export(float) var shot_velocity = 150
export(float) var WALK_SPEED = 50
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get('parameters/playback')
onready var menu = get_node("../../Menu")

var health

func _ready():
	health = MAX_HEALTH
	var health_bar = menu.get_node("VBoxContainer/HealthBar")
	for i in range(MAX_HEALTH):
		var heart : TextureRect = TextureRect.new()
		heart.texture = load("res://GFX/heart_full.png")
		health_bar.add_child(heart)
		
		

var velocity = Vector2()
var last_dir = Vector2.UP

func _physics_process(delta):
	if not animationState.get_current_node()=="Damaged":
		## Set Velocity and Facing if arrow key pressed
		if Input.is_action_pressed("ui_left"):
			velocity = Vector2.LEFT*WALK_SPEED
			last_dir = Vector2.LEFT
			animationTree.set("parameters/Idle/blend_position",last_dir)
			animationTree.set("parameters/Walk/blend_position",last_dir)
			animationState.travel("Walk")
		elif Input.is_action_pressed("ui_right"):
			velocity = Vector2.RIGHT*WALK_SPEED
			last_dir = Vector2.RIGHT
			animationTree.set("parameters/Idle/blend_position",last_dir)
			animationTree.set("parameters/Walk/blend_position",last_dir)
			animationState.travel("Walk")
		elif Input.is_action_pressed("ui_up"):
			velocity = Vector2.UP*WALK_SPEED
			last_dir = Vector2.UP
			animationTree.set("parameters/Idle/blend_position",last_dir)
			animationTree.set("parameters/Walk/blend_position",last_dir)
			animationState.travel("Walk")
		elif Input.is_action_pressed("ui_down"):
			velocity =  Vector2.DOWN*WALK_SPEED
			last_dir = Vector2.DOWN
			animationTree.set("parameters/Idle/blend_position",last_dir)
			animationTree.set("parameters/Walk/blend_position",last_dir)
			animationState.travel("Walk")
		else:
			velocity = Vector2.ZERO
			animationState.travel("Idle")
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
				wave.set_global_position(self.get_global_position()+last_dir*10)
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
		
func hit():
	health -=1
	if health ==0:
		get_tree().reload_current_scene()
	else:
		animationState.travel("Damaged")
		var health_bar = menu.get_node("VBoxContainer/HealthBar")
		for i in range(health_bar.get_child_count()):
			health_bar.get_child(i).visible = i < health
