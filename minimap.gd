extends Control
@export var chart_scroll : ScrollContainer
@export var chart_viewer : Control

var pixels_per_beat = 0

func _process(delta: float) -> void:
	#should probably be event based to only redraw when the chart changes
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			scroll_to()
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			scroll_to()

func scroll_to():
	var percent = (get_local_mouse_position().y -pixels_per_beat*7 )/size.y
	chart_scroll.scroll_vertical = chart_scroll.get_v_scroll_bar().max_value * percent

func _draw() -> void:
	draw_rect( Rect2(0,0,size.x,size.y), Color(0.1,0.1,0.1) )
	var final_beat = 12
	for child in chart_viewer.get_children():
		var start = child.startBeatNumber
		var end = child.endBeatNumber
		if end > final_beat:
			final_beat = end
	#final_beat += 10
			
	var scroll = (chart_scroll.get_v_scroll_bar().max_value - chart_scroll.get_v_scroll_bar().value)-720
	var beat = scroll/64
	var view_rect = Rect2(0, size.y-size.y*((beat+10)/final_beat), 8, size.y*(10/final_beat))
	
	pixels_per_beat = size.y/final_beat
	
	draw_rect( view_rect, Color(0.8,0.6,0.1,0.2), true )
	
	for child in chart_viewer.get_children():
		var start = child.startBeatNumber
		var end = child.endBeatNumber
		
		draw_rect( Rect2( Vector2((child.get_track()-1)*2, size.y-size.y*(end/final_beat)  ), Vector2(1,size.y*((end-start)/final_beat)  ) ), child.colour, true )
		
	draw_rect( view_rect, Color.YELLOW, false, 1  )
