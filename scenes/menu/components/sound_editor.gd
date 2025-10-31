extends HBoxContainer

const cnv_mul = 100
@export var bus: String
@export var label_text: String

@onready var slider = $VBoxContainer/Slider
@onready var line_edit = $LineEdit
@onready var label = $VBoxContainer/Label

func _ready() -> void:
	label.text = label_text
	var volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
	slider.value = db_to_linear(volume_db) * cnv_mul
	line_edit.text = str(float(slider.value))


func _on_line_edit_text_changed(new_text: String) -> void:
	var sanitized = ""
	var dot_used = false
	for c in new_text:
		if c >= "0" and c <= "9":
			sanitized += c
		elif c == "." and not dot_used:
			sanitized += c
			dot_used = true
	var value = 0.0
	if sanitized != "":
		value = float(sanitized)
	value = clamp(value, 0.0, 1.0)
	slider.value = value
	line_edit.text = sanitized
	set_bus_volume(value)


func _on_line_edit_text_submitted(new_text: String) -> void:
	_on_line_edit_text_changed(new_text)


func _on_slider_value_changed(value: float) -> void:
	var t = str(value)
	if value >= 100: t = str(int(value))
	line_edit.text = t
	set_bus_volume(value)

func set_bus_volume(linear_value: float) -> void:
	var db = linear_to_db(linear_value / cnv_mul)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)
