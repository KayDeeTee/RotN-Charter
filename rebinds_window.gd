extends GridContainer

class rebind_wrapper:
	var rebind
	var variable_name
	
	var label
	var key
	var button
	
	func _init( rebinder, var_name : String ):
		rebind = rebinder
		variable_name = var_name
		
		label = Label.new()
		label.text = var_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
		key = Label.new()
		key.text = OS.get_keycode_string( Keybinds.get(var_name) )
	
		button = Button.new()
		button.text = OS.get_keycode_string( Keybinds.get(var_name) )
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		button.pressed.connect( start_rebind )
		
	func start_rebind():
		rebind.current_rebind = self
		
var current_rebind = null :
	set(v):
		if current_rebind != null:
			current_rebind.button.disabled = false
		current_rebind = v
		if current_rebind != null:
			current_rebind.button.disabled = true
		

@export var window : Window

var rebind_wrappers = []
func create_rebind_button( var_name : String ):
	var rw = rebind_wrapper.new( self, var_name )
	rebind_wrappers.append( rw )
	add_child( rw.label )
	#add_child( rw.key )
	add_child( rw.button )

func _ready() -> void:
	#window.close_requested.connect( hide_window )
	
	for prop in Keybinds.get_property_list():
		if !(prop["usage"] & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if prop["name"] == "filepath": continue
		create_rebind_button( prop["name"] )

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if current_rebind == null: return
		
		Keybinds.set( current_rebind.variable_name, event.keycode )
		current_rebind.key.text = OS.get_keycode_string( event.keycode )
		current_rebind.button.text = OS.get_keycode_string( event.keycode )
		current_rebind = null
		
		Keybinds.save_binds()
