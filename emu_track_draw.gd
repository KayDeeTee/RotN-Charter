extends Control
class_name RotN_Emu

var bpm = 0
var beats_per_second = 0
var event_idx = 0
var events = []
var time = 0
var playing = false

func _ready():
	var scroll : ScrollContainer = chart_viewer.get_parent().get_parent()
	scroll_bar = scroll.get_v_scroll_bar()
	scroll_bar.value_changed.connect( chart_scrolled )

var scroll_bar : VScrollBar
func chart_scrolled( v ):
	if playing: return
	return
	var t = (scroll_bar.max_value-scroll_bar.value-get_viewport().size.y)/64
	if t < target_t:
		target_t = t
		regen()
		
	target_t = t

var regen_timeout = 0
func regen( forced=false ):
	if Time.get_ticks_msec() - regen_timeout < 1000 and !forced:
		return
	regen_timeout = Time.get_ticks_msec()
	if len( events ) == 0 or forced:
		for child in chart_viewer.get_children():
			events.append( child )
		events.sort_custom( sort_events )
	time = 0
	tick = 0
	
	var t1 = len( save_states )-1
	var t2 = int(target_t)
	time = min( t1, t2 )
	tick = time * 64
	if save_states.has(time):
		event_idx = save_states[time][0]
	else:
		event_idx = 0
	
			
	spawned_enemies = []
	
	bpm = float(parser.bpm)
	for child in get_children():
		child.queue_free()
	
	beats_per_second = (60.0/bpm)

@export var parser : Node2D
@export var chart_viewer : Control
func start_play():
	if playing:
		playing = false
		return
	target_t = 0
	time = -8
	regen( true )
	
	playing = true

func hit_track( x ):
	var hit = preload("res://prefab/hit.tscn").instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	hit.emu_manager = self
	add_child(hit)
	hit.set_track( x )
	hit.set_subbeat( fposmod(time, 1)  )
	#print( "Hit Track %d at %.2f [%.2f]" % [x, time, time*beats_per_second])

func create_event( event ):
	match( event.type ):
		"SpawnEnemy": spawn_enemy( event )
		_: print( event.type )
		
var spawned_enemies = []
func spawn_enemy( event ):
	var enemy = preload("res://prefab/enemy.tscn").instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	enemy.emu_manager = self
	enemy.parse_event( event )
	add_child( enemy )
	spawned_enemies.append( enemy )

func get_time_for_idx( idx ):
	if idx >= len( events ):
		return INF
	return events[event_idx].startBeatNumber * beats_per_second


var save_states = []

var target_t = 0
var tickrate = 1/64.0
var tick = 0
func _process(delta: float) -> void:
	if playing:
		target_t += delta / beats_per_second
		scroll_bar.value = scroll_bar.max_value - (((target_t-7) * 64)+512)
	while( time  < target_t ):
		time += tickrate #delta / beats_per_second
		tick += 1
		while( time > get_time_for_idx(event_idx) ):
			create_event( events[event_idx] )
			event_idx += 1
		for enemy in spawned_enemies:
			enemy.update( tickrate )#delta )
		
		if tick % 64 == 0:
			var idx = tick/64
			while( idx >= len(save_states) ):
				save_states.append( null )
			save_states[ idx ] = create_save_state()

func create_save_state():
	return [event_idx]

func sort_events( a, b ):
	return a.startBeatNumber < b.startBeatNumber

func get_cell_pos(x,y):
	return get_cell_size() * Vector2(x,y)

func get_cell_size():
	return Vector2( size.x / 3,  size.y / 9 )

func _draw():
	var y_size = size.y / 9
	var x_size = size.x / 3
	
	for x in range(3):
		for y in range(9):
			var c = Color(0.1,0.1,0.1)
			if (x + y) % 2 == 0: c = Color(0.2,0.2,0.2)
			var rpos = Vector2(x_size*x, y_size*y)
			var rsize = Vector2(x_size, y_size)
			draw_rect( Rect2( rpos, rsize ), c, true  )
	
	
	for y in range(10):
		draw_line( Vector2(0,y_size*(y)),Vector2(size.x,y_size*(y)), Color.LIGHT_GRAY, 1 )
	
	#draw vert lines
	for x in range(3):
		draw_line( Vector2(x_size*(x+.5),0),Vector2(x_size*(x+.5),size.y-y_size), Color.AQUAMARINE, 2 )
