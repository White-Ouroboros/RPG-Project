extends Area2D

onready var TextOut = get_node("../../../../TextMenu/ScrollContainer/RichTextLabel")
export var grid_size = 64
var look_on_grid: Vector2

var Name = "Character1"
var HP
var MaxHP
var MP
var MaxMP
var ST
var MaxST
var ERO
var MaxERO

var AllButtonNames = ["Q", "W", "E", "R", "A", "S", "D", "F", "Z", "X", "C", "V"]
signal _on_Q_button_down
signal _on_W_button_down
signal _on_E_button_down
signal _on_R_button_down
signal _on_A_button_down
signal _on_S_button_down
signal _on_D_button_down
signal _on_F_button_down
signal _on_Z_button_down
signal _on_X_button_down
signal _on_C_button_down
signal _on_V_button_down

enum {EXPLORE, CHOICE, BATTLE}
var MenuState = EXPLORE

signal UpdateCamera
var Map
signal UpdateWorld

var Enemy

func _ready():
	position = position.snapped(Vector2.ONE * grid_size)
	position -= Vector2.ONE * grid_size/2
	$RayCast2D.cast_to = Vector2(0, 0)
	HP = 100
	MaxHP = 100
	MP = 100
	MaxMP = 100
	ST = 0
	MaxST = 100
	ERO = 0
	MaxERO = 100
	UpdateParameter(0, HP, "HP")
	UpdateParameter(0, MP, "MP")
	UpdateParameter(0, ST, "ST")
	UpdateParameter(0, ERO, "ERO")
	get_node("../Camera2D").position = position
	for ButtonName in AllButtonNames:
		self.connect("_on_%s_button_down" % ButtonName, self, "_on_%s_button_down" % ButtonName)
	MenuUpdate()
	Map = get_node("../World")

func _unhandled_input(event):
	if event.is_pressed():
		for ButtonName in AllButtonNames:
			if Input.is_action_pressed("ui_%s" % ButtonName) and get_node("../../../../../ActionMenu/Actions/%s" % ButtonName).disabled == false:
				get_node("../../../../../ActionMenu/Actions/%s" % ButtonName).pressed = true
				emit_signal("_on_%s_button_down" % ButtonName)

func _on_Q_button_down():
	match MenuState:
		EXPLORE:
			UpdateParameter(-10, HP, "HP")
		CHOICE:
			ChangeLocation()
			MenuState = EXPLORE
			MenuUpdate()
		BATTLE:
			Enemy.queue_free()
			MenuState = EXPLORE
			MenuUpdate()

func _on_W_button_down():
	match MenuState:
		EXPLORE:
			look_on_grid = Vector2.UP
			move(look_on_grid)
		CHOICE:
			MenuState = EXPLORE
			MenuUpdate()
			emit_signal("UpdateWorld")

func _on_E_button_down():
	match MenuState:
		EXPLORE:
			UpdateParameter(10, HP, "HP")
		BATTLE:
			Enemy.GhostFrames = 5
			Enemy.ModulateColor()
			MenuState = EXPLORE
			MenuUpdate()

func _on_R_button_down():
	examine(false)

func _on_A_button_down():
	look_on_grid = Vector2.LEFT
	move(look_on_grid)

func _on_S_button_down():
	look_on_grid = Vector2.DOWN
	move(look_on_grid)

func _on_D_button_down():
	look_on_grid = Vector2.RIGHT
	move(look_on_grid)

func _on_F_button_down():
	interact()

func _on_Z_button_down():
	get_node("../../../../PartyMenu/Character1/ScrollContainer/Status").add_icon_item(load("res://Status_atlastexture.tres"))

func _on_X_button_down():
	pass # Replace with function body.

func _on_C_button_down():
	pass # Replace with function body.

func _on_V_button_down():
	pass # Replace with function body.

func move(look_on_grid, check = true):
	if check:
		$RayCast2D.cast_to = look_on_grid * grid_size
		$RayCast2D.force_raycast_update()
	$Sprite.rotation = look_on_grid.angle()
	if !$RayCast2D.is_colliding() or check == false:
		position += look_on_grid * grid_size
		get_node("../Camera2D").position = position
		examine(true)
		emit_signal("UpdateWorld")

func interact():
	var Text = $RayCast2D.get_collider()
	if Text != null:
		TextOut.text += "It's a %s\n" % Text.name
		if Text.name == "Exit":
			TextOut.text += "Do you want to go?\n"
			MenuState = CHOICE
			var Names = ["Q", "W"]
			var Texts = ["Yes", "No"]
			MenuUpdate(Names, Texts)
	else:
		TextOut.text += "There are nothing\n"
		emit_signal("UpdateWorld")

func examine(Auto):
	var Text = get_overlapping_areas()
	if Auto:
		pass
	else:
		if Text.size() > 0:
			TextOut.text += "There are a %s\n" % Text[0].name
		else:
			TextOut.text += "There are nothing\n"
		emit_signal("UpdateWorld")

func UpdateParameter(Change, Parameter, ParameterName):
	var MaxParameter = get("Max%s" % ParameterName)
	Parameter = max(min(Parameter + Change, MaxParameter*2),0)
	set(ParameterName, Parameter)
	get_node("../../../../PartyMenu/%s/Parametrs/%s/ColorRect" % [Name, ParameterName]).rect_size.x = 64*Parameter/MaxParameter
	get_node("../../../../PartyMenu/%s/Parametrs/%s/ColorRect2" % [Name, ParameterName]).rect_size.x = 64*Parameter/MaxParameter-64
	get_node("../../../../PartyMenu/%s/Parametrs/%s/Label" % [Name, ParameterName]).text = "%s/%s" % [Parameter, MaxParameter]

func ChangeLocation():
	var Exit = Map.get_node("Exit")
	Map.queue_free()
	var scene = load("res://%s.tscn" % Exit.Destination).instance()
	get_node("..").add_child(scene)
	Map = scene
	
	position = scene.get_node("Exit").position + position - Exit.position.snapped(Vector2.ONE * grid_size)
	position = position.snapped(Vector2.ONE * grid_size)
	position -= Vector2.ONE * grid_size/2
	move(Exit.Destinationlook_on_grid, false)
	
	emit_signal("UpdateCamera", scene)

func BlockButtons(Names, Texts):
	var i = 0
	for ButtonName in Names:
		get_node("../../../../../ActionMenu/Actions/%s" % ButtonName ).disabled = false
		get_node("../../../../../ActionMenu/Actions/%s" % ButtonName ).text = Texts[i]
		i += 1
	var AllButtonNames2 = AllButtonNames.duplicate(true)
	for ButtonName in Names:
		AllButtonNames2.erase(ButtonName)
	for ButtonName in AllButtonNames2:
		get_node("../../../../../ActionMenu/Actions/%s" % ButtonName ).disabled = true
		get_node("../../../../../ActionMenu/Actions/%s" % ButtonName ).text = ""

func MenuUpdate(Names = [], Texts = []):
	match MenuState:
		EXPLORE:
			Names = ["Q", "W", "E", "R", "A", "S", "D", "F"]
			Texts = ["Q", "W", "E", "R", "A", "S", "D", "F"]
			BlockButtons(Names, Texts)
		CHOICE:
			BlockButtons(Names, Texts)
		BATTLE:
			Names = ["Q", "W", "E"]
			Texts = ["Win", "Lose", "Run"]
			BlockButtons(Names, Texts)

func _on_BeginBattle(EnemyAll):
	MenuState = BATTLE
	MenuUpdate()
	Enemy = EnemyAll
