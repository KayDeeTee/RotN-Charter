extends OptionButton

var targets = []

func _ready() -> void:
	SignalBus.event_selected.connect( update_target )
	item_selected.connect( on_change )
	var keys = EventDef.EnemyID.keys()
	for key in keys:
		add_item( key, EventDef.EnemyID[key] )

func on_change(idx):
	for target in targets:
		target.set_enemy_id( get_item_id( idx ) )

func update_target( event ):
	targets = event
	if len( targets ) == 0:
		visible = false
		return
	if targets[0].type == "SpawnEnemy":
		var idx = get_item_index(targets[0].data_dict["EnemyId"])
		select( idx )
		visible = true
	else:
		visible = false
		
	
