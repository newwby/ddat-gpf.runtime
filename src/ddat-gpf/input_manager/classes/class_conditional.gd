extends Reference

class_name Conditional

##############################################################################
#
# Conditional is a bool extension for instances where you might want to set
# a bool to be true if multiple different states or conditions are true.
#
# As an example; during game loading some nodes may want to block
# player input whilst other nodes might want to allow player input for
# confirmation - if the exact order of loading can't be determined then a
# conditional can be used. Each node that wants to block input can set their
# own key with 'false' on a conditional whilst they are active; the conditional
# will return true if none of these input-blocking nodes are active and false
# if even one of them is active.
#
##############################################################################

# consts

# for passing to error logging
const SCRIPT_NAME := "Conditional"

# for developer use, enable if making changes
# in the case of this class be careful of adding too many verbose calls (esp.
# in the 'get_outcome' method, as an autoload (globalInput) references
# a conditional object on *every* input event
const VERBOSE_LOGGING := false

# private vars

# without any update to the 
var _default_state := true
# main return value for objects of the class; defaults to _default_state
var _output_state: bool = _default_state

# string keys, bool vals
# evaluates every bool against a presupposition of 'true' to see whether
# any false conditionals are presented, then returns (as output_state)
var _conditional_record := {}

###############################################################################

# virtual _init method


# arg1 is the bool that the conditional defaults to if the conditional
# record is empty. If arg isn't provided it will default to true.
func _init(conditional_default_state: bool = true):
	_default_state = conditional_default_state


###############################################################################

# public methods


func get_outcome() -> bool:
	# step logging
	GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME, "_get_outcome",
			"method.start, record = {get_rec}".format({
				"get_rec": _conditional_record
			}))
	# output is pre-calculated
	return _output_state


# developers should take care to remember to remove keys when the states
# that required setting the condition are no longer true; a vestige conditional
# key may result in unexpected behaviour.
# arg 1 is the key for the conditional record
# arg 2 is the value, if left empty it will default to false.
func set_condition(condition_key: String, condition_value: bool = false) -> void:
	#// not doing anything to the value so can just set it
#	if _conditional_record.has(condition_key):
#		_conditional_record[condition_key] = condition_value
	_conditional_record[condition_key] = condition_value
	# recalculate based on change in conditional_record
	_recalculate_output_state()


# remove a key from the condition record
func clear_condition(condition_key: String) -> void:
	pass
	if _conditional_record.has(condition_key):
		# erase should return void but debugger flagging warning
		var _return_arg_discard
		_return_arg_discard = _conditional_record.erase(condition_key)
		# recalculate based on change in conditional_record
		_recalculate_output_state()
	
	# improper method use logging
	else:
		# can produce excessive error pushes so flagged with verbose logging
		if VERBOSE_LOGGING:
			GlobalDebug.log_error(SCRIPT_NAME, "clear_condition",
					"trying to remove key({key}) that doesn't exist".format({
						"key": condition_key
					}))


###############################################################################

# private methods


# calculate the output state from the current conditional dict whenever
# a set_condition or clear_condition call is made
func _recalculate_output_state() -> void:
	# default state returned if no keys have been set or all keys are removed
	if _conditional_record.empty():
		_output_state = _default_state
	
	# calculate state from bools in the conditional record
	else:
		# returns true unless a false is present
		var calculated_value: bool = true
		var get_value
		for key in _conditional_record:
			get_value = _conditional_record[key]
			assert(typeof(get_value) == TYPE_BOOL)
			calculated_value = (calculated_value and get_value)
		
		_output_state = calculated_value
	
	GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
			"_recalculate_output_state",
			"new output state = {out}".format({"out": _output_state}))

