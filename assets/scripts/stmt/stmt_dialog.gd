
class_name StmtDialog extends StmtNode

const DEPTH_REMOVAL_PATTERN := r"(?<=\n)\t{0,%s}"
static var REGEX_WORD_COUNT := RegEx.create_from_string(r"\b\S+\b")
static var REGEX_CHAR_COUNT := RegEx.create_from_string(r"\S")


var subject_dialog_path : Cell.Ref
var pure_text : String


func _populate(tokens: Array) -> void:
	var regex_whitespace := RegEx.create_from_string(DEPTH_REMOVAL_PATTERN % self.depth)
	pure_text = regex_whitespace.sub(tokens.pop_back().value, "", true)

	super._populate(tokens)

	subject_dialog_path = subject_ref.duplicate()
	subject_dialog_path.ids.push_back(Cell.K_DIALOG)


func _execute(host: PennyHost) :
	var incoming_dialog : Cell = self.subject_dialog_path.evaluate()
	if not incoming_dialog:
		printerr("Attempted to create dialog box for '%s', but no such object exists" % self.subject_dialog_path)
		return create_record(host)
	var incoming_dialog_node : DialogNode
	var previous_dialog : Cell = host.last_dialog_object

	var previous_dialog_node : DialogNode
	var incoming_needs_creation : bool

	if previous_dialog != null:
		previous_dialog_node = previous_dialog.instance
		incoming_needs_creation = previous_dialog_node == null or previous_dialog != incoming_dialog
	else:
		previous_dialog_node = null
		incoming_needs_creation = true

	if incoming_needs_creation:
		if previous_dialog_node != null:
			await previous_dialog_node.close(true)
		incoming_dialog_node = incoming_dialog.instantiate(host)
		await incoming_dialog_node.open(true)
	else:
		incoming_dialog_node = previous_dialog_node

	var what := DisplayString.new_from_pure(pure_text)
	var result := create_record(host, { "who": subject, "what": what })
	incoming_dialog_node.receive(result)

	await incoming_dialog_node.advanced

	return result


func _abort(host: PennyHost) -> Record:
	var what := DisplayString.new_from_pure(pure_text)
	var result := create_record(host, { "who": subject, "what": what })
	return result
