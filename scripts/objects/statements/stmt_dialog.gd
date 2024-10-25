
@tool
class_name StmtDialog extends StmtNode_

const REGEX_DEPTH_REMOVAL_PATTERN := "(?<=\\n)\\t{0,%s}"
static var REGEX_INTERPOLATION := RegEx.create_from_string("(?<!\\\\)(@([A-Za-z_]\\w*(?:\\.[A-Za-z_]\\w*)*)|\\[(.*?)\\])")
static var REGEX_INTERJECTION := RegEx.create_from_string("(?<!\\\\)(\\{.*?\\})")
static var REGEX_DECORATION := RegEx.create_from_string("(?<!\\\\)(<.*?>)")
static var REGEX_WORD_COUNT := RegEx.create_from_string("\\b\\S+\\b")
static var REGEX_CHAR_COUNT := RegEx.create_from_string("\\S")

var subject_dialog_path : Path
var raw_text : String

var text_stripped : String :
	get:
		var result : String = raw_text
		# result = REGEX_INTERPOLATION.sub(result, "$1", true)
		result = REGEX_INTERJECTION.sub(result, "", true)
		result = REGEX_DECORATION.sub(result, "", true)
		return result

var word_count : int :
	get: return REGEX_WORD_COUNT.search_all(text_stripped).size()

var char_count : int :
	get: return text_stripped.length()

var char_count_non_whitespace : int :
	get: return REGEX_CHAR_COUNT.search_all(text_stripped).size()

func _get_is_halting() -> bool:
	return true

func _get_verbosity() -> Verbosity:
	return Verbosity.MAX

func _get_keyword() -> StringName:
	return 'message'

func _execute(host: PennyHost) -> Record:
	var result := create_record(host, true)

	var previous_dialog : PennyObject = host.last_dialog_object
	var previous_dialog_node : PennyNode

	var incoming_dialog : PennyObject = self.subject_dialog_path.evaluate_deep(host.data_root)
	var incoming_dialog_node : PennyNode

	var incoming_needs_creation : bool = true
	if previous_dialog:
		previous_dialog_node = previous_dialog.local_instance
		incoming_needs_creation = previous_dialog_node == null or previous_dialog_node.appear_state >= PennyNode.AppearState.CLOSING or previous_dialog != incoming_dialog

	if incoming_needs_creation:
		incoming_dialog_node = self.instantiate_node(host, subject_dialog_path)
		incoming_dialog_node.populate(host, incoming_dialog)
		incoming_dialog_node.open_on_ready = previous_dialog_node == null
		if previous_dialog_node != null:
			previous_dialog_node.advance_on_free = false
			previous_dialog_node.tree_exited.connect(incoming_dialog_node.open)
			previous_dialog_node.close()
	else:
		incoming_dialog_node = previous_dialog_node

	if incoming_dialog_node is MessageHandler:
		incoming_dialog_node.receive(result, subject_path.evaluate_deep(host.data_root))
	elif incoming_dialog_node:
		host.cursor.create_exception("Attempted to send a message to a node, but it isn't a MessageHandler.").push()
	else:
		host.cursor.create_exception("Attempted to send a message to a node, but it wasn't created.").push()
	return result

func _message(record: Record) -> Message:
	var text : String = raw_text

	var rx_whitespace = RegEx.create_from_string(REGEX_DEPTH_REMOVAL_PATTERN % depth)

	while true:
		var match := REGEX_INTERPOLATION.search(text)
		if not match : break

		var interp_expr_string := match.get_string(2) + match.get_string(3)	## ~= $2$3

		var parser = PennyParser.new(interp_expr_string)
		var exceptions = parser.tokenize()
		if not exceptions.is_empty():
			for i in exceptions:
				i.push()
			break

		var inter_expr := Expr.from_tokens(self, parser.tokens)
		var result = inter_expr.evaluate(record.host.data_root)
		var result_string := str(result)

		text = text.substr(0, match.get_start()) + result_string + text.substr(match.get_end(), text.length() - match.get_end())

	text = rx_whitespace.sub(text, "", true)
	return Message.new(text)

func _validate() -> PennyException:
	if tokens.back().type != Token.VALUE_STRING:
		return create_exception("The last token must be a String.")
	return null

func _setup() -> void:
	raw_text = tokens.pop_back().value
	super._setup()
	subject_dialog_path = subject_path.duplicate()
	subject_dialog_path.ids.push_back(PennyObject.BILTIN_DIALOG_NAME)

