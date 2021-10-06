extends RigidBody2D

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
	## Remember direction and source of wave
	dir = facing
	src=source





func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	## Tile Map Collision
	if body.name == "TileMap":
		var perp = Vector2(1-abs(dir.x),1-abs(dir.y))
		var pos1 = body.world_to_map(global_position + 8*dir - 8*perp)
		var pos2 = body.world_to_map(global_position + 8*dir + 8*perp)
		body.hit(pos1,pos2)
		self.queue_free()
