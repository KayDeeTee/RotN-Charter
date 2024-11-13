extends OptionButton

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


var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	item_selected.connect( on_change )
	for key in RRTrapDirection.keys():
		add_item( key, RRTrapDirection[key] )

func on_change(idx):
	for target in targets:
		target.data_dict["TrapDirection"] = int(idx)
		target.queue_redraw()

func set_vis( v ):
	get_parent().visible = v

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		set_vis(false)
		return
	if targets[0].type == "SpawnTrap":
		select( targets[0].data_dict["TrapDirection"] )
		set_vis(true)
	else:
		set_vis(false)
		
