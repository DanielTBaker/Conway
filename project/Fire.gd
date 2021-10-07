extends KinematicBody2D

var nav = null setget set_nav
var speed = 100
var path = []
var goal = Vector2()
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
var spawn : Vector2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
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
	knockback = knockback.move_toward(Vector2.ZERO,100*delta)
	if knockback == Vector2.ZERO:
		if path.size()>1:
			var d = global_position.distance_to(path[0])
			if d>2:
				velocity = speed*(path[0]-global_position)/d	
			else:
				velocity = Vector2.ZERO
				path.remove(0)
		velocity = move_and_slide(velocity)
	else:
		print(knockback)
		knockback = move_and_slide(knockback)
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			if get_slide_collision(i).collider.name =='Player':
				get_slide_collision(i).collider.hit()
				global_position = spawn
				update_path(goal)
				break


func hit(dir):
	knockback = 100*dir

