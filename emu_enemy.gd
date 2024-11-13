extends Control
class_name RotN_Emu_Enemy

var emu_manager : RotN_Emu
var track : int = 0
var row = 1
var type : EnemyID = EnemyID.GreenSlime

var final_row = 9
var on_hit : Callable
var on_move : Callable

var is_headless_skeleton

var health = 1
var max_health = 1
var facing = -1
var subdiv = 1.0

func _ready() -> void:
	pass # Replace with function body.

var start_time = 0
func parse_event( event ):
	#visible = false
	update_texture(event)
	track = int(event.track - 1)
	start_time = event.startBeatNumber * emu_manager.beats_per_second
	if event.data_dict.has("ShouldStartFacingRight"):
		facing = 1
	type = event.data_dict["EnemyId"]
	position =  emu_manager.get_cell_pos(track, row-1)
	on_hit = default_hit
	on_move = default_move
	
	match( type ):
		EnemyID.Harpy:
			on_move = harpy_move
			on_hit = harpy_hit
		EnemyID.QuickHarpy:
			on_move = harpy_move
			on_hit = harpy_hit
		EnemyID.StrongHarpy:
			on_move = harpy_move
			on_hit = harpy_hit
			health = 2
			subdiv = 0.5
		EnemyID.GreenZombie:
			on_move = zombie_move
		EnemyID.YellowSlime:
			subdiv = 1
			health = 3
			on_hit = default_hit
		EnemyID.BlueSlime:
			subdiv = 1
			health = 2
			on_hit = default_hit
		EnemyID.BlackSkeleton:
			health = 3
			on_move = skeleton_move
			on_hit = skeleton_hit
		EnemyID.ShieldSkeleton:
			subdiv = 2
			health = 2
			on_hit = default_hit
		EnemyID.TripleShieldBaseSkeleton:
			subdiv = 2
			health = 3
			on_hit = default_hit
		EnemyID.YellowBat: 
			health = 3
			on_hit = bat_hit
		EnemyID.RedBat: 
			health = 3
			on_hit = bat_hit
		EnemyID.BlueBat: 
			health = 2
			on_hit = bat_hit
		EnemyID.BlueArmadillo:
			health = 2
			subdiv = 3
		EnemyID.YellowArmadillo:
			health = 3
			subdiv = 3
		EnemyID.RedArmadillo:
			health = 2
			subdiv = 1.5
		_: pass
	max_health = health
	last_move = start_time

var snap = true
var last_move = 0
func update(delta: float) -> void:
	visible = true
	var bslm = beats_since_last_move()
	if bslm > 0:
		visible = true
	if bslm > 1:
		on_move.call()
		if row != final_row:
			last_move += emu_manager.beats_per_second
		
	position = emu_manager.get_cell_pos(track, row-1)
	if row == final_row:
		on_hit.call()
		emu_manager.hit_track( track )
		
func default_move():
	row += 1
		
func beats_since_last_move():
	return (emu_manager.time*emu_manager.beats_per_second - last_move)/emu_manager.beats_per_second
	
func bat_hit():
	if health == max_health:
		track += facing
	else:
		if type == EnemyID.YellowBat:
			track += facing
		else:
			track -= facing
	track = (track + 3)%3
	health -= 1
	row -= 1
	last_move += emu_manager.beats_per_second/subdiv
	if health <= 0:
		die()

var harpy_moved = false
func harpy_move():
	if !harpy_moved or type == EnemyID.QuickHarpy:
		row += 2
	harpy_moved = !harpy_moved
	
func harpy_hit():
	health -= 1
	row -= 2
	last_move += emu_manager.beats_per_second/subdiv
	if health <= 0:
		die()
	

func zombie_move():
	if is_cell_free( track + facing, row+1):
		row += 1
		track += facing
		return
	else:
		facing *= -1
		if is_cell_free( track + facing, row+1):
			row += 1
			track += facing
			return
	row += 1
			

func is_cell_free(x,y):
	if x < 0:
		return false
	if x > 2:
		return false
	for child in emu_manager.get_children():
		if child == self: continue
		if child is not RotN_Emu_Enemy: continue
		if child.row == y and child.track == x: return false
	return true

