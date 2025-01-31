extends SpinBox

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	value_changed.connect( on_change )
	get_line_edit().editable = false

var diff = 0
func _gui_input(event: InputEvent) -> void: #handle custom snapping
	if !(event is InputEventMouseButton): return 
	if !event.pressed: return
	var mpos = get_local_mouse_position()
	var on_up = false
	var on_down = false
	if mpos.x > size.x - 16:
		if mpos.y < size.y/2:
			on_up = true
		else:
			on_down = true
	if !on_up and !on_down: return
	if event.button_index == 1:
		diff = 1 if on_up else -1
		value = fposmod( value+diff-1, 3 )+1

func on_change(v):
	for target in targets:
		target.set_track(  fposmod( target.track+diff-1, 3 )+1 )

func set_vis( v ):
	get_parent().visible = v
	
func update_target( event ):
	targets = event
	if len( targets ) == 0:
		set_vis( false )
		return
	set_vis( true )
	set_value_no_signal( targets[0].track )
