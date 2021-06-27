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

func _unhandled_input(event):
	if event.is_pressed():
		if Input.is_action_pressed("ui_f"):
			interact()
		elif Input.is_action_pressed("ui_r"):
			examine()
		elif Input.is_action_pressed("ui_q"):
			UpdateParameter(-10, HP, "HP")
		elif Input.is_action_pressed("ui_e"):
			UpdateParameter(10, HP, "HP")
		elif Input.is_action_pressed("ui_d") || Input.is_action_pressed("ui_a") || Input.is_action_pressed("ui_s") || Input.is_action_pressed("ui_w"):
			look_on_grid.x = Input.get_action_strength("ui_d") - Input.get_action_strength("ui_a")
			if look_on_grid.x == 0: 
				look_on_grid.y = Input.get_action_strength("ui_s") - Input.get_action_strength("ui_w")
			else:
				look_on_grid.y = 0
			move(look_on_grid)

func move(look_on_grid):
	$RayCast2D.cast_to = look_on_grid * grid_size
	$RayCast2D.force_raycast_update()
	$Sprite.rotation = look_on_grid.angle()
	if !$RayCast2D.is_colliding():
		position += look_on_grid * grid_size
	get_node("../Camera2D").position = position

func interact():
	var Text = $RayCast2D.get_collider()
	if Text != null:
		TextOut.text += "It's a %s\n" % Text.name
		if Text.name == "Exit":
			TextOut.text += "Do you want to go?\n"
			get_node("../../../../../ActionMenu/Actions/Q").text = "Yes"
			get_node("../../../../../ActionMenu/Actions/W").text = "No"
			if Input.is_action_pressed("ui_q") or get_node("../../../../../ActionMenu/Actions/Q").pressed:
				ChangeLocation()
#			elif Input.is_action_pressed("ui_w") or get_node("../../../../../ActionMenu/Actions/W").pressed:
			get_node("../../../../../ActionMenu/Actions/Q").text = "Q"
			get_node("../../../../../ActionMenu/Actions/W").text = "W"
	else:
		TextOut.text += "There are nothing\n"

func examine():
	var Text = get_overlapping_areas()
	if Text.size() > 0:
		var Text_full = ""
		for part in Text:
			Text_full = Text_full + " and " + part.name
		TextOut.text += "There are a " + Text_full.right(5) + "\n"
	else:
		TextOut.text += "There are nothing\n" 

func _on_F_button_down():
	interact()

func _on_D_button_down():
	look_on_grid = Vector2.RIGHT
	move(look_on_grid)

func _on_W_button_down():
	look_on_grid = Vector2.UP
	move(look_on_grid)

func _on_A_button_down():
	look_on_grid = Vector2.LEFT
	move(look_on_grid)

func _on_S_button_down():
	look_on_grid = Vector2.DOWN
	move(look_on_grid)

func _on_R_button_down():
	examine()

func _on_Q_button_down():
	UpdateParameter(-10, HP, "HP")

func _on_E_button_down():
	UpdateParameter(10, HP, "HP")

func UpdateParameter(Change, Parameter, ParameterName):
	var MaxParameter = get("Max%s" % ParameterName)
	Parameter = max(min(Parameter + Change, MaxParameter*2),0)
	set(ParameterName, Parameter)
	get_node("../../../../PartyMenu/%s/Parametrs/%s/ColorRect" % [Name, ParameterName]).rect_size.x = 64*Parameter/MaxParameter
	get_node("../../../../PartyMenu/%s/Parametrs/%s/ColorRect2" % [Name, ParameterName]).rect_size.x = 64*Parameter/MaxParameter-64
	get_node("../../../../PartyMenu/%s/Parametrs/%s/Label" % [Name, ParameterName]).text = "%s/%s" % [Parameter, MaxParameter]


func _on_Z_button_down():
	get_node("../../../../PartyMenu/Character1/ScrollContainer/Status").add_icon_item(load("res://Status_atlastexture.tres"))

func ChangeLocation():
	pass
#	position =
#	look_on_grid =
#	get_node("../World").
#	load("res://World2.tscn")
