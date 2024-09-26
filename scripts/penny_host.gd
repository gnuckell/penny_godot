
## Node that actualizes Penny statements. This stores local data and records based on what the player chooses to do. Most applications will simply use an autoloaded, global host. For more advanced uses, you can instantiate multiple of these simultaneously for concurrent or even network-replicated instances. The records/state can be saved.
class_name PennyHost extends Node

## If populated, this host will start at this label on ready. Leave empty to not execute anything.
@export var autostart_label : StringName = ''

## Reference to a message handler. (Temporary. Eventually will be instantiated in code)
@export var message_handler : MessageHandler

## Reference to the history handler.
@export var history_handler : HistoryHandler

## Settings.
@export var settings : PennySettings

var records : Array[Record]

var last_record : Record :
	get: return records[records.size() - 1]

var _cursor : Address = null
var cursor : Address = null :
	get: return _cursor
	set (value):
		if _cursor == null:
			if _cursor == value: return
		elif _cursor.equals(value): return
		else: _cursor.free()
		_cursor = value.copy()

var cursor_stmt : Statement :
	get: return Penny.get_statement_from(cursor)
	set (value):
		cursor = value.address


var is_halting : bool :
	get: return cursor_stmt.is_halting

@onready var watcher := Watcher.new([message_handler])

func _ready() -> void:
	if not autostart_label.is_empty():
		jump_to.call_deferred(autostart_label)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('penny_advance'):
		if not watcher.working:
			advance()
		else: watcher.wrap_up_work()

func jump_to(label: StringName) -> void:
	cursor = Penny.get_address_from_label(label)
	invoke_at_cursor()

func invoke_at_cursor() -> void:
	var record := cursor_stmt.execute(self)
	records.push_back(record)
	history_handler.receive(record)

	if is_halting:
		pass
	else:
		advance()

func advance() -> void:
	if cursor == null: return
	cursor = last_record.get_next()

	if cursor_stmt == null:
		close()
		return

	invoke_at_cursor()

func close() -> void:
	message_handler.queue_free()
	queue_free()

func rewind_to(record: Record) -> void:
	cursor = record.address
	print("Rewinding to %s" % cursor)
	while records.size() > record.stamp:
		records.pop_back()
	history_handler.rewind_to(record)
	invoke_at_cursor()

func evaluate_expression(tokens: Array[Token]) -> Variant:
	if tokens[0].value == true: return true
	if tokens[0].value == false: return false
	return null
