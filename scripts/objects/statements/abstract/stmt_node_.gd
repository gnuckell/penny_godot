
## Statement that interacts with a PennyObject and its Node instance via the supplied Path.
class_name StmtNode extends Stmt

## Path to the object.
var subject_path : Path

var subject_node : Node :
	get:
		return self.subject_path.evaluate().local_instance


# func _init() -> void:
# 	pass


func _get_keyword() -> StringName:
	return 'node'


func _get_verbosity() -> Verbosity:
	return Verbosity.NODE_ACTIVITY


# func _validate_self() -> PennyException:
# 	return super._validate_self()


func _validate_self_post_setup() -> void:
	if tokens:
		subject_path = Path.from_tokens(tokens)
	else:
		subject_path = _get_default_subject()


# func _validate_cross() -> PennyException:
# 	return null


# func _execute(host: PennyHost) :
# 	return super._execute(host)


# func _undo(record: Record) -> void:
# 	if record.attachment:
# 		record.attachment.queue_free()


# func _next(record: Record) -> Stmt:
# 	return next_in_order


func _get_default_subject() -> Path:
	return Path.from_single(PennyObject.BILTIN_OBJECT_NAME)


func instantiate_node(host: PennyHost, path := subject_path) -> Node:
	var obj : PennyObject = path.evaluate()
	if obj:
		var node = obj.instantiate_from_lookup(host.get_layer(obj.preferred_layer))
		return node
	return null
