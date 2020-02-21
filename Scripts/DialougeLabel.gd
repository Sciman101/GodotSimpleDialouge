extends Control
tool

const FORMATTING_CHAR = '$' # Character used to indicate a formatting character
const NEWLINE_CHAR = '#' # Character used to indicate a newline

signal effect_signal(c) # Signal emitted when a formatting code in 'SIGNAL_EFFECTS' is drawn

# Define effect parameters
const COLORS = {
	'0':Color.white,
	'1':Color.red,
	'2':Color.orange,
	'3':Color.yellow,
	'4':Color.green,
	'5':Color.blue,
	'6':Color.indigo,
	'7':Color.violet,
	'8':Color.black,
	'9':Color.brown,
} # Define color codes
const ANIMATED_EFFECTS = ['w','s','r'] # This array defines any effect characters that require constant screen redraws
const SIGNAL_EFFECTS = ['+','-','='] # This array defines any effect which should trigger a signal


export(String, MULTILINE) var text : String setget set_text
export(int) var visible_characters : int = -1 setget set_visible_characters
export(Font) var font : Font setget set_font


var text_without_formatting : String setget ,get_raw_text # The text to display without any formatting visible
var text_formatting = {} # A dictionary of formatting tags - keys are indicies in the text_without_formatting
						 # string, and values are strings containing multiple formatting characters

var emitted_signals = [] # Used to track the indices of which signal effects have already been emitted

var use_animated_effects : bool = false # If true, the text will be redrawn each frame
var animation_time : float = 0 # Timer used for text animation


# Only redraw text in _process if we are using any effects which require constant animation
func _process(delta) -> void:
	if use_animated_effects:
		animation_time = fmod(animation_time+delta,1)
		update()


# Draw the text
func _draw() -> void:
	
	# Initialize text drawing parameters
	var cursor = Vector2.DOWN * font.get_height()
	var color = Color.white
	var effect = ''
	
	# Get number of characters to display
	var count = len(text_without_formatting) if visible_characters == -1 else visible_characters
	
	
	# Loop over characters
	for i in range(count):
		
		if text_formatting.has(i): # Check if this string position has formatting
			for f in text_formatting[i]: # Loop over all formatting chars
				if f == '_': # Clear formatting
					color = Color.white
					effect = '_'
				elif f == NEWLINE_CHAR: # Insert newline
					cursor.y += font.get_height()
					cursor.x = 0
				elif COLORS.has(f): # Set color
					color = COLORS[f]
				elif ANIMATED_EFFECTS.has(f): # Set effect
					effect = f
				elif SIGNAL_EFFECTS.has(f): # Emit signal effect
					if not emitted_signals.has(i):
						emitted_signals.append(i)
						emit_signal("effect_signal",f)
		
		# Apply special effects
		var offset = Vector2.ZERO
		if effect == 'w': # Wavy text
			offset = Vector2.UP*sin(i+animation_time*PI*2)*4
		elif effect == 's': # Shaky text
			offset = Vector2(rand_range(-1,1),rand_range(-1,1))
		elif effect == 'r': # Rainbow
			color = Color.from_hsv(fmod((float(i)/10)+animation_time,1),1,1)
		
		# Draw character
		var w = draw_char(font,cursor+offset,text_without_formatting[i],'',color)
		# Move cursor
		cursor.x += w


func get_raw_text() -> String:
	return text_without_formatting

# Generate the info needed to display the formatted string properly
func generate_text_formatting() -> void:
	
	# Clear existing info
	text_formatting.clear()
	text_without_formatting = ""
	use_animated_effects = false
	emitted_signals.clear()
	
	var real_text_pos : int = 0
	var line_width : float = 0 # Width of the current line
	var last_space_pos : int = 0 # Index of the last space
	
	var i = 0
	while i < len(text):
		
		# Handle spaces
		if text[i] == ' ':
			last_space_pos = real_text_pos
		
		# Handle formatting chaarcters
		if text[i] == FORMATTING_CHAR and i < len(text)-1:
			# Read the next character
			var f = str(text[i+1])
			
			# Check if we need to enable animated effects
			if not use_animated_effects and f in ANIMATED_EFFECTS:
				use_animated_effects = true
			add_effect_at(real_text_pos,f)
			
			# Manually remove newlines
			if f == NEWLINE_CHAR:
				line_width = 0
			
			i+=1
		
		# Handle regular characters
		else:			
			var c = text[i]
			# Add text to string
			text_without_formatting += c
			if font:
				# Manually check line width and add new characters when necessary
				line_width += font.get_string_size(c).x
				if line_width >= rect_size.x:
					line_width = 0
					add_effect_at(last_space_pos+1,NEWLINE_CHAR)
			real_text_pos += 1
		i += 1


# Add an effect identifier at a given string position
func add_effect_at(pos:int, effect) -> void:
	if text_formatting.has(pos):
		text_formatting[pos] += effect
	else:
		text_formatting[pos] = effect


func set_text(txt:String) -> void:
	text = txt
	generate_text_formatting()
	update()


func set_visible_characters(count:int) -> void:
	visible_characters = clamp(count,-1,len(text_without_formatting))
	update()


# Update the font and redraw everything
func set_font(fnt:Font) -> void:
	font = fnt
	generate_text_formatting() # We call this since line lengths may change
	update()
