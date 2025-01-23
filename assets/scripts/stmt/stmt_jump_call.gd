
class_name StmtJumpCall extends StmtJump

# func _init() -> void:
# 	pass


# func _get_verbosity() -> Verbosity:
# 	return super._get_verbosity()


func _execute(host: PennyHost) :
	host.call_stack.push_back(next_in_order)
	return super._execute(host)


func _undo(record: Record) -> void:
	record.host.call_stack.pop_back()


func _redo(record: Record) -> void:
	record.host.call_stack.push_back(next_in_order)


# func _next(record: Record) -> Stmt:
# 	return next_in_order
