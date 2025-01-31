extends Node

func json_default( json, key, default ):
	if json.has(key):
		return json[key]
	return default

func _init():
	if !FileAccess.file_exists( filepath ): return
	var f = FileAccess.open( filepath, FileAccess.READ )
	var json = JSON.parse_string( f.get_as_text() )
	
	scroll_up		= json_default( json, 		"up", 		KEY_UP )
	scroll_down 	= json_default( json, 		"down", 	KEY_DOWN )
	snap_left 		= json_default( json, 		"left", 	KEY_LEFT )
	snap_right 		= json_default( json, 		"right", 	KEY_RIGHT )

	#placing
	place_left 		= json_default( json, 		"1", 		KEY_Z )
	place_up 		= json_default( json, 		"2", 		KEY_X )
	place_right 	= json_default( json, 		"3", 		KEY_C )
	delete_row 		= json_default( json, 		"del", 		KEY_D )
	toggle_facing 	= json_default( json, 		"facing", 	KEY_F )
	
	shift_event_right 	= json_default( json, 		"event_right", 	KEY_E )
	shift_event_left 	= json_default( json, 		"event_left", 	KEY_Q )
	shift_event_up 		= json_default( json, 		"event_up", 	KEY_W )
	shift_event_down 	= json_default( json, 		"event_down", 	KEY_S )


func save_binds():
	var f = FileAccess.open( filepath, FileAccess.WRITE )
	var json = {}
	#cursor
	json["up"] 			= scroll_up
	json["down"] 		= scroll_down
	json["left"] 		= snap_left
	json["right"] 		= snap_right
	#placing
	json["1"] 			= place_left
	json["2"] 			= place_up
	json["3"] 			= place_right
	json["del"] 		= delete_row
	json["facing"] 		= toggle_facing
	
	json["event_right"] = shift_event_right
	json["event_left"] = shift_event_left
	json["event_up"] = shift_event_up
	json["event_down"] = shift_event_down

	
	f.store_string( JSON.stringify( json ) )
	
var filepath = "user://keybinds.json"

var scroll_up 		= KEY_UP
var scroll_down 	= KEY_DOWN
var snap_left 		= KEY_LEFT
var snap_right 		= KEY_RIGHT

var place_left		= KEY_Z
var place_up		= KEY_X
var place_right		= KEY_C
var delete_row		= KEY_D
var toggle_facing	= KEY_F

var shift_event_right 	= KEY_E
var shift_event_left 	= KEY_Q
var shift_event_up 		= KEY_W
var shift_event_down 	= KEY_S
