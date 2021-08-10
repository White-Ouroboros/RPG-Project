extends Area2D

export var grid_size = 64
var look_on_grid: Vector2

signal BeginBattle

var MoveDirection
#enum MoveDirections {Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN}
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

func _ready():
	randomize()
	position = position.snapped(Vector2.ONE * grid_size)
	position -= Vector2.ONE * grid_size/2
	$RayCast2D.cast_to = Vector2(0, 0)
	MoveDirection = MoveDirections[randi()%4]
	get_node("/root/Main").connect("UpdateWorld", self, "_on_UpdateWorld")
	self.connect("BeginBattle", get_node("/root/Main/UI/HBoxContainer/Viewport/ViewportContainer/Viewport/Player"), "_on_BeginBattle")
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
	move()

func _on_Enemy_area_entered(area):
	if area.name == "Player":
		emit_signal("BeginBattle", self)

func ModulateColor():
	if GhostFrames == 0:
		$Sprite.modulate = Color(1, 1, 1, 1)
		$CollisionShape2D.disabled = false
		$CollisionShape2D2.disabled = false
	else:
		$Sprite.modulate = Color(1, 1, 1, 0.5)
		$CollisionShape2D.disabled = true
		$CollisionShape2D2.disabled = true
