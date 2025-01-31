extends Node
class_name EventDef

enum TrapID {
		Coals = 0,
		PortalIn = 1,
		PortalOut = 2,
		Bounce = 3,
		Mystery = 4 ,
		Wind = 5,
		Freeze = 6 ,
		DebugLock = 7
}

enum EnemyID {
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

static var categories = []
static var definitions = {}
	
static func get_categories():
	if categories == []: get_cat_id( "slime/green" )
	return categories
	
static func get_type_id( _type, _id ):
	if definitions == {}: get_cat_id("slime/green")
	if TrapID.has( _id ): 
		_id = TrapID[_id]
	for key in definitions.keys():
		if definitions[key].type == _type and definitions[key].id == _id:
			return definitions[key]
	return null
	
static func get_cat_id( _cat_id ):
	if definitions == {}:
		EventDef.new(0, EnemyID.GreenSlime,				 	preload("res://sprites/green_slime.png"),		"slime","green" )
		EventDef.new(0, EnemyID.BlueSlime, 					preload("res://sprites/blue_slime.png"),		"slime","blue" )
		EventDef.new(0, EnemyID.YellowSlime, 				preload("res://sprites/yellow_slime.png"),		"slime","yellow" )
		EventDef.new(0, EnemyID.BaseSkeleton, 				preload("res://sprites/skeleton.png"),			"skeleton","1" )
		EventDef.new(0, EnemyID.ShieldSkeleton, 			preload("res://sprites/shield_skeleton.png"),	"skeleton","2" )
		EventDef.new(0, EnemyID.TripleShieldBaseSkeleton, 	preload("res://sprites/shield_double_skeleton.png"),	"skeleton","3" )
		EventDef.new(0, EnemyID.YellowSkeleton, 			preload("res://sprites/yellow_skeleton.png"),	"skeletony","1" )
		EventDef.new(0, EnemyID.ShieldYellowSkeleton, 		preload("res://sprites/shield_yellow_skeleton.png"),	"skeletony","2" )
		EventDef.new(0, EnemyID.BlackSkeleton, 				preload("res://sprites/black_skeleton.png"),	"skeletonb","1" )
		EventDef.new(0, EnemyID.ShieldBlackSkeleton, 		preload("res://sprites/shield_black_skeleton.png"),	"skeletonb","2" )
		EventDef.new(0, EnemyID.GreenZombie, 				preload("res://sprites/green_zombie.png"),	"zombie","green" )
		EventDef.new(0, EnemyID.RedZombie, 					preload("res://sprites/red_zombie.png"),	"zombie","red" )
		EventDef.new(0, EnemyID.WyrmHead, 					preload("res://sprites/wyrm_head.png"),	"wyrm","head" )
		EventDef.new(0, EnemyID.BlueBat, 					preload("res://sprites/blue_bat.png"),	"bat","blue" )
		EventDef.new(0, EnemyID.YellowBat, 					preload("res://sprites/yellow_bat.png"),	"bat","yellow" )
		EventDef.new(0, EnemyID.RedBat, 					preload("res://sprites/red_bat.png"),	"bat","red" )
		EventDef.new(0, EnemyID.Harpy, 						preload("res://sprites/green_harpy.png"),	"harpy","green" )
		EventDef.new(0, EnemyID.QuickHarpy, 				preload("res://sprites/red_harpy.png"),	"harpy","blue" )
		EventDef.new(0, EnemyID.StrongHarpy, 				preload("res://sprites/blue_harpy.png"),	"harpy","red" )
		EventDef.new(0, EnemyID.Skull, 						preload("res://sprites/skull.png"),	"skull","base" )
		EventDef.new(0, EnemyID.StrongSkull, 				preload("res://sprites/strong_skull.png"),	"skull","strong" )
		EventDef.new(0, EnemyID.TrickySkull, 				preload("res://sprites/tricky_skull.png"),	"skull","tricky" )
		EventDef.new(0, EnemyID.BladeMaster, 				preload("res://sprites/blademaster.png"),		"blademaster","red" )
		EventDef.new(0, EnemyID.StrongBladeMaster, 			preload("res://sprites/blue_blademaster.png"),	"blademaster","blue" )
		EventDef.new(0, EnemyID.YellowBladeMaster, 			preload("res://sprites/yellow_blademaster.png"),		"blademaster","yellow" )
		EventDef.new(0, EnemyID.BlueArmadillo, 				preload("res://sprites/blue_armadillo.png"),	"armadillo","blue" )
		EventDef.new(0, EnemyID.YellowArmadillo, 			preload("res://sprites/yellow_armadillo.png"),	"armadillo","yellow" )
		EventDef.new(0, EnemyID.RedArmadillo, 				preload("res://sprites/red_armadillo.png"),	"armadillo","red" )
		
		EventDef.new(0, EnemyID.Cheese, 					preload("res://sprites/cheese.png"),	"food","cheese" )
		EventDef.new(0, EnemyID.Apple, 						preload("res://sprites/apple.png"),	"food","apple" )
		EventDef.new(0, EnemyID.Drumstick, 					preload("res://sprites/drumstick.png"),	"food","drumstick" )
		EventDef.new(0, EnemyID.Ham, 						preload("res://sprites/ham.png"),	"food","ham" )
		
		
		EventDef.new(2, TrapID.Bounce, 						preload("res://sprites/bouncer.png"),	"traps_1","bouncer" )
		EventDef.new(2, TrapID.Coals, 						preload("res://sprites/coals.png"),	"traps_1","coals" )
		EventDef.new(2, TrapID.Freeze, 						preload("res://sprites/freeze.png"),	"traps_1","freeze" )

		EventDef.new(2, TrapID.Mystery, 					preload("res://sprites/mystery.png"),	"traps_2","mystery" )
		EventDef.new(2, TrapID.PortalIn, 					preload("res://sprites/portal_in.png"),	"traps_2","portal_in" )
		EventDef.new(2, TrapID.Wind, 						preload("res://sprites/wind.png"),	"traps_2","wind" )
		
		EventDef.new(3, 0, 									preload("res://sprites/vibe.png"),	"nonentity","vibe" )
		EventDef.new(4, 0, 									preload("res://sprites/bpm.png"),	"nonentity","adjustbpm" )
		
	return definitions[ _cat_id ]
	
func _init(_type, _id, _sprite, _cat, _subcat) -> void:
	type = _type
	id = _id
	sprite = _sprite
	cat = _cat
	subcat = _subcat
	cat_id = "%s/%s" % [cat, subcat]
	
	definitions[ cat_id ] = self
	if !categories.has( cat ): categories.append( cat )

var type : int #0 enemy, 1 random enemy, 2 trap, 3 vibe, 4 adjust bpm
var id : int
var sprite : Texture2D
var cat_id : String
var cat : String
var subcat : String
