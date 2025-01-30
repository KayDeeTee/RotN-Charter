extends CodeEdit


class GDHighlight extends CodeHighlighter:
	
	var flow_control = ["if","elif","else","for","while","match","when","break","continue","pass","return"]
	var keywords = ["class","class_name","extends","is","in","as","self","super","signal","func","static","const","enum","var","breakpoint","await","yield","PI","TAU","INF","NAN"]
	var voids = ["void"]
	var asserts = ["preload","assert"]

	var flow_colour = Color("#ff8ccc")
	var keyword_colour = Color("#ff7085")
	var symbol_colour = Color("#abc9ff")
	var string_colour = Color("#ffeda1")
	var number_colour = Color("#a1ffe0")
	var member_colour = Color("#bce0ff")
	var function_colour = Color("#57b3ff")
	var comment_colour = Color("#cdcfd280")
	
	func _init():
		for keyword in flow_control: add_keyword_color( keyword, flow_colour )
		for keyword in keywords: add_keyword_color( keyword, keyword_colour )
		for keyword in asserts: add_keyword_color( keyword, symbol_colour )
		for keyword in voids: add_keyword_color( keyword, string_colour )
		
		function_color = function_colour
		member_variable_color = member_colour
		symbol_color = symbol_colour
		number_color = number_colour
		
		add_color_region("#", "", comment_colour, true)
		add_color_region("\"", "\"", string_colour, false)
		

func _ready() -> void:
	var code_highlight = GDHighlight.new()
	
	syntax_highlighter = code_highlight

@export var logger : Control

func run():
	logger.clear()
	
	var script = GDScript.new()
	script.source_code = text
		
	var err = script.reload()
	
	match( err ):
		OK:
			SignalBus.command_log.emit( "[center]-- Running Script --[/center]" )
			script.__run()	
			SignalBus.command_log.emit( "[center]-- Script Finished --[/center]" )
		ERR_PARSE_ERROR:
			SignalBus.command_log.emit( "[center]-- Parser Error --[/center]" )
			SignalBus.command_log.emit( "Run the charter from terminal/cmd and you will see something like:" )
			SignalBus.command_log.emit( "\n[color=#ad7fa8]SCRIPT ERROR: Parse Error: Identifier \"a\" not declared in the current scope.[/color]" )
			SignalBus.command_log.emit( "[color=#555753]          at: GDScript::reload (gdscript://-9223371914766972150.gd:15)" )
			SignalBus.command_log.emit( "\nThe gd:15 means the error is on line 15" )
		_:
			SignalBus.command_log.emit( "-- ERROR: %d --" % err )
			SignalBus.command_log.emit( "No idea what you did but congrats, you broke it!" )
