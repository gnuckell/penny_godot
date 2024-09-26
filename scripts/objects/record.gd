
## Record of a statement that has occurred. Records that share the same statement are not necessarily equal as they can have occurred at different stamps (times).
class_name Record extends Object

var host : PennyHost
var stamp : int
var address : Address
var message : Message
var attachment : Variant

var statement : Statement :
	get: return Penny.get_statement_from(address)
	set (value):
		address = value.address

var verbosity : int :
	get:
		match statement.type:

			## Player Essentials
			Statement.MESSAGE, Statement.MENU: return 0

			## Debug Essentials
			Statement.ASSIGN, Statement.PRINT: return 1

			## Debug Helpers
			Statement.JUMP, Statement.RISE, Statement.DIVE, Statement.CONDITION: return 2

			## Debug Markers
			Statement.LABEL: return 3

		return -1

func _init(__host: PennyHost, __statement: Statement) -> void:
	host = __host
	stamp = host.records.size()
	statement = __statement
	message = Message.new(statement)

func _to_string() -> String:
	return "Record : stamp %s, address %s" % [stamp, address]

func equals(other: Record) -> bool:
	return host == other.host and stamp == other.stamp

func get_next() -> Address:
	var result = statement.address.copy()
	match statement.type:
		Statement.CONDITION:
			if attachment:
				result.index += 1
			else:
				result.index += 2
		_:
			result.index += 1
	return result
