extends SpinBox

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	value_changed.connect( on_change )

func on_change(v):
	for target in targets:
		if target.data_dict.has("Bpm"):
			target.data_dict["Bpm"] = v

func set_vis( v ):
	get_parent().visible = v

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		set_vis(false)
		return
	if targets[0].type == "AdjustBPM":
		set_value_no_signal(targets[0].data_dict["Bpm"])
		set_vis( true )
	else:
		set_value_no_signal(-1)
		set_vis( false )
