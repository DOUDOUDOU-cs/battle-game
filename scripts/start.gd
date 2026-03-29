extends Control

@onready var start_button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	InventoryUI.visible = false

func _on_start_pressed() -> void:
	InventoryUI.visible = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
