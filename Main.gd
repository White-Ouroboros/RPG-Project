extends Node

onready var camera = $UI/HBoxContainer/Viewport/ViewportContainer/Viewport/Camera2D
onready var world = $UI/HBoxContainer/Viewport/ViewportContainer/Viewport/World

func _ready():
	set_camera_limits()

func set_camera_limits():
	var map_limits = world.get_used_rect()
	var map_cellsize = world.cell_size
	camera.limit_left = map_limits.position.x * map_cellsize.x
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y
