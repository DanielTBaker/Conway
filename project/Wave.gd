extends KinematicBody2D

const MOVE_SPEED = 150
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dir : Vector2 = Vector2.ZERO
var src
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(facing : Vector2, source):
	dir = facing
	src=source
	
func _physics_process(delta):
	move_and_slide(dir*MOVE_SPEED)
	var hit = false
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		print(collision.collider.name)
		if not collision.collider == src:
			collision.collider.hit(collision.position+dir)
			hit = true
	if hit:	
		self.queue_free()
