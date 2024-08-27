extends Node
## Result Wrapper Management for return values
## 
## Creates and Stores return values for debugging purposes.

enum DebugLevels {NONE,MESSAGE,LOG,WARNING,ERROR,DEBUG,FATAL}
const DebugLevel := DebugLevels.FATAL

var _logs: Array[Result] = []
## The available results in a Stack like Array
var values: Array[Result] = []

func _init():
	print_rich("\n[color=grey][b]Logic Workbench Logger : [color=green]Initialised\n")

func close():
	print_rich("\n[color=grey][b]Logic Workbench Logger : [color=green]Saving")
	save()
	print_rich("[color=grey][b]Logic Workbench Logger : [color=red]Closing\n")
	while not self.is_queued_for_deletion():
		self.queue_free()

func save():
	return

func push(value: Result):
	values.push_back(value)
	_logs.push_back(value)
	print_entry(value)

func pop() -> Result:
	return values.pop_back()

func print_entry(e: Result):
	match DebugLevel:
		DebugLevels.NONE:
			return
		DebugLevels.MESSAGE:
			if e.is_message():
				e.to_output()
		DebugLevels.LOG:
			if e.is_message():
				e.to_output()
			elif e.is_log():
				e.to_output()
		DebugLevels.WARNING:
			if e.is_message():
				e.to_output()
			elif e.is_log():
				e.to_output()
			elif e.is_warning():
				e.to_output()
				push_warning(e)
		DebugLevels.ERROR:
			if e.is_message():
				e.to_output()
			elif e.is_log():
				e.to_output()
			elif e.is_warning():
				e.to_output()
				push_warning(e)
			elif e.is_error():
				e.to_output()
				push_error(e)
		DebugLevels.DEBUG:
			if e.is_message():
				e.to_output()
			elif e.is_log():
				e.to_output()
			elif e.is_warning():
				e.to_output()
				push_warning(e)
			elif e.is_error():
				e.to_output()
				push_error(e)
		DebugLevels.FATAL: # only errors / warnings
			if e.is_warning():
				e.to_output()
				push_warning(e)
			elif e.is_error():
				e.to_output()
				push_error(e)
