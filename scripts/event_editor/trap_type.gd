extends OptionButton

enum TrapType {
		Coals,
		PortalIn,
		PortalOut,
		Bounce,
		Mystery,
		Wind,
		Freeze,
		DebugLock
}

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	item_selected.connect( on_change )
	for key in TrapType.keys():
		add_item( key, TrapType[key] )

func on_change(idx):
	for target in targets:
		target.set_trap_to_spawn( get_item_id( idx ) )

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		visible = false
		return
	if targets[0].type == "SpawnTrap":
		var idx = TrapType[targets[0].data_dict["TrapTypeToSpawn"]]
		select( idx )
		visible = true
	else:
		visible = false
		
	
