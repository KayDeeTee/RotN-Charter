extends VBoxContainer

func _ready() -> void:
	SignalBus.command_log.connect( add_log )
	
func clear():
	for child in get_children():
		child.queue_free()
	
func add_log( string ):
	var rtl = RichTextLabel.new()
	rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rtl.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	rtl.text = string
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	add_child( rtl )
