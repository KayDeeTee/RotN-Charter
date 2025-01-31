extends HBoxContainer

var categories = {}
var buttons = {}

func _ready() -> void:
	
	for category in EventDef.get_categories():
		create_category( category )
		
	for key in EventDef.definitions.keys():
		var edef = EventDef.definitions[key]
		create_button( edef.cat, edef.subcat, edef.sprite )
	
	#auto select green slime
	on_click( "slime", "green" )

func create_category( id ):
	var cat = VBoxContainer.new()
	cat.name = id
	add_child( cat )
	categories[id] = cat
	
func create_button( cat, id, texture ):
	var button = TextureButton.new()
	button.texture_normal = texture
	categories[cat].add_child( button )
	buttons["%s/%s" % [cat, id]] = button
	var callable = on_click
	button.pressed.connect( callable.bindv( [cat, id] ) )
	button.focus_mode = Control.FOCUS_NONE
	
func on_click( cat, id ):
	for button in buttons.keys():
		buttons[button].self_modulate = Color(0.5,0.5,0.5)
	buttons["%s/%s" % [cat, id]].self_modulate = Color(1,1,1)
	
	SignalBus.set_picker_entity.emit( "%s/%s" % [cat, id] )
