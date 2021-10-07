extends Navigation2D


onready var enemies = get_node("../Enemies")
onready var player = get_node("../Player")
onready var timer = $NavTimer

export(float) var update_timer = .1


func _ready():
	for enemy in enemies.get_children():
		enemy.set_nav(self)
		enemy.update_path(player.global_position)
	timer.start(update_timer)



func _on_NavTimer_timeout():
	for enemy in enemies.get_children():
		enemy.set_nav(self)
		enemy.update_path(player.global_position)
	timer.start(update_timer)


func _on_TileMap_map_update():
	for enemy in enemies.get_children():
		enemy.set_nav(self)
		enemy.update_path(player.global_position)
