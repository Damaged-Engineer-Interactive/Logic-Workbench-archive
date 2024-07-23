extends Node
## Result Wrapper Management for return values
## 
## Creates and Stores return values for debugging purposes.

var _logs: Array[Result] = []
## The available results in a Stack like Array
var values: Array[Result] = []

func push(value: Result):
	values.push_back(value)
	_logs.push_back(value)

func pop():
	return values.pop_back()

