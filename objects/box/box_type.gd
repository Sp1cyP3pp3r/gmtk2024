extends Node

enum Type {Normal, Floaty, Sticky}

func get_type(box_type : Type = Type.Normal) -> PackedScene:
	var box_scene : PackedScene
	match box_type:
		Type.Normal:
			box_scene = preload("res://objects/box/box.tscn")
		Type.Floaty:
			box_scene = preload("res://objects/box/box_floaty.tscn")
		Type.Sticky:
			box_scene = preload("res://objects/box/box_sticky.tscn")
	return box_scene
