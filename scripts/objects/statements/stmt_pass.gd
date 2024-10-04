
## Speaks nothing. Hears nothing. Sees nothing. Is nothing.
class_name StmtPass extends Stmt

func _get_keyword() -> StringName:
	return "pass"

func _get_verbosity() -> int:
	return 4

func _execute(host: PennyHost) -> Record:
	return super._execute(host)

func _undo(record: Record) -> void:
	pass

func _message(record: Record) -> Message:
	return super._message(record)

func _validate() -> PennyException:
	return validate_as_no_tokens()
