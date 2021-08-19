extends Area2D

export var grid_size = 64
var look_on_grid: Vector2

signal BeginBattle

var MoveDirection

var MoveDirections = {1: Vector2.RIGHT,
			3: Vector2.LEFT,
			0: Vector2.UP,
			2: Vector2.DOWN}

var HP
var MaxHP
var MP
var MaxMP
var ST
var MaxST
var ERO
var MaxERO

var GhostFrames
onready var Player = get_node("/root/Main/UI/HBoxContainer/Viewport/ViewportContainer/Viewport/Player")

onready var RayCast = $RayCast2D
#onready var RayCast = $Area2D/RayCast2D
enum {WANDER, CHASE}
var Behavior = WANDER

export var ScaleInt = 5

func _ready():
	$Area2D/CollisionShape2D.scale = Vector2(ScaleInt * 2, ScaleInt *2 )
	randomize()
	position = position.snapped(Vector2.ONE * grid_size)
	position -= Vector2.ONE * grid_size/2
	$RayCast2D.cast_to = Vector2(0, 0)
	MoveDirection = MoveDirections[randi()%4]
	get_node("/root/Main").connect("UpdateWorld", self, "_on_UpdateWorld")
	self.connect("BeginBattle", Player, "_on_BeginBattle")
	GhostFrames = 0

func move():
	if GhostFrames == 0:
		var random_number = randf()
		if random_number >= 0.2:
			if random_number < 0.5:
				look_on_grid = MoveDirections[randi()%4]
			else:
				look_on_grid = MoveDirection
			var positionStart = position
			while positionStart == position:
				$RayCast2D.cast_to = look_on_grid * grid_size
				$RayCast2D.force_raycast_update()
				if !$RayCast2D.is_colliding():
					$Sprite.rotation = look_on_grid.angle()
					position += look_on_grid * grid_size
					MoveDirection = look_on_grid
				else:
					look_on_grid = MoveDirections[randi()%4]
	else:
		GhostFrames -= 1
		if GhostFrames == 0:
			ModulateColor()

func _on_UpdateWorld():
	if Behavior == WANDER:
		LookForPlayer()
		move()
	else:
		Chase()

func _on_Area2D2_area_entered(area):
	if area.name == "Player":
		emit_signal("BeginBattle", self)

func ModulateColor():
	if GhostFrames == 0:
		$Sprite.modulate = Color(1, 1, 1, 1)
		$Area2D2/CollisionPolygon2D.disabled = false
		$CollisionShape2D.disabled = false
	else:
		$Sprite.modulate = Color(1, 1, 1, 0.5)
		$Area2D2/CollisionPolygon2D.disabled = true
		$CollisionShape2D.disabled = true

func LookForPlayer(Signal = false):
	if Signal or $Area2D.get_overlapping_areas().find(Player) > -1:
		RayCast.cast_to = Player.position
		if RayCast.is_colliding():
#			var a = RayCast.get_collider()
			if RayCast.get_collider() == Player:
				Behavior = CHASE

func Chase():
	pass

func _on_Area2D_area_entered(area):
	if area == Player:
		LookForPlayer(true)
