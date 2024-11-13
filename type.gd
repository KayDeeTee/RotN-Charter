extends OptionButton

enum Types {
	SpawnEnemy=0,
	SpawnRandomEnemy=1,
	SpawnTrap=2,
	StartVibeChain=3,
	AdjustBPM=4
}

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	item_selected.connect( on_change )
	for key in Types.keys():
		add_item( key, Types[key] )

func on_change(idx):
	for target in targets:
		target.set_type( get_item_id( idx ) )
	SignalBus.event_selected.emit( targets )

func update_target( event ):
	targets = event
	if len(targets) == 0: 
		visible = false
		return
	visible = true
	var idx = Types[targets[0].type]
	select( idx )
