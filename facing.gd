extends CheckBox

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	toggled.connect( on_change )

func on_change(v):
	for target in targets:
		target.set_facing( v )

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		visible = false
		return
	if targets[0].type == "SpawnEnemy":
		visible = true
		if targets[0].data_dict.has( "ShouldStartFacingRight" ):
			set_pressed_no_signal( true )
		else:
			set_pressed_no_signal( false )
	else:
		visible = false
