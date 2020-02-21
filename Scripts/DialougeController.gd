extends Control

const FUNCTION_PREFIX : String = '#' # Prefix used when we want to use a line of dialouge to print text

signal on_dialouge_advanced()
signal on_dialouge_finished()

onready var dialouge_label = $DialougePanel/HBoxContainer/DialougeLabel
onready var text_reveal_timer = $TextRevealTimer # This timer is used to incrementally reveal text

export(String,MULTILINE) var dialouge_lines # Dialouge to show, line by line

var lines = [] # 

var progressing_text : bool = false
var current_line_index : int = 0

func _ready() -> void:
	# Connect to effect signal method, so certain effects will change text speed
	dialouge_label.connect("effect_signal",self,"_on_effect_signal")
	# Connect signal so the timer will actually advance text
	text_reveal_timer.connect("timeout",self,"_on_TextRevealTimer_timeout")
	# Wait a sec for stuff to load in
	yield(get_tree(),"idle_frame")
	
	# Get dialouge lines from string
	if len(dialouge_lines) > 0:
		set_dialouge(dialouge_lines.split('\n'),true)
	else:
		visible = false


func _on_effect_signal(effect) -> void:
	match effect:
		'+':
			text_reveal_timer.wait_time = 0.01
		'=':
			text_reveal_timer.wait_time = .05
		'-':
			text_reveal_timer.wait_time = .2


# Set the dialouge array, and optionally start the dialouge
func set_dialouge(lines:Array,start:bool=false) -> void:
	self.lines = lines
	current_line_index = -1
	if start:
		advance_dialouge()


# Called when we want to move to the next chunk of dialouge
func advance_dialouge() -> void:
	if progressing_text:
		# Show the entire message
		progressing_text = false
		dialouge_label.visible_characters = -1
	else:
		if current_line_index == lines.size()-1:
			# Last line, hide dialouge box
			visible = false
			emit_signal("on_dialouge_finished")
		else:
			visible = true
			current_line_index += 1
			if lines[current_line_index][0] == FUNCTION_PREFIX:
				# Get command arguments
				var line = lines[current_line_index]
				var args = line.substr(1,len(line)-1).split(' ')
				
				var fname = args[0]
				args.remove(0)
				# Try and call function
				if has_method(fname):
					callv(fname,args)
				else:
					print("Dialouge Error: Trying to call unknown function '%s' (Line %d)" % [fname,current_line_index])
				
				advance_dialouge()
			else:
				dialouge_label.visible_characters = 0
				dialouge_label.text = lines[current_line_index]
				text_reveal_timer.wait_time = .05
				progressing_text = true
				emit_signal("on_dialouge_advanced")


# Called when the timer expires, to show a new character
func _on_TextRevealTimer_timeout():
	if progressing_text:
		var count = dialouge_label.visible_characters
		if count == len(dialouge_label.get_raw_text()):
			progressing_text = false
		else:
			dialouge_label.visible_characters = count+1


# Wrapper for the 'print' method
func dprint(text:String) -> void:
	print(text)