func skeleton_move():
	if is_headless_skeleton:
		var free = true
		free = free and is_cell_free(track, row)
		free = free and is_cell_free(track, row-1)
		free = free and is_cell_free(track, row-2)
		if !free:		
			is_headless_skeleton = false
			row += 1
		else:
			row -= 1
	else:
		row += 1

func skeleton_hit():
	health -= 1
	row -= 1
	last_move += emu_manager.beats_per_second/subdiv
	if health == 1:
		is_headless_skeleton = true
	if health <= 0:
		die()
		
func default_hit():
	health -= 1
	row -= 1
	last_move += emu_manager.beats_per_second/subdiv
	if health <= 0:
		die()

func die():
	emu_manager.spawned_enemies.erase( self )
	queue_free()

func _draw():
	size = emu_manager.get_cell_size()
	var rect_size = size/4
	draw_texture( texture, Vector2(size/2-size/4) )

var texture : Texture2D

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

func update_texture(event):
	match( event.type ):
		"SpawnEnemy":			
			match( event.data_dict["EnemyId"] ):
				EnemyID.GreenSlime: texture = preload("res://sprites/green_slime.png")
				EnemyID.BlueSlime: texture = preload("res://sprites/blue_slime.png")
				EnemyID.YellowSlime: texture = preload("res://sprites/yellow_slime.png")
				EnemyID.GreenZombie: texture = preload("res://sprites/green_zombie.png")
				EnemyID.RedZombie: texture = preload("res://sprites/red_zombie.png")
				EnemyID.BaseSkeleton: texture = preload("res://sprites/skeleton.png")
				EnemyID.YellowSkeleton: texture = preload("res://sprites/yellow_skeleton.png")
				EnemyID.BlackSkeleton: texture = preload("res://sprites/black_skeleton.png")
				EnemyID.ShieldSkeleton: texture = preload("res://sprites/shield_skeleton.png")
				EnemyID.ShieldYellowSkeleton: texture = preload("res://sprites/shield_yellow_skeleton.png")
				EnemyID.ShieldBlackSkeleton: texture = preload("res://sprites/shield_black_skeleton.png")
				EnemyID.TripleShieldBaseSkeleton: texture = preload("res://sprites/shield_double_skeleton.png")
				EnemyID.RedArmadillo: texture = preload("res://sprites/red_armadillo.png")
				EnemyID.BlueArmadillo: texture = preload("res://sprites/blue_armadillo.png")
				EnemyID.YellowArmadillo: texture = preload("res://sprites/yellow_armadillo.png")
				EnemyID.Harpy: texture = preload("res://sprites/green_harpy.png")
				EnemyID.StrongHarpy: texture = preload("res://sprites/blue_harpy.png")
				EnemyID.QuickHarpy: texture = preload("res://sprites/red_harpy.png")
				EnemyID.Apple: texture = preload("res://sprites/apple.png")
				EnemyID.Cheese: texture = preload("res://sprites/cheese.png")
				EnemyID.Drumstick: texture = preload("res://sprites/drumstick.png")
				EnemyID.Ham: texture = preload("res://sprites/ham.png")
				EnemyID.WyrmHead: texture = preload("res://sprites/wyrm_head.png")
				EnemyID.WyrmBody: texture = preload("res://sprites/wyrm_body.png")
				EnemyID.WyrmTail: texture = preload("res://sprites/wyrm_tail.png")
				EnemyID.BlueBat: texture = preload("res://sprites/blue_bat.png")
				EnemyID.RedBat: texture = preload("res://sprites/red_bat.png")
				EnemyID.YellowBat: texture = preload("res://sprites/yellow_bat.png")
				EnemyID.BladeMaster: texture = preload("res://sprites/blademaster.png")
				EnemyID.StrongBladeMaster: texture = preload("res://sprites/blue_blademaster.png")
				EnemyID.YellowBladeMaster: texture = preload("res://sprites/yellow_blademaster.png")
				EnemyID.Skull: texture = preload("res://sprites/skull.png")
				EnemyID.StrongSkull: texture = preload("res://sprites/strong_skull.png")
				EnemyID.TrickySkull: texture = preload("res://sprites/tricky_skull.png")
				_: print( event.type )
	queue_redraw()
