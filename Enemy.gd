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

enum {WANDER, CHASE}
var Behavior = WANDER

var Look = false
export var ScaleInt = 5

var PlayerPosition = Vector2(0, 0)

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

func _on_UpdateWorld():
	if Look:
		LookForPlayer()
	if GhostFrames == 0:
		if Behavior == WANDER:
			move()
		else:
			Chase()
	else:
		GhostFrames -= 1
		if GhostFrames == 0:
			ModulateColor()
	if Look:
		LookForPlayer()

func _on_Area2D2_area_entered(area):
	if area.name == "Player":
		emit_signal("BeginBattle", self)

func ModulateColor():
	if GhostFrames == 0:
		$Sprite.modulate.a = 1
		$Area2D2/CollisionPolygon2D.disabled = false
		$CollisionShape2D.disabled = false
	else:
		$Sprite.modulate.a = 0.5
		$Area2D2/CollisionPolygon2D.disabled = true
		$CollisionShape2D.disabled = true

func LookForPlayer():
	$RayCast2D.cast_to = Player.position - position
	$RayCast2D.force_raycast_update()
	if $RayCast2D.get_collider() == Player:
		Behavior = CHASE
		PlayerPosition = Player.position

func Chase():
	$RayCast2D.cast_to = PlayerPosition - position
	$RayCast2D.force_raycast_update()
	if $RayCast2D.cast_to != Vector2(0, 0):
		if abs($RayCast2D.cast_to.x) >= abs($RayCast2D.cast_to.y):
			$RayCast2D.cast_to.x = abs($RayCast2D.cast_to.x) / $RayCast2D.cast_to.x
			$RayCast2D.cast_to.y = 0
		else:
			$RayCast2D.cast_to.y = abs($RayCast2D.cast_to.y) / $RayCast2D.cast_to.y
			$RayCast2D.cast_to.x = 0
	else:
		$RayCast2D.cast_to = Vector2(0, 0)
	look_on_grid = $RayCast2D.cast_to
	$RayCast2D.cast_to = look_on_grid * grid_size
	$RayCast2D.force_raycast_update()
	
	if $RayCast2D.is_colliding():
		$RayCast2D.cast_to = PlayerPosition - position
		$RayCast2D.force_raycast_update()
		if abs($RayCast2D.cast_to.x) < abs($RayCast2D.cast_to.y):
			$RayCast2D.cast_to.x = abs($RayCast2D.cast_to.x) / $RayCast2D.cast_to.x
			$RayCast2D.cast_to.y = 0
		else:
			$RayCast2D.cast_to.y = abs($RayCast2D.cast_to.y) / $RayCast2D.cast_to.y
			$RayCast2D.cast_to.x = 0
		look_on_grid = $RayCast2D.cast_to
	
	$Sprite.rotation = look_on_grid.angle()
	position += look_on_grid * grid_size
	if position == PlayerPosition:
		Behavior = WANDER

func _on_Area2D_area_entered(area):
	if area == Player:
		Look = true

func _on_Area2D_area_exited(area):
	if area == Player:
		Look = false
