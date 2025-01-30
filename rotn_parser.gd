extends Node2D

var beat_divs = 12
var chart_name = "null"
var playback_offset = 0
var inputMapOverride = ""
var cameraZoomLevel = 0
var shouldSetBossStanceOnBeatmapStart = false
var defaultBossStance = 0
var beatTiming = []
var events = []
var bpm = 130
var coalTrapSpeedUpFactorOverride = 0

var json_data

@export var chart_name_edit : LineEdit
@export var bpm_spin : SpinBox
@export var coal_spin : SpinBox
@export var subdiv_spin : SpinBox
@export var offset_spin : SpinBox

enum EnemyID{
	Nothing = -1,
	EnemyPlaceholder,
	HealthPlaceholder,
	GreenSlime = 1722,
	BlueSlime = 4355,
	YellowSlime = 9189,
	BaseSkeleton = 2202,
	ShieldSkeleton = 1911,
	YellowSkeleton = 6803,
	ShieldYellowSkeleton = 4871,
	BlackSkeleton = 2716,
	ShieldBlackSkeleton = 3307,
	TripleShieldBaseSkeleton = 6471,
	WyrmHead = 7794,
	WyrmBody = 8079,
	WyrmTail = 9888,
	BlueBat = 8675309,
	YellowBat = 717,
	RedBat = 911,
	Harpy = 8519,
	QuickHarpy = 3826,
	StrongHarpy = 8156,
	BladeMaster = 929,
	StrongBladeMaster = 3685,
	YellowBladeMaster = 7288,
	Skull = 4601,
	StrongSkull = 3543,
	TrickySkull = 7685,
	GreenZombie = 1234,
	RedZombie = 1236,
	Cheese = 2054,
	Apple = 7358,
	Drumstick = 1817,
	Ham = 3211,
	Coin = 8883,
	BlueArmadillo = 7831,
	YellowArmadillo = 6311,
	RedArmadillo = 1707
}

@export var chart_viewer : Control
func _ready() -> void:
	Global.parser = self
	Global.chart = chart_viewer
	
	json_data = {}
	subdiv_spin.value_changed.connect( update_subdiv )
	offset_spin.value_changed.connect( update_offset )
	coal_spin.value_changed.connect( update_coal_speed )
	bpm_spin.value_changed.connect( update_bpm )
	chart_name_edit.text_changed.connect( update_chart_name )
	
	get_window().files_dropped.connect( files_dropped )
	return
	load_from_file( "res://chart/imp.json" )
	#save()

func files_dropped(files):
	if len( files ) == 1:
		load_from_file( files[0] )
	
func load_from_file( filename : String ):
	if filename.get_extension() == "qua":
		load_from_quaver_file( filename )
		regen_events()
		return
	currently_loaded_filepath = filename
	var text = FileAccess.open(filename, FileAccess.READ)
	var json = JSON.parse_string( text.get_as_text() )
	json_data = json
	if !json_data.has("name"): json_data["name"] = "N/A"
	chart_name = json_data["name"]
	if !json_data.has("bpm"): json_data["bpm"] = 120
	bpm = json_data["bpm"]
	bpm_spin.set_value_no_signal( bpm )
	coalTrapSpeedUpFactorOverride = json_data["coalTrapSpeedUpFactorOverride"]
	coal_spin.set_value_no_signal( coalTrapSpeedUpFactorOverride )
	if !json_data.has("beatDivisions"): json_data["beatDivisions"] = 12
	subdiv_spin.set_value_no_signal( json_data["beatDivisions"] )
	if !json_data.has("playbackOffset"): json_data["playbackOffset"] = 1
	offset_spin.set_value_no_signal( json_data["playbackOffset"] )
	chart_name_edit.text = chart_name
	
	regen_events()

