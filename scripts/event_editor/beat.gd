extends SpinBox

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	value_changed.connect( on_change )
	#value_changed.connect( func(value:float): get_line_edit().text='%.3f' % value, CONNECT_DEFERRED )
	get_line_edit().focus_exited.connect(format_value, CONNECT_DEFERRED)
	get_line_edit().text_submitted.connect(format_value.unbind(1), CONNECT_DEFERRED)
	value_changed.connect(format_value.unbind(1), CONNECT_DEFERRED)
	custom_arrow_step = 0
	step = 0
	SignalBus.change_snap.connect( update_snap )
	SignalBus.change_snap_rel.connect( update_rel )

var snap = 1.0
var rel = false

func update_snap( v ):
	snap = 1/float(v)
	
func update_rel( v ):
	rel = v

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
		if !rel:
			value = round(value/snap)*snap
		value += snap if on_up else -snap
			

func format_value() -> void:
	get_line_edit().text = '%.3f' % value

func on_change(v):
	var diff = 0
	if len(targets) > 0:
		diff = v - targets[0].startBeatNumber
		
	for target in targets:
		target.offset_beat( diff )
	
func set_vis( v ):
	get_parent().visible = v
	
func update_target( event ):
	targets = event
	if len(targets) == 0:
		set_vis( false )
		return
	set_value_no_signal( targets[0].startBeatNumber )
	set_vis( true )
	format_value.call_deferred()
