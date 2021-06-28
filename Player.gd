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

func _unhandled_input(event):
	if event.is_pressed():
		for ButtonName in AllButtonNames:
			if Input.is_action_pressed("ui_%s" % ButtonName):
				emit_signal("_on_%s_button_down" % ButtonName)
				get_node("../../../../../ActionMenu/Actions/%s" % ButtonName).pressed = true

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
			var Names = ["Q", "W"]
			BlockButtons(Names, true, true)
			while !(get_node("../../../../../ActionMenu/Actions/Q").pressed or get_node("../../../../../ActionMenu/Actions/W").pressed):
				if get_node("../../../../../ActionMenu/Actions/Q").pressed:
					BlockButtons(Names, false, true)
					ChangeLocation()
				elif get_node("../../../../../ActionMenu/Actions/W").pressed:
					BlockButtons(Names, false, true)
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

func _on_Z_button_down():
	get_node("../../../../PartyMenu/Character1/ScrollContainer/Status").add_icon_item(load("res://Status_atlastexture.tres"))

func _on_X_button_down():
	pass # Replace with function body.

func _on_C_button_down():
	pass # Replace with function body.

func _on_V_button_down():
	pass # Replace with function body.

func UpdateParameter(Change, Parameter, ParameterName):
	var MaxParameter = get("Max%s" % ParameterName)
	Parameter = max(min(Parameter + Change, MaxParameter*2),0)
	set(ParameterName, Parameter)
	get_node("../../../../PartyMenu/%s/Parametrs/%s/ColorRect" % [Name, ParameterName]).rect_size.x = 64*Parameter/MaxParameter
	get_node("../../../../PartyMenu/%s/Parametrs/%s/ColorRect2" % [Name, ParameterName]).rect_size.x = 64*Parameter/MaxParameter-64
	get_node("../../../../PartyMenu/%s/Parametrs/%s/Label" % [Name, ParameterName]).text = "%s/%s" % [Parameter, MaxParameter]

func ChangeLocation():
	var Exit = get_node("../World").get_node("Exit")
	position = Exit.DestinationPosition + position - Exit.position
	look_on_grid = Exit.Desinationlook_on_grid
	get_node("../World").queue_delete()
	var scene = preload("res://World2.tscn").instance()
	get_node("..").add_child(scene)

func BlockButtons(Names, Off, Reverse = false):
	if Reverse:
#		var AllButtonNames = ["Q", "W", "E", "R", "A", "S", "D", "F", "Z", "X", "C", "V"]
		for ButtonName in Names:
			AllButtonNames.erase(ButtonName)
		for ButtonName in AllButtonNames:
			get_node("../../../../../ActionMenu/Actions/%s" % ButtonName ).disabled = Off
	else:
		for ButtonName in Names:
			get_node("../../../../../ActionMenu/Actions/%s" % ButtonName ).disabled = Off



