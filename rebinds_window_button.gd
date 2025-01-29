extends TextureButton

@export var window : Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window.visibility_changed.connect( change_vis )
	pressed.connect( spawn_window )

func change_vis():
	visible = !window.visible

func spawn_window():
	window.show()
