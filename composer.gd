extends Node2D
class_name Composer

@export var text_info : RichTextLabel
@export var video : VideoStreamPlayer
@export var gameplay : Control
@export var gameplay_raw : Control

@export var bpm_spin : SpinBox 
var bpm = 230

@export var video_spin : SpinBox
var video_offset = -2.25

@export var snap_label : RichTextLabel
@export var time_label : RichTextLabel
@export var beat_label : RichTextLabel

var current_time = 0
var beat = 0
var playing = false
var snap = 0



var paused = false

var snapped = false
var lanes = []

func set_lane_at_time(lane, time):
	if lanes[lane].has(time):
		lanes[lane].erase(time)
	else:
		lanes[lane][time] = get_snap_from_t(time)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_0:
				current_time = 0.0
				video.stream_position = current_time-video_offset
				video.paused = false
				snapped = false
			if event.keycode == KEY_1:
				save_data()
			if event.keycode == KEY_2: 
				load_data()
			if event.keycode == KEY_SPACE:
				paused = !paused
				snapped = false
			if event.keycode == KEY_RIGHT:
				current_time += snap_dist()
				snap_to()
				
				video.stream_position = current_time-video_offset
			if event.keycode == KEY_LEFT:
				current_time -= snap_dist()
				snap_to()
				video.stream_position = current_time-video_offset
			if event.keycode == KEY_UP:
				snap += 1
			if event.keycode == KEY_DOWN:
				snap -= 1
			if snapped:
				if event.keycode == KEY_Q:
					set_lane_at_time(0, current_time)
				if event.keycode == KEY_W:
					set_lane_at_time(1, current_time)
				if event.keycode == KEY_E:
					set_lane_at_time(2, current_time)
				if event.keycode == KEY_R:
					set_lane_at_time(6, current_time)
				if event.keycode == KEY_A:
					set_lane_at_time(3, current_time)
				if event.keycode == KEY_S:
					set_lane_at_time(4, current_time)
				if event.keycode == KEY_D:
					set_lane_at_time(5, current_time)
				if event.keycode == KEY_F:
					set_lane_at_time(7, current_time)
			print( event )

func snap_to():
	var subdiv = 1
	match(snap):
		0: subdiv = 1
		1: subdiv = 2
		2: subdiv = 3
		3: subdiv = 4
		4: subdiv = 6
		5: subdiv = 8
		6: subdiv = 12
		7: subdiv = 16
	var divs = (60.0/bpm)/subdiv
	var t = current_time / divs
	t = round(t)
	current_time = t*divs
	snapped = paused

func snap_dist():
	var subdiv = 1
	if snap < 0: snap += 8
	snap %= 8
	match(snap):
		0: subdiv = 1
		1: subdiv = 2
		2: subdiv = 3
		3: subdiv = 4
		4: subdiv = 6
		5: subdiv = 8
		6: subdiv = 12
		7: subdiv = 16
		
	print( subdiv )
	return (60.0/bpm)/subdiv

func snap_text():
	if snap < 0: snap += 8
	snap %= 8
	match(snap):
		0: return "1/1"
		1: return "1/2"
		2: return "1/3"
		3: return "1/4"
		4: return "1/6"
		5: return "1/8"
		6: return "1/12"
		7: return "1/16"
	return ""

func save_data():
	var chart_save = FileAccess.open( "res://current.chart", FileAccess.WRITE )
	chart_save.store_var(bpm)
	chart_save.store_var(video_offset)
	chart_save.store_var( lanes )

	
func load_data():
	var chart_save = FileAccess.open( "res://current.chart", FileAccess.READ )
	bpm = chart_save.get_var()
	video_offset = chart_save.get_var()
	lanes = chart_save.get_var()
	
	bpm_spin.set_value_no_signal(bpm)
	video_spin.set_value_no_signal(video_offset)

func get_snap_from_t(t):
		var beat = t * (bpm/60.)
		var fraction = fposmod(beat, 1)
		if is_equal_approx( fraction, 0 ): return 1
		if is_equal_approx( fraction, 1 ): return 1
		if is_equal_approx( fraction, 0.5 ): return 2
		if is_equal_approx( fraction, 0.25 ): return 3
		if is_equal_approx( fraction, 0.75 ): return 3
		if is_equal_approx( fraction, 1/3.0 ): return 4
		if is_equal_approx( fraction, 2/3.0 ): return 4
		if is_equal_approx( fraction, 1/8.0 ): return 5
		if is_equal_approx( fraction, 3/8.0 ): return 5
		if is_equal_approx( fraction, 5/8.0 ): return 5
		if is_equal_approx( fraction, 7/8.0 ): return 5
		return 6
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bpm_spin.set_value_no_signal(bpm)
	video_spin.set_value_no_signal(video_offset)
	for x in range(8):
		lanes.append({})
	gameplay.composer = self
	gameplay_raw.composer = self

func ui():
	var beat = (bpm/60.0)*current_time
	var snap_amount = snap_text()
	text_info.text = """bpm:%d\ntime:%.2f\nbeat:%.2f\nsnap:%s""" % [bpm, current_time, beat, snap_amount]
	snap_label.text = "[center]%s[/center]" % snap_amount
	var minutes = floor(current_time/60)
	var seconds = fposmod(current_time, 60)
	var milliseconds = fposmod(current_time, 1)
	time_label.text = "[center]%02d:%02d.%02d[/center]" % [minutes, seconds, milliseconds*100]
	beat_label.text = "[center]%0.2f[/center]" % beat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused:
		video.stream_position = current_time-video_offset
	else:
		current_time = video.stream_position+video_offset
	ui()
	
func _on_bpm_value_changed(value: float) -> void:
	bpm = value

func _on_v_offset_value_changed(value: float) -> void:
	video_offset = value
