class_name SaveSlot extends PanelContainer

@onready var profile_name: Label = %ProfileName
@onready var rank: Label = %Rank
@onready var country: Label = %Country
@onready var balance: Label = %Balance
@onready var timestamp: Label = %Timestamp


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func configure(p_profile_name: String, p_rank: int, p_country: String, p_balance: int, p_timestamp: int) -> void:
	profile_name.text = p_profile_name
	rank.text = "%d" % p_rank
	country.text = p_country
	balance.text = "%d" % p_balance
	timestamp.text = "%d" % p_timestamp
