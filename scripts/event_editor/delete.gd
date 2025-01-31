extends Button

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	pressed.connect( delete )

func delete():
	for target in targets:
		target.queue_free()
		SignalBus.event_selected.emit( [] )

func update_target( event ):
	targets = event
	visible = !(targets == [])
