extends Node2D

const wave = preload("res://src/Attacks/Wave.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var projectiles = get_parent()
export(float) var wave_speed = 150
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	##Spawn 4 directional waves
	var up : RigidBody2D = wave.instance()
	var down : RigidBody2D = wave.instance()
	var left : RigidBody2D = wave.instance()
	var right : RigidBody2D = wave.instance()
	
	## Assign direction to waves
	up.init(Vector2(0,-1),self)
	down.init(Vector2(0,1),self)
	left.init(Vector2(-1,0),self)
	right.init(Vector2(1,0),self)
	
	##Rotate waves and position on bomb
	up.set_global_position(self.get_global_position())
	up.set_rotation_degrees(-90)
	down.set_global_position(self.get_global_position())
	down.set_rotation_degrees(90)
	left.set_global_position(self.get_global_position())
	left.set_rotation_degrees(180)
	right.set_global_position(self.get_global_position())
	
	##Give waves velocity
	up.apply_impulse(Vector2(),Vector2.UP*wave_speed)
	down.apply_impulse(Vector2(),Vector2.DOWN*wave_speed)
	left.apply_impulse(Vector2(),Vector2.LEFT*wave_speed)
	right.apply_impulse(Vector2(),Vector2.RIGHT*wave_speed)
	
	##Add waves to projectiles List
	projectiles.add_child(up)
	projectiles.add_child(down)
	projectiles.add_child(left)
	projectiles.add_child(right)
	
	##Deleta bomb
	self.queue_free()
