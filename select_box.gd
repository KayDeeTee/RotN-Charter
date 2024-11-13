extends Control

var dragging = false
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO

@export var chart_viewer : Control

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			dragging = event.pressed
			if dragging:
				drag_start = event.position
				drag_end = event.position
				resize_drag_area()
			else:
				drag_end = event.position
				resize_drag_area()
				get_selected()
	if event is InputEventMouseMotion:
		if dragging:
			drag_end = event.position
			resize_drag_area()
			
var drag_pos = Vector2.ZERO
var drag_size = Vector2.ZERO
func resize_drag_area():
	drag_size = Vector2( abs( drag_start-drag_end ) )
	var x = min( drag_start.x, drag_end.x )
	var y = min( drag_start.y, drag_end.y )
	drag_pos = Vector2(x,y)
	queue_redraw()
	
func get_selected():
	var drag_rect = Rect2( drag_pos, drag_size )
	var selection = []
	for child : Control in chart_viewer.get_children():
		var child_box = Rect2( child.get_screen_position(), child.size )
		if drag_rect.intersects( child_box ):
			selection.append( child )
	SignalBus.event_selected.emit( selection )
			
func _draw() -> void:
	if dragging:
		draw_rect( Rect2( drag_pos, drag_size), Color(0.2,0.5,0.8,0.5) )
		draw_rect( Rect2( drag_pos, drag_size), Color(0.2,0.5,0.8,1), false )
