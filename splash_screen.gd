extends Control

@onready var typewriter_rich_text_label: TypewriterRichTextLabel = $TypewriterRichTextLabel

func _init() -> void:
	pass


func _ready() -> void:
	typewriter_rich_text_label.play()
