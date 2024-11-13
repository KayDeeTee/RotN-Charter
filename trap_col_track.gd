extends SpinBox

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	value_changed.connect( on_change )

func on_change(v):
	for target in targets:
		target.data_dict["TrapChildSpawnLane"] = v

func set_vis( v ):
	get_parent().visible = v

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		set_vis( false )
		return
	if targets[0].type == "SpawnTrap":
		set_vis(true)
		set_value_no_signal( targets[0].data_dict["TrapChildSpawnLane"] )
	else:
		set_vis( false )
