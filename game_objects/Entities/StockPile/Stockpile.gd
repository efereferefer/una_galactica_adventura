extends Control

var res_name: String
var amount: int

@onready var label = %Label


func setup(_name,_amount):
	res_name = _name
	amount = _amount
	label.text = "%s:%d" % [res_name, amount]
