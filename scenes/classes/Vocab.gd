class_name Vocab

var native_word: String;
var target_word: String;
var map_x: int;
var map_y: int;
var ui: Node;

func _init(in_native_word, in_target_word, in_x, in_y, in_ui):
	native_word = in_native_word
	target_word = in_target_word
	map_x = in_x
	map_y = in_y
	ui = in_ui 
	
func as_json():
	return {
		"map_x": self.map_x,
		"map_y": self.map_y,
		"native_word": self.native_word,
		"target_word": self.target_word
	}


