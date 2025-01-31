extends Control

var dragging = false

var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO

@export var chart_viewer : Control
@export var chart_scroll : ScrollContainer

func _ready():
	chart_scroll.get_v_scroll_bar().value_changed.connect( on_scroll )

func on_scroll( v ):
	if !dragging: return
	await get_tree().process_frame
	drag_end = chart_viewer.get_local_mouse_position()
	resize_drag_area()
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			dragging = event.pressed
			if dragging:
				drag_start = chart_viewer.get_local_mouse_position()
				drag_end = chart_viewer.get_local_mouse_position()
				resize_drag_area()
			else:
				drag_end = chart_viewer.get_local_mouse_position()
				resize_drag_area()
				get_selected()
	if event is InputEventMouseMotion:
		if dragging:
			drag_end = chart_viewer.get_local_mouse_position()
			resize_drag_area()
			
var drag_pos = Vector2.ZERO
var drag_size = Vector2.ZERO
func resize_drag_area():
	drag_size = Vector2( abs(drag_start-drag_end) )
	var x = min( drag_start.x, drag_end.x )
	var y = min( drag_start.y, drag_end.y )
	drag_pos = Vector2(x,y)
	queue_redraw()
	
var selection = []
func get_selected():
	var drag_rect = Rect2( drag_pos, drag_size )
	if !Input.is_key_pressed(KEY_CTRL) and !Input.is_key_pressed(KEY_SHIFT):
		selection = []
	for child : Control in chart_viewer.get_children():
		var child_box = Rect2( child.position, child.size )
		child.selected = false
		if drag_rect.intersects( child_box ):
			if Input.is_key_pressed(KEY_SHIFT):
				if !selection.has( child ):
					selection.append( child )
			if Input.is_key_pressed(KEY_CTRL):
				selection.erase( child )
			else:
				if !selection.has( child ):
					selection.append( child )
		child.queue_redraw.call_deferred()
	for sel in selection:
		sel.selected = true
	SignalBus.event_selected.emit( selection )
			
func _draw() -> void:
	if dragging:
		var pos = drag_pos + chart_viewer.global_position
		draw_rect( Rect2( pos, drag_size), Color(0.2,0.5,0.8,0.5) )
		draw_rect( Rect2( pos, drag_size), Color(0.2,0.5,0.8,1), false )
