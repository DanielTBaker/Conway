extends Node2D

const wave = preload("res://src/Maps/Wave.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var projectiles = get_node("../../Projectiles")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	var up : KinematicBody2D = wave.instance()
	var down : KinematicBody2D = wave.instance()
	var left : KinematicBody2D = wave.instance()
	var right : KinematicBody2D = wave.instance()
	up.init(Vector2(0,-1))
	down.init(Vector2(0,1))
	left.init(Vector2(-1,0))
	right.init(Vector2(1,0))
	
	up.set_global_position(self.get_global_position())
	up.set_rotation_degrees(-90)
	down.set_global_position(self.get_global_position())
	down.set_rotation_degrees(90)
	left.set_global_position(self.get_global_position())
	left.set_rotation_degrees(180)
	right.set_global_position(self.get_global_position())
	projectiles.add_child(up)
	projectiles.add_child(down)
	projectiles.add_child(left)
	projectiles.add_child(right)
	self.queue_free()
