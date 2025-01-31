extends TextureButton

@export var window : Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window.close_requested.connect( hide_window )
	window.visibility_changed.connect( change_vis )
	pressed.connect( spawn_window )

func hide_window():
	window.hide()

func change_vis():
	visible = !window.visible

func spawn_window():
	window.show()
