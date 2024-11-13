extends Control

enum RRTrapType {
		Coals,
		PortalIn,
		PortalOut,
		Bounce,
		Mystery,
		Wind,
		Freeze,
		DebugLock
	}

enum RRTrapDirection {
		Up,
		Right,
		Left,
		Down,
		UpLeft,
		UpRight,
		DownLeft,
		DownRight
}

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

var track_width = 0

var track = 1
func get_track():
	if type == "AdjustBPM": return 4
	if type == "StartVibeChain": return 4
	return track
var type = "SpawnEnemy"
var group = 0
var clipin = 0
var startBeatNumber = 0
var endBeatNumber = 0
var dataPairs = []
var audioEvents = []

var data_dict = {}

func save_json( smod = 1 ):
	var json = {}
	json["track"] = track
	json["type"] = type
	json["group"] = group
	json["clipin"] = clipin
	var tbpm = 0
	if type == "AdjustBPM":
		tbpm = data_dict["Bpm"]
		data_dict["Bpm"] = data_dict["Bpm"] * smod
	if type == "StartVibeChain":
		data_dict["RiftedVibeChainShift"] = startBeatNumber
	
	json["startBeatNumber"] = startBeatNumber
	if endBeatNumber <= startBeatNumber + 1:
		endBeatNumber = startBeatNumber + 1
	json["endBeatNumber"] = endBeatNumber
	json["dataPairs"] = []
	for key in data_dict.keys():
		json["dataPairs"].append( {"_eventDataKey": key, "_eventDataValue": data_dict[key] } )
	json["audioEvents"] = []
	
	if type == "AdjustBPM":
		data_dict["Bpm"] = tbpm
		
	return json
	
var texture
var flip_h

func update_texture():
	position.x = (get_parent().size.x/4) * (track-.5)
	
	match( type ):
		"SpawnEnemy":
			if data_dict.has("ShouldStartFacingRight"):
				flip_h = true
			var edef = EventDef.get_type_id( 0, data_dict["EnemyId"] )
			texture = edef.sprite
		"SpawnRandomEnemy": pass
		"SpawnTrap":
			var edef = EventDef.get_type_id( 2, data_dict["TrapTypeToSpawn"] )
			texture = edef.sprite
		"StartVibeChain":
			var edef = EventDef.get_type_id( 3, 0 )
			texture = edef.sprite
			position.x = (get_parent().size.x/4) * (4-.5)
		"AdjustBPM":
			var edef = EventDef.get_type_id( 4, 0 )
			texture = edef.sprite
			position.x = (get_parent().size.x/4) * (4-.5)
	queue_redraw()

func set_enemy_id( id ):
	data_dict["EnemyId"] = id
	if id == EnemyID.BladeMaster or id == EnemyID.StrongBladeMaster or id == EnemyID.YellowBladeMaster:
		data_dict["BlademasterAttackRow"] = 4
	else:
		data_dict.erase("BlademasterAttackRow")
	if id == EnemyID.ShieldSkeleton or id == EnemyID.ShieldYellowSkeleton or id == EnemyID.ShieldBlackSkeleton or id == EnemyID.TripleShieldBaseSkeleton:
		data_dict["ShouldMoveOnDupletMeter"] = true
	else:
		data_dict.erase("ShouldMoveOnDupletMeter")
	update_texture()
	queue_redraw()

func set_track( b ):
	track = b
	position.x = (get_parent().size.x/4) * (track-.5)
	update_texture()
	update_beat()
	queue_redraw()

func offset_beat( b ):
	set_beat( startBeatNumber + b )

func set_beat( b ):
	startBeatNumber = b
	update_beat()
	queue_redraw()
	
func offset_beat_end( b ):
	set_end_beat( endBeatNumber + b )

func set_end_beat( b ):
	endBeatNumber = b
	update_beat()
	queue_redraw()

func set_attack_row( v ):
	data_dict["BlademasterAttackRow"] = v
	queue_redraw()
	