func regen_events():
	var final_beat = 1
	for event in json_data["events"]:
		if event["endBeatNumber"] > final_beat: final_beat = event["endBeatNumber"]
	#chart_viewer.custom_minimum_size.y = (len(json_data["BeatTimings"])+10) * 64 + 720
	chart_viewer.custom_minimum_size.y = final_beat * 64
	await get_tree().process_frame
	for child in chart_viewer.get_children():
		child.queue_free()
	for event in json_data["events"]:
		var new_event = preload("res://prefab/event.tscn").instantiate()
		chart_viewer.add_child( new_event )
		new_event.parse_event( event )
		if new_event.endBeatNumber > final_beat: final_beat =  new_event.endBeatNumber
		
	SignalBus.chart_loaded.emit()
	
	
func load_from_quaver_file( file_name, offset=null ):
	var snap = false#true
	var quachart = FileAccess.open( file_name, FileAccess.READ)
	quachart = quachart.get_as_text()
	
	var parsed_chart = YAML.parse( quachart )
	
	var current_time = 0
	var current_beat = 0
	var adjust_bpm = []
	var hit_events = []
	var ms_per_beat = 0
	var timing_idx = 0
	var hit_idx = 0
	var qbpm = 0
	while timing_idx < len( parsed_chart["TimingPoints"] ) or hit_idx < len( parsed_chart["HitObjects"] ):
		var next_timing_event = INF
		var next_hit_event = INF
		if timing_idx < len( parsed_chart["TimingPoints"] ): next_timing_event = parsed_chart["TimingPoints"][timing_idx]["StartTime"]
		if hit_idx < len( parsed_chart["HitObjects"] ): next_hit_event = parsed_chart["HitObjects"][hit_idx]["StartTime"]
		if offset == null: 
			offset = min( next_timing_event, next_hit_event ) * -1
			current_time =  min( next_timing_event, next_hit_event ) 
		
		if next_timing_event <= next_hit_event:
			var diff = next_timing_event-current_time
			current_time = next_timing_event
			qbpm = float(parsed_chart["TimingPoints"][timing_idx]["Bpm"])
			if ms_per_beat == 0:
				ms_per_beat = (60.0/qbpm)*1000
			current_beat += diff / ms_per_beat
			ms_per_beat = (60.0/qbpm)*1000
			adjust_bpm.append( [current_beat, qbpm]  )
			timing_idx += 1
		else:
			var diff = next_hit_event-current_time
			current_time = next_hit_event
			current_beat += diff / ms_per_beat
			if parsed_chart["HitObjects"][hit_idx].has("EndTime"):
				var duration = parsed_chart["HitObjects"][hit_idx]["EndTime"]-parsed_chart["HitObjects"][hit_idx]["StartTime"]
				duration /= ms_per_beat
				hit_events.append( [current_beat, current_beat + duration] )
			else:
				hit_events.append( [current_beat, current_beat] )
			hit_idx += 1
	
	json_data = {}
	json_data["events"] = []
	var track = 0
	var total_beats = 0
	for t in hit_events:
		if t[1]+1 > total_beats:
			total_beats = t[1]+1
		var event = {}
		event["type"] = "SpawnEnemy"
		event["startBeatNumber"] = round(t[0]*12)/12.0
		event["endBeatNumber"] = round(t[1]*12)/12.0
		event["group"] = 0
		event["track"] = track+1
		track += 1
		track %= 3
		event["clipin"] = 0
		event["dataPairs"] = []
		#var rand = randi_range(0, 5)
		if t[0] == t[1]:
			event["dataPairs"].append( {"_eventDataKey":"EnemyId", "_eventDataValue":"1722"} ) #slime
		else:
			event["dataPairs"].append( {"_eventDataKey":"EnemyId", "_eventDataValue":"7794"} ) #wyrm
		event["dataPairs"].append( {"_eventDataKey":"ShouldClampToSubdivisions", "_eventDataValue":"False"} )
		json_data["events"].append(event)
		
	for t in adjust_bpm:
		var event = {}
		event["type"] = "AdjustBPM"
		event["startBeatNumber"] = t[0]+8 #normal games do timing events based on when hit, not spawn so this synchronises it
		event["endBeatNumber"] = t[0]+1+8
		event["group"] = 0
		event["track"] = 1
		event["clipin"] = 0
		event["dataPairs"] = []
		event["dataPairs"].append( {"_eventDataKey":"Bpm", "_eventDataValue":t[1]} )
		json_data["events"].append(event)
	timing_idx = 0
	qbpm = 0
	ms_per_beat = 0
	current_time = 0
	json_data["BeatTimings"] = []
	for beat in range(total_beats):
		if timing_idx < len( adjust_bpm ):
			if beat >= adjust_bpm[timing_idx][0]:
				qbpm = adjust_bpm[timing_idx][1]
				ms_per_beat = (60.0/qbpm)*1000
				timing_idx += 1
		json_data["BeatTimings"].append( current_time )
		current_time += (ms_per_beat/1000.0)
		
	bpm = adjust_bpm[0][1]
	bpm_spin.set_value_no_signal( bpm )
	
	chart_name = parsed_chart["Title"]
	coalTrapSpeedUpFactorOverride = 1
	coal_spin.set_value_no_signal( coalTrapSpeedUpFactorOverride )
	subdiv_spin.value = ( 12 )
	offset_spin.value =  ( 0 )
	json_data["beatDivisions"] = 12
	json_data["playbackOffset"] = 0
	chart_name_edit.text = chart_name

