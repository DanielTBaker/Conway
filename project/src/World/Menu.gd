extends ColorRect

onready var player = get_node("../Player")
onready var enemies = get_node("../Enemies")
onready var tilemap

var _random_move = false

func _ready():
	for button in $VBoxContainer/HBoxContainer3/B.get_children():
		button.connect("pressed",self,"_on_birth_pressed")
	for button in $VBoxContainer/HBoxContainer3/D.get_children():
		button.connect("pressed",self,"_on_death_pressed")

func _on_EnemySpeed_value_changed(value):
	for enemy in enemies.get_children():
		enemy.speed = value
	var label : Label = $VBoxContainer/ESLabel
	label.text = "Enemy Speed: " + str(value)
	$VBoxContainer/EnemySpeed.release_focus()

func _on_PlayerSpeed_value_changed(value):
	player.WALK_SPEED=value
	var label : Label = $VBoxContainer/PSLabel
	label.text = "Player Speed: " + str(value)
	$VBoxContainer/PlayerSpeed.release_focus()


func _on_ShotSpeed_value_changed(value):
	player.shot_velocity=value
	var label : Label = $VBoxContainer/SSLabel
	label.text = "Shot Speed: " + str(value)
	$VBoxContainer/ShotSpeed.release_focus()


func _on_ReloadTime_value_changed(value):
	player.shot_delay = value
	var label : Label = $VBoxContainer/RTLabel
	label.text = "Reload Time: " + str(value)
	$VBoxContainer/ReloadTime.release_focus()


func _on_ConwayTime_value_changed(value):
	tilemap.DELAY = value
	var label : Label = $VBoxContainer/CTLabel
	label.text = "Conway Time: " + str(value)
	$VBoxContainer/ConwayTime.release_focus()

func _on_RandomMove_button_down():
	_random_move = true
	for enemy in enemies.get_children():
		enemy._random_move = true
#	$VBoxContainer/HBoxContainer2/RandomMove.release_focus()

func _on_DirectMove_button_down():
	_random_move = false
	for enemy in enemies.get_children():
		enemy._random_move = false
#	$VBoxContainer/HBoxContainer2/RandomMove.release_focus()


func _on_birth_pressed():
	tilemap.BIRTHS = []
	for i in range(9):
		var button : CheckBox = get_node("VBoxContainer/HBoxContainer3/B/"+str(i))
		if button.pressed:
			tilemap.BIRTHS.append(i)
		

func _on_death_pressed():
	tilemap.DEATHS = []
	for i in range(9):
		var button : CheckBox = get_node("VBoxContainer/HBoxContainer3/D/"+str(i))
		if button.pressed:
			tilemap.DEATHS.append(i)

func _on_Reload_pressed():
	get_parent().unload_level()
	get_parent().load_level("res://src/Maps/Level01.tscn")
	if _random_move:
		_on_RandomMove_button_down()
	else:
		_on_DirectMove_button_down()
	_on_birth_pressed()
	_on_death_pressed()
	_on_ConwayTime_value_changed($VBoxContainer/ConwayTime.value)
	_on_EnemySpeed_value_changed($VBoxContainer/EnemySpeed.value)
