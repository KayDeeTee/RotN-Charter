extends Control

var composer : Composer
var font : Font

@export var is_raw : bool = false

func _ready() -> void:
	font = preload("res://fonts/Hack-Regular.ttf")

func _process(delta: float) -> void:
	queue_redraw()
	
var scroll_speed = 900
	
func get_colour( snap ):
	match( snap ):
		1: return Color.RED
		2: return Color.BLUE
		3: return Color.ORANGE
		4: return Color.PURPLE
		5: return Color.GREEN
		_: return Color.DEEP_PINK
	
	
func _draw() -> void:
	draw_rect( Rect2i(0,0, size.x, size.y), Color(0,0,0,0.9) )
	if is_raw:
		var min = composer.current_time-50
		var max = composer.current_time+50
		var circle_size = 20
		var reticle_position = 660
		
		for i in range(6):
			var j = i % 3
			var lane = composer.lanes[i]
			var lane_target = Vector2( (size.x/3)*(j+.5), reticle_position )
			draw_circle( lane_target, circle_size-1, Color.WHITE, false )
			if i%3 == 0:
				draw_polygon( [lane_target+Vector2(-8,0), lane_target+Vector2(4,8), lane_target+Vector2(4,-8)], [Color(1,1,1)] )
			if i%3 == 1:
				draw_polygon( [lane_target+Vector2(0,-8), lane_target+Vector2(-8,4), lane_target+Vector2(8,4)], [Color(1,1,1)] )
			if i%3 == 2:
				draw_polygon( [lane_target+Vector2(8,0), lane_target+Vector2(-4,8), lane_target+Vector2(-4,-8)], [Color(1,1,1)] )
			for note in lane.keys():
				if note < min: continue
				if note > max: continue
				if !lane[note]: continue
				var t = note-composer.current_time
				var target = lane_target - Vector2(0,scroll_speed) * t
				draw_circle( target, circle_size, get_colour( lane[note]) )
				draw_circle( target , circle_size/2, Color(1,1,1,0.2) )
		for i in range(2):
			var lane = composer.lanes[i+6]
			var targets = [ Vector2( (size.x/3)*(0+.5), reticle_position ), Vector2( (size.x/3)*(1+.5), reticle_position ), Vector2( (size.x/3)*(2+.5), reticle_position ) ]
			for note in lane.keys():
				if note < min: continue
				if note > max: continue
				if !lane[note]: continue
				var t = note-composer.current_time
				for x in range(3):
					var target = targets[x] - Vector2(0,scroll_speed) * t
					draw_circle( target, circle_size, get_colour( lane[note]) )
					draw_circle( target , circle_size/2, Color(1,1,1,0.2) )
	else:
	
		draw_line( Vector2(size.x/2,0), Vector2(size.x/2, size.y), Color.WHITE )
		draw_string(font, Vector2(0,24), "LEFT HAND", HORIZONTAL_ALIGNMENT_CENTER, size.x/2-8, 16)
		draw_string(font, Vector2(size.x/2+8,24), "RIGHT HAND", HORIZONTAL_ALIGNMENT_CENTER, size.x/2-8, 16)

		var min = composer.current_time-50
		var max = composer.current_time+50
		var circle_size = 20
		var reticle_position = 660
		for i in range(6):
			var lane = composer.lanes[i]
			var lane_target = Vector2( (size.x/6)*(i+.5), reticle_position )
			draw_circle( lane_target, circle_size-1, Color.WHITE, false )
			if i%3 == 0:
				draw_polygon( [lane_target+Vector2(-8,0), lane_target+Vector2(4,8), lane_target+Vector2(4,-8)], [Color(1,1,1)] )
			if i%3 == 1:
				draw_polygon( [lane_target+Vector2(0,-8), lane_target+Vector2(-8,4), lane_target+Vector2(8,4)], [Color(1,1,1)] )
			if i%3 == 2:
				draw_polygon( [lane_target+Vector2(8,0), lane_target+Vector2(-4,8), lane_target+Vector2(-4,-8)], [Color(1,1,1)] )
			for note in lane.keys():
				if note < min: continue
				if note > max: continue
				if !lane[note]: continue
				var t = note-composer.current_time
				var target = lane_target - Vector2(0,scroll_speed) * t
				draw_circle( target, circle_size, get_colour( lane[note]) )
				draw_circle( target , circle_size/2, Color(1,1,1,0.2) )
		for i in range(2):
			var lane = composer.lanes[i+6]
			var lane_target = Vector2( (size.x/2)*(i+.5), reticle_position )
			draw_circle( lane_target, circle_size-1, Color.WHITE, false )
			for note in lane.keys():
				if note < min: continue
				if note > max: continue
				if !lane[note]: continue
				var t = note-composer.current_time
				var target = lane_target - Vector2(0,scroll_speed) * t
				var rect_tl = Vector2(size.x/4-8,circle_size-4)
				draw_rect( Rect2i(target-rect_tl, Vector2(size.x/2-16, circle_size*2-8)), get_colour( lane[note]) )
				draw_circle( target , circle_size/2, Color(1,1,1,0.2) )
