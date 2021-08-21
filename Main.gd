extends Node

onready var camera = $UI/HBoxContainer/Viewport/ViewportContainer/Viewport/Camera2D
onready var onreadyworld = $UI/HBoxContainer/Viewport/ViewportContainer/Viewport/World

signal UpdateWorld

func _ready():
	set_camera_limits()

func set_camera_limits(world = onreadyworld):
	var map_limits = world.get_used_rect()
	var map_cellsize = world.cell_size
	camera.limit_left = map_limits.position.x * map_cellsize.x
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y

func _on_Player_UpdateCamera(scene):
	set_camera_limits(scene)

func _on_Player_UpdateWorld():
#	$UI/HBoxContainer/Viewport/ViewportContainer/Viewport/Player.pause_mode = true
	emit_signal("UpdateWorld")
#	$UI/HBoxContainer/Viewport/ViewportContainer/Viewport/Player.pause_mode = false
