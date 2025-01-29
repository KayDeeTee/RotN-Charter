extends OptionButton

var snaps = [1,2,3,4,5,6,8,12,16,24,32,48,64,96,128,256]
func _ready() -> void:
	for snap in snaps:
		add_item( "1/%d" % snap, snap )
	item_selected.connect( emit_sig )
	
func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed: return
		if event.keycode == Keybinds.snap_right:
			select( (selected + 1)%len(snaps) )
			item_selected.emit( selected )
		if event.keycode == Keybinds.snap_left:
			select( ((selected - 1)+len(snaps))%len(snaps) )
			item_selected.emit( selected )
	
func emit_sig( idx ):
	SignalBus.change_snap.emit( snaps[idx] )
	
