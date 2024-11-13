extends SpinBox

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

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	value_changed.connect( on_change )

func on_change(v):
	for target in targets:
		target.set_attack_row( v )

func set_vis( v ):
	get_parent().visible = v

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		set_vis(false)
		return
	if targets[0].type == "SpawnEnemy":
		if targets[0].data_dict["EnemyId"] == EnemyID.BladeMaster or targets[0].data_dict["EnemyId"] == EnemyID.StrongBladeMaster or targets[0].data_dict["EnemyId"] == EnemyID.YellowBladeMaster:
			set_value_no_signal(targets[0].data_dict["BlademasterAttackRow"])
			set_vis( true )
		else:
			set_value_no_signal(-1)
			set_vis( false )
	else:
		set_vis( false )
		
	
