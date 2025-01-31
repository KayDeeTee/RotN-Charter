extends ColorRect

@export var parser : Node2D
@export var scroll : ScrollContainer

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var offset = scroll.get_v_scroll_bar().value - 128 # hack to prevent negative numbers rounding differently
	var end = scroll.get_v_scroll_bar().max_value
	offset = ( (end-offset)-get_viewport().size.y   )
	
	var beatzero = (offset/64)

	offset = int(offset) % 64
	
	for y in int(size.y/64)+1:
		var row_y = size.y - (64*y) + offset
		draw_string( preload("res://fonts/Hack-Regular.ttf"), Vector2(0,row_y-4), "%d" % floor(beatzero+y-2) ) #offset the previous hack to get correct numbers
		draw_line( Vector2(0, row_y ), Vector2(size.x, row_y), Color(1,1,1,0.5), 1 )
		draw_line( Vector2(0, row_y-32), Vector2(size.x, row_y-32), Color(1,1,1,0.25), 1 )
