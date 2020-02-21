extends Area2D

const MOVE_SPEED = 500
var overlapping = null
var talking = false

# Reference to dialouge object - you could also make this a singleton
onready var dialouge = $"../UI/PortraitDialougeExample"

func _ready():
	dialouge.connect("on_dialouge_finished",self,"_dialouge_finished")

func _process(delta) -> void:
	
	if not talking:
		var hor = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var ver = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		position += Vector2(hor,ver).normalized() * delta * MOVE_SPEED
	
	if Input.is_action_just_pressed("ui_accept"):
		if not talking and overlapping != null:
			dialouge.set_dialouge(overlapping.dialouge.split('\n'),true)
			talking = true
		elif talking:
			dialouge.advance_dialouge()


func _dialouge_finished() -> void:
	talking = false


func _on_Player_area_entered(area):
	overlapping = area


func _on_Player_area_exited(area):
	overlapping = null
