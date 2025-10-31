extends Control


@onready var container = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var template = $VBoxContainer/ScrollContainer/VBoxContainer/Template
@onready var header_template = $VBoxContainer/ScrollContainer/VBoxContainer/Label
var text_template = "[color=gray]- {asset} от [color=white][wave]{author}[/wave] [color=blue][url={url}]{link}[/url]"
enum TYPE {
	Sound,
	Font
}

func type_to_header(type: TYPE) -> String:
	match type:
		TYPE.Font:
			return "< Шрифты >"
		TYPE.Sound:
			return "< Звуки и музыка >"
	return "unknown!"

func type_order() -> Array[TYPE]:
	return [
		TYPE.Font,
		TYPE.Sound
	]

func format(i: Dictionary) -> String:
	return text_template \
		.replace("{asset}", i["asset"]) \
		.replace("{author}", i["author"]) \
		.replace("{link}", i["link"])

var creds = [
	{"asset": "monogram", "author": "datagoblin", "link": "https://datagoblin.itch.io/monogram", "types": [TYPE.Font]},
	
	{"asset": "Shapeforms Audio Free Sound Effects", "author": "shapeforms", "link": "https://shapeforms.itch.io/shapeforms-audio-free-sfx", "types": [TYPE.Sound]},
	{"asset": "interface-sfx-pack-1", "author": "obsydianx", "link": "https://obsydianx.itch.io/interface-sfx-pack-1", "types": [TYPE.Sound]},
	{"asset": "Много всего", "author": "kenney", "link": "https://kenney.nl", "types": [TYPE.Sound]},
]

func header(t: TYPE) -> void:
	var h : Label = header_template.duplicate()
	h.text = type_to_header(t)
	container.add_child(h)


func item(i: Dictionary) -> void:
	var t = format(i)
	var d : RichTextLabel = template.duplicate()
	d.text = t
	container.add_child(d)
	

func _ready() -> void:
	var by_types = {}
	for c in creds:
		for t : TYPE in c["types"]:
			if by_types.keys().has(t):
				by_types[t].append(c)
			else:
				by_types[t] = [c]
	for t in type_order():
		header(t)
		if !by_types.keys().has(t): continue 
		for i in by_types[t]:
			item(i)
	template.hide()
	header_template.hide()
