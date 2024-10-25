
## Statement that interacts with a PennyObject and its Node instance via the supplied Path.
class_name StmtNode_ extends Stmt_

var subject_path : Path

func _init(_address: Address, _line: int, _depth: int, _tokens: Array[Token]) -> void:
	super._init(_address, _line, _depth, _tokens)

# func _get_is_halting() -> bool:
# 	return false

func _get_keyword() -> StringName:
	return 'node'

func _get_verbosity() -> Verbosity:
	return Verbosity.NODE_ACTIVITY

# func _is_record_shown_in_history(record: Record) -> bool:
# 	return true

# func _load() -> PennyException:
# 	return null

# func _execute(host: PennyHost) -> Record:
# 	return super._execute(host)

# func _next(record: Record) -> Stmt_:
# 	return next_in_order

# func _undo(record: Record) -> void:
# 	if record.attachment:
# 		record.attachment.queue_free()

func _message(record: Record) -> Message:
	return super._message(record)

func _validate() -> PennyException:
	return null

func _setup() -> void:
	if tokens:
		subject_path = Path.from_tokens(tokens)
	else:
		subject_path = Path.new([PennyObject.BILTIN_OBJECT_NAME])


func instantiate_node(host: PennyHost, path := subject_path) -> Node:
	var obj : PennyObject = path.evaluate_deep(host.data_root)
	if obj:
		var node = obj.instantiate_from_lookup(host)
		return node
	return null

# func instantiate_node(host: PennyHost, path := subject_path) -> Node:
# 	return obj.instantiate(host)

func get_existing_node(host: PennyHost, path := subject_path) -> Node:
	var obj : PennyObject = path.evaluate_deep(host.data_root)
	if obj:
		var node : Node = obj.local_instance
		return node
	return null
