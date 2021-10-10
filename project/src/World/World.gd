extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var enemies = $Enemies
onready var player = $Player
onready var projectiles = $Projectiles
onready var nav = $Nav

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level("res://src/Maps/Level01.tscn")
	pass # Replace with function body.

func load_level(level: String):
	var loader : Level = load(level).instance()
	nav.add_child(loader)
	loader.load_level()
	$Menu.tilemap = loader
	nav.tilemap = loader
	loader.name = "TileMap"


func unload_level():
	for enemy in enemies.get_children():
		enemy.queue_free()
		enemies.remove_child(enemy)
	for proj in projectiles.get_children():
		proj.queue_free()
		projectiles.remove_child(proj)
	nav.tilemap.name = 'OldMap'
	nav.tilemap.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
