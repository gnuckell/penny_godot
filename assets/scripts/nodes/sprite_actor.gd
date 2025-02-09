
class_name SpriteActor extends CellNode

signal flag_changed(value : StringName)
signal eyes_changed(value : bool)
signal talking_changed(value : bool)

@export var voice_audio_player : Node
@export var sprite_flags : FlagController

var _is_talking : bool
@export var is_talking : bool :
	get: return _is_talking
	set(value):
		if _is_talking == value: return
		_is_talking = value

		talking_changed.emit(value)


func _ready() -> void:
	super._ready()

	if not self.flag_changed.is_connected(sprite_flags.set_current_flag):
		self.flag_changed.connect(sprite_flags.set_current_flag)
		self.talking_changed.connect(sprite_flags.set_talking_flag)
