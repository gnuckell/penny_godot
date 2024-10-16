
class_name ObjectPath extends RefCounted

var identifiers : Array[StringName]

func _init(_identifiers: Array[StringName]) -> void:
	identifiers = _identifiers

static func from_tokens(tokens: Array[Token]) -> ObjectPath:
	var ids : Array[StringName]
	var l = floor(tokens.size() * 0.5) + 1
	for i in l:
		ids.push_back(tokens[i * 2].value)
	return ObjectPath.new(ids)

static func from_string(s: String) -> ObjectPath:
	var ids : Array[StringName]
	var split := s.split(".", false)
	for i in split:
		ids.push_back(StringName(i))
	return ObjectPath.new(ids)

func _to_string() -> String:
	var result := ""
	for i in identifiers:
		result += i + "."
	return result.substr(0, result.length() - 1)

func get_data(host: PennyHost) -> Variant:
	var result : Variant = host.data
	for i in identifiers:
		result = result.get_data(i)
	return result

func set_data(host: PennyHost, _value: Variant) -> void:
	var result : PennyObject = host.data
	for i in identifiers.size() - 1:
		result = result.get_data(identifiers[i])
	result.set_data(identifiers.back(), _value)

func add_object(host: PennyHost) -> PennyObject:
	var result : PennyObject = PennyObject.new({'name': self.to_string()})
	set_data(host, result)
	return result

func prepend(other: ObjectPath) -> void:
	var temp = identifiers.duplicate()
	identifiers = other.identifiers.duplicate()
	identifiers.append_array(temp)