func set_facing( should_face_right ):
	if !should_face_right:
		data_dict.erase("ShouldStartFacingRight")
	else:
		data_dict["ShouldStartFacingRight"] = true
	update_texture()
	queue_redraw()

func update_beat():
	position.y = get_parent().size.y - (startBeatNumber+8) * 64

func _ready() -> void:
	get_window().get_viewport().size_changed.connect( recalc_position )
	
func recalc_position():
	set_track(track)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			SignalBus.event_selected.emit( self )

#to do 
#public int EnemyLength;
#public int ItemToDropOnDeathId;
#public bool ShouldSpawnWithPoofStatusEffect;
#public bool ShouldSpawnAsVibeChain;

func parse_event( data ):
	mouse_filter = MOUSE_FILTER_IGNORE
	for key in data.keys():
		match( key ):
			"track": track = data[key]
			"type": type = data[key]
			"group": group = data[key]
			"clipin": clipin = data[key]
			"startBeatNumber": startBeatNumber = data[key]
			"endBeatNumber": endBeatNumber = data[key]
			"dataPairs": 
				for pair in data[key]:
					var eventKey = pair["_eventDataKey"]
					var eventValue = pair["_eventDataValue"]
					match( eventKey ):
						"EnemyId": #id
							set_enemy_id( int(eventValue) )
							#data_dict[eventKey] = int(eventValue)
						"ShouldClampToSubdivisions": #always true?
							if eventValue is bool:
								eventValue = "True"
							if eventValue != "True":
								pass
							data_dict[eventKey] = eventValue
						"ShouldStartFacingRight":
							data_dict[eventKey] = eventValue
						"ShouldMoveOnDupletMeter":
							data_dict[eventKey] = eventValue
						"RiftedVibeChainShift":
							data_dict[eventKey] = eventValue
						"Bpm": #for adjust bpm
							data_dict[eventKey] = float(eventValue)
						"TrapTypeToSpawn": # just a string that corresponds to the enum name
							data_dict[eventKey] = eventValue
						"TrapDropRow":  #just int
							data_dict[eventKey] =  int(eventValue)
						"TrapHealthInBeats":  #just int
							data_dict[eventKey] =  int(eventValue)
						"TrapColor": #0-5
							data_dict[eventKey] = int(eventValue)
						"TrapDirection": #0-7
							data_dict[eventKey] = int(eventValue)
						"TrapChildSpawnRow":  #just int
							data_dict[eventKey] = int(eventValue)
						"TrapChildSpawnLane": #just int
							data_dict[eventKey] = int(eventValue)
						"BlademasterAttackRow":
							data_dict[eventKey] =  int(eventValue)
						_: print( eventKey )
				dataPairs = data[key]
			"audioEvents": audioEvents = data[key]
			_: print( key )
	
	track_width = get_parent().size.x/4
	
	position.x = (get_parent().size.x/4) * (track-.5)
	position.y = get_parent().size.y - (startBeatNumber+8) * 64
	
	update_texture()
	
	size = Vector2(32,32)
	
func set_trap_to_spawn( idx ):
	for key in RRTrapType.keys():
		if RRTrapType[key] == idx:
			data_dict["TrapTypeToSpawn"] = key
	update_texture()
	
func set_type( t ):
	match( t ):
		0:
			if type == "SpawnEnemy": return
			type = "SpawnEnemy"
			data_dict = {"EnemyId": EventDef.EnemyID.GreenSlime, "ShouldClampToSubdivisions": false }
		1:
			type = "SpawnRandomEnemy"
		2:
			if type == "SpawnTrap": return
			type = "SpawnTrap"
			data_dict = { "TrapTypeToSpawn": "Coals", "TrapDropRow": 7, "TrapHealthInBeats":8, "TrapColor":0, "TrapDirection": RRTrapDirection.Up, "TrapChildSpawnRow":6, "TrapChildSpawnLane":track  }
		3:
			type = "StartVibeChain"
			data_dict = {}
		4:
			type = "AdjustBPM"
			data_dict = { "Bpm":0 }
	update_texture()
	#SignalBus.event_selected.emit( self )
	
	