func save( smod=1, path="" ):
	if path == "": path = currently_loaded_filepath
	if path == "": return
	if smod != 1:
		path += " (%.2f)" % smod
	var timing_events = []
	json_data["bpm"] = bpm * smod
	json_data["name"] = chart_name
	json_data["coalTrapSpeedUpFactorOverride"] = coalTrapSpeedUpFactorOverride
	json_data["events"] = []
	var last_beat = 0
	for child in chart_viewer.get_children():
		json_data["events"].append( child.save_json( smod ) )
		if child.endBeatNumber > last_beat:
			last_beat = child.endBeatNumber
		if child.type == "AdjustBPM":
			timing_events.append( [child.startBeatNumber, child.data_dict["Bpm"] ] )
	var timing_idx = 0
	if len( timing_events ) == 0:
		timing_events.append( [0, json_data["bpm"]] )
		
	json_data["BeatTimings"] = []
	var ms_per_beat = (60.0/json_data["bpm"])*1000
	var current_time = 0
	for i in range( ceil(last_beat)+1 ):
		current_time += (60.0/timing_events[timing_idx][1])
		if timing_idx < len( timing_events )-1:
			if i >= timing_events[timing_idx+1][0]:
				timing_idx += 1
		json_data["BeatTimings"].append( current_time / smod )
	
	var data = JSON.stringify( json_data )
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string( data )

@export var speed_mod_spin : SpinBox
func _on_save_smod() -> void:
	save( speed_mod_spin.value )

func _on_save() -> void:
	save()

@export var load_dialog : FileDialog
func _on_load() -> void:
	load_dialog.visible = true
	
@export var save_dialog : FileDialog
func _on_save_as_pressed() -> void:
	save_dialog.visible = true

func update_chart_name( v ):
	chart_name = v

func update_bpm( v ):
	bpm = v

func update_coal_speed( v ):
	coalTrapSpeedUpFactorOverride = v
	
func update_subdiv( v ):
	json_data["beatDivisions"] = v

func update_offset( v ):
	json_data["playbackOffset"] = v

@export var qua_offset : SpinBox
@export var qua_file_name : LineEdit
func _on_load_qua_pressed() -> void:
	load_from_quaver_file( qua_file_name.text, qua_offset.value )
	regen_events()

var currently_loaded_filepath = ""
func _on_load_dialog_file_selected(path: String) -> void:
	load_from_file( path )

func _on_save_dialog_file_selected(path: String) -> void:
	save(1, path)
