extends Control

var emu_manager : RotN_Emu

func set_track( x ):
	size = emu_manager.get_cell_size()
	position = emu_manager.get_cell_pos(x, 8)

func set_subbeat( f ):
	offset_angle = (floor(f*12)/12) * PI * 2
	queue_redraw()
	
func _process(delta: float) -> void:
	self_modulate.a -= delta
	if self_modulate.a <= 0:
		queue_free()
	
var offset_angle = 0
func _draw() -> void:
	var mid = size/2
	var end = mid + Vector2( sin( offset_angle ), -cos(offset_angle) ) * (size.x/2)
	draw_line( mid, end, Color.WHITE, 2 )