func get_offset_pos(x,y):
	var _x = ((int(track)+5+x)%3)+1 #5 = -1 but > 0 so % works
	_x = _x - track
	return Vector2(track_width*_x,-64*y)+Vector2(16,16)
	
var colour_white = Color(1, 1, 1, 1)
var colour_red = Color(0.8,0.2,0.2, 1.0)
var colour_green = 	Color(0.2,0.8,0.3, 1.0)
var colour_blue = Color(0.2,0.3,0.8, 1.0)
var colour_yellow = Color(0.7,0.8,0.2,1.0)
var colour_black = Color(0.2,0.2,0.2, 1.0)
	
var colour = Color.WHITE
	
func _draw():
	var is_trap = false
	var points = []
	var zero = get_parent().size.y
	var target_y = zero-((startBeatNumber) * 64) - 32
	var target_size = Vector2(32,32)
	var col = colour_green
	match( type ):
		"SpawnEnemy":
			var face_mul = -1
			if data_dict.has("ShouldStartFacingRight"):
				face_mul = 1
			
			match( data_dict["EnemyId"] ):
				EnemyID.GreenSlime: pass
				EnemyID.BlueSlime:
					points.append( get_offset_pos( 0, 1 ) )
					col = colour_blue
				EnemyID.YellowSlime:
					points.append( get_offset_pos( 0, 1 ) )
					points.append( get_offset_pos( 0, 2 ) )
					col = colour_yellow
				EnemyID.GreenZombie: pass
				EnemyID.RedZombie:
					col = colour_red
				EnemyID.BaseSkeleton:
					col = colour_white
				EnemyID.YellowSkeleton:
					col = colour_yellow
				EnemyID.BlackSkeleton:
					points.append( get_offset_pos(0, 1) )
					col = colour_black
				EnemyID.ShieldSkeleton:
					points.append( get_offset_pos(0, .5) )
					col = colour_white
				EnemyID.ShieldYellowSkeleton:
					col = colour_yellow
				EnemyID.ShieldBlackSkeleton:
					col = colour_black
				EnemyID.TripleShieldBaseSkeleton:
					points.append( get_offset_pos(0, .5) )
					points.append( get_offset_pos(0, 1) )
					col = colour_white
				EnemyID.RedArmadillo:
					points.append( get_offset_pos(0, .66) )
					col = colour_red
				EnemyID.BlueArmadillo:
					points.append( get_offset_pos(0, .33) )
					col = colour_blue
				EnemyID.YellowArmadillo:
					points.append( get_offset_pos(0, .33) )
					points.append( get_offset_pos(0, .66) )
					col = colour_yellow
				EnemyID.Harpy:
					pass
				EnemyID.StrongHarpy:
					points.append( get_offset_pos(0, 2) )
					col = colour_blue
				EnemyID.QuickHarpy:
					points.append( get_offset_pos(0, -4) )
					col = colour_red
				EnemyID.Apple:
					col = colour_red
				EnemyID.Cheese:
					points.append( get_offset_pos(0, 1) )
					col = colour_yellow
				EnemyID.Drumstick:
					points.append( get_offset_pos(0, 1) )
					points.append( get_offset_pos(0, 2) )
					col = colour_red
				EnemyID.Ham:
					points.append( get_offset_pos(0, 1) )
					points.append( get_offset_pos(0, 2) )
					points.append( get_offset_pos(0, 3) )
					col = colour_red
				EnemyID.WyrmHead:
					target_y = zero-(endBeatNumber * 64)
					target_size.y = (endBeatNumber-startBeatNumber)*64
				EnemyID.WyrmBody: pass
				EnemyID.WyrmTail: pass
				EnemyID.BlueBat:
					points.append( get_offset_pos(1*face_mul, 1) )
					col = colour_blue
				EnemyID.RedBat:
					points.append( get_offset_pos(1*face_mul, 1) )
					points.append( get_offset_pos(0, 2)  )
					col = colour_red
				EnemyID.YellowBat:
					points.append( get_offset_pos(1*face_mul, 1) )
					points.append( get_offset_pos(2*face_mul, 2) )
					col = colour_yellow
				EnemyID.BladeMaster:
					var early = data_dict["BlademasterAttackRow"]-2
					points.append( get_offset_pos(0, -early) )
					col = colour_red
				EnemyID.StrongBladeMaster:
					col = colour_blue
				EnemyID.YellowBladeMaster:
					col = colour_yellow
				EnemyID.Skull:
					points.append( get_offset_pos(0,1) )
					points.append( get_offset_pos(-1*face_mul,1) )
					col = colour_white
				EnemyID.StrongSkull: 
					points.append( get_offset_pos(0,1) )
					points.append( get_offset_pos(0,2) )
					points.append( get_offset_pos(-1*face_mul,2) )
					col = colour_blue
				EnemyID.TrickySkull:
					points.append( get_offset_pos(1*face_mul,1) )
					points.append( get_offset_pos(0,2) )
					points.append( get_offset_pos(1*face_mul,2) )
					
					col = colour_red
				_: print( "Unknown Type ",  data_dict["EnemyId"] )
		"SpawnRandomEnemy":
			pass
		"SpawnTrap":
			is_trap = true
		"StartVibeChain":
			col = colour_yellow
			target_y = zero-(endBeatNumber * 64)
			target_size.y = (endBeatNumber-startBeatNumber)*64

	
	position.y = target_y
	size = target_size
	col.a = 0.5
	draw_rect( Rect2i(Vector2(0,0), size),col, true )
	col.a = 1.0
	draw_rect( Rect2i(Vector2(0,0), size),col, false )
	colour = col
	var prev_point = Vector2(16, 16)
	for point in points:
		draw_circle( point, 4, col )
		draw_line( prev_point, point, col, 2 )
		prev_point = point

	draw_texture( texture, Vector2(0,size.y-32), )
	
	if is_trap:
		match( data_dict["TrapColor"] ):
			0: draw_texture( preload("res://sprites/color_a.png"), Vector2(0,0) )
			1: draw_texture( preload("res://sprites/color_b.png"), Vector2(0,0) )
			2: draw_texture( preload("res://sprites/color_c.png"), Vector2(0,0) )
			3: draw_texture( preload("res://sprites/color_d.png"), Vector2(0,0) )
			4: draw_texture( preload("res://sprites/color_e.png"), Vector2(0,0) )
			5: draw_texture( preload("res://sprites/color_f.png"), Vector2(0,0) )
		match( data_dict["TrapDirection"] ):
			RRTrapDirection.Up: 		draw_texture( preload("res://sprites/td_up.png"), Vector2(0,0) )
			RRTrapDirection.Right: 		draw_texture( preload("res://sprites/td_right.png"), Vector2(0,0) )
			RRTrapDirection.Down: 		draw_texture( preload("res://sprites/td_down.png"), Vector2(0,0) )
			RRTrapDirection.Left: 		draw_texture( preload("res://sprites/td_left.png"), Vector2(0,0) )
			RRTrapDirection.UpLeft: 	draw_texture( preload("res://sprites/td_upleft.png"), Vector2(0,0) )
			RRTrapDirection.UpRight: 	draw_texture( preload("res://sprites/td_upright.png"), Vector2(0,0) )
			RRTrapDirection.DownLeft: 	draw_texture( preload("res://sprites/td_downleft.png"), Vector2(0,0) )
			RRTrapDirection.DownRight: 	draw_texture( preload("res://sprites/td_downright.png"), Vector2(0,0) )
