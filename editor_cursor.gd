extends Control

@export var chart_scroll : ScrollContainer
@export var chart_viewer : Control
var snap = 1.0
var facing = false
var current_beat = 0:
	set( value ):
		if value < 0:
			value = 0
		current_beat = value
		var t_scroll = chart_scroll.get_v_scroll_bar().max_value-((current_beat-2)*64)-height
		chart_scroll.get_v_scroll_bar().allow_greater = true
		chart_scroll.get_v_scroll_bar().allow_lesser = true
		chart_scroll.set_v_scroll( t_scroll )
		queue_redraw()

func on_load_chart():
	await get_tree().process_frame
	current_beat = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chart_scroll.get_v_scroll_bar().value_changed.connect( on_scroll )
	SignalBus.change_snap.connect( change_snap )
	SignalBus.set_picker_entity.connect( change_ent )
	current_beat = 0
	SignalBus.chart_loaded.connect( on_load_chart )
	get_window().get_viewport().size_changed.connect( recalc_height )
	recalc_height()

var height = 720
func recalc_height():
	height = size.y
	
func delete_event( track, beat ):
	for child in chart_viewer.get_children():
		if child.get_track() == track and child.startBeatNumber == beat: #won't delete bpm/vibe
			child.queue_free()

func add_event( track, beat, catid ):
	delete_event( track, beat )
	var new_event = preload("res://prefab/event.tscn").instantiate()
	chart_viewer.add_child( new_event )
	var event = {}
	event["track"] = track
	event["startBeatNumber"] = beat
	event["endBeatNumber"] = beat+1
	event["clipin"] = 0
	event["audioEvents"] = []
	event["dataPairs"] = []
	
	event["type"] = "SpawnEnemy"
	event["dataPairs"].append( {"_eventDataKey":"EnemyId","_eventDataValue":1722} )
	event["dataPairs"].append( {"_eventDataKey":"ShouldClampToSubdivisions","_eventDataValue":false} )
	new_event.parse_event( event )
	
	var event_def = EventDef.get_cat_id( catid )
	new_event.set_type( event_def.type )
	if event_def.type == 0:
		new_event.set_enemy_id( event_def.id )
	if event_def.type == 2:
		new_event.set_trap_to_spawn( event_def.id )

	new_event.set_facing( facing )

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed: return
		if event.keycode == KEY_UP: current_beat += snap
		if event.keycode == KEY_DOWN: current_beat -= snap
		if event.keycode == KEY_Z: add_event(1, current_beat, cat_and_id)
		if event.keycode == KEY_X: add_event(2, current_beat, cat_and_id)
		if event.keycode == KEY_C: add_event(3, current_beat, cat_and_id)
		if event.keycode == KEY_D: 
			delete_event(1, current_beat)
			delete_event(2, current_beat)
			delete_event(3, current_beat)
		if event.keycode == KEY_F: 
			facing = !facing
			queue_redraw()
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 5: current_beat -= snap
			if event.button_index == 4: current_beat += snap
			
func on_scroll( v ):
	var scroll = (chart_scroll.get_v_scroll_bar().max_value - v)-height
	var beat = scroll/64
	beat = round( beat/snap )
	beat *= snap
	current_beat = beat+2
	
func change_snap( v ):
	snap = 1./v
	

var cat_and_id = "slime/green"
func change_ent( ent_cat_id ):
	cat_and_id = ent_cat_id

func _draw() -> void:
	var scroll = (chart_scroll.get_v_scroll_bar().max_value - chart_scroll.get_v_scroll_bar().value)-height
	var beat = scroll/64
	var offset = (current_beat-beat)*64
	draw_line( Vector2(0,size.y-offset), Vector2(size.x,size.y-offset), Color.GREEN )
	draw_string( preload("res://fonts/Hack-Regular.ttf"), Vector2(size.x*0.75,size.y-offset-4), "%.2f" % current_beat, HORIZONTAL_ALIGNMENT_RIGHT, size.x*0.25, 16, Color.GREEN   )
	draw_string( preload("res://fonts/Hack-Regular.ttf"), Vector2(size.x*0.75,size.y-offset+8), "right" if facing else "left", HORIZONTAL_ALIGNMENT_RIGHT, size.x*0.25, 8, Color.GREEN   )
