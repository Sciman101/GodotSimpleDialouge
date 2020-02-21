extends "res://Scripts/DialougeController.gd"

var face_cache = {} # Used to save faces that had to be loaded previously

onready var portrait_rect = $DialougePanel/HBoxContainer/PortraitContainer/Portrait

var tween : Tween

func _ready() -> void:
	# Create tween
	tween = Tween.new()
	add_child(tween)


# This is a dialouge controller with functions defined to change the face of a portrait
func show_face(fname:String) -> void:
	portrait_rect.visible = true
	var tex = null
	if face_cache.has(fname):
		tex = face_cache[fname]
	else:
		tex = load(fname)
		face_cache[fname] = tex
	portrait_rect.texture = tex
	
	# Play tween
	tween.stop_all()
	tween.interpolate_property(portrait_rect,"rect_scale",Vector2(0.8,1.2),Vector2(1.1,0.9),0.05,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.interpolate_property(portrait_rect,"rect_scale",Vector2(1.1,0.9),Vector2(1,1),0.1,Tween.TRANS_CIRC,Tween.EASE_IN,0.05)
	tween.start()
