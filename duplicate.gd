extends Button

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	pressed.connect( duplic )

func duplic():
	for target in targets:
		var t = target.duplicate()
		t.track = target.track
		t.startBeatNumber = target.startBeatNumber
		t.endBeatNumber = target.endBeatNumber
		t.type = target.type
		t.clipin = 0
		t.group = 0
		for key in target.data_dict.keys():
			t.data_dict[key] = target.data_dict[key]
		target.get_parent().add_child(t)

func update_target( event ):
	targets = event
	visible = !(targets == [])
