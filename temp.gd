extends Control

func _ready():
	var res = test_adder_cic(true,true,false)
	for r in res:
		print(r)
	print("\n\n")
	
	get_tree().quit()

func test_adder_cir(in_a: bool,in_b: bool,in_cin: bool) -> Array[bool]: # circuit
	printerr("TEST - ADDER : CIRCUIT # START")
	var circuit = Circuit.new()
	print("\n\n")
	printerr("Create Gates")
	var and1 = AndGate.new(2)
	and1.gate_name = "and1"
	var and2 = AndGate.new(2)
	and2.gate_name = "and2"
	var xor1 = XorGate.new(2)
	xor1.gate_name = "xor1"
	var xor2 = XorGate.new(2)
	xor2.gate_name = "xor2"
	var or1 = OrGate.new(2)
	or1.gate_name = "or1"
	@warning_ignore("int_as_enum_without_cast")
	var a = InputGate.new(1,"A")
	@warning_ignore("int_as_enum_without_cast")
	var b = InputGate.new(1,"B")
	@warning_ignore("int_as_enum_without_cast")
	var cin = InputGate.new(1,"C IN")
	@warning_ignore("int_as_enum_without_cast")
	var sum = OutputGate.new(1,"SUM")
	@warning_ignore("int_as_enum_without_cast")
	var cout = OutputGate.new(1,"C OUT")
	print("\n\n")
	printerr("Add Gates")
	# Add gates
	circuit.add_gate(and1)
	circuit.add_gate(and2)
	circuit.add_gate(xor1)
	circuit.add_gate(xor2)
	circuit.add_gate(or1)
	circuit.add_gate(a)
	circuit.add_gate(b)
	circuit.add_gate(cin)
	circuit.add_gate(sum)
	circuit.add_gate(cout)
	print("\n\n")
	printerr("Add Connections")
	# Add Connections
	print("\n",a,"OUT",and1,"0")
	circuit.add_connection(a,"OUT",and1,"0")
	print("\n",b,"OUT",and1,"1")
	circuit.add_connection(b,"OUT",and1,"1")
	print("\n",a,"OUT",xor1,"0")
	circuit.add_connection(a,"OUT",xor1,"0")
	print("\n",b,"OUT",xor1,"1")
	circuit.add_connection(b,"OUT",xor1,"1")
	print(cin,"OUT",and2,"1")
	circuit.add_connection(cin,"OUT",and2,"1")
	print(cin,"OUT",xor2,"1")
	circuit.add_connection(cin,"OUT",xor2,"1")
	print("\n",and1,"OUT",and2,"0")
	circuit.add_connection(and1,"OUT",and2,"0")
	print("\n",xor1,"OUT",xor2,"0")
	circuit.add_connection(xor1,"OUT",xor2,"0")
	print("\n",xor1,"OUT",or1,"0")
	circuit.add_connection(and1,"OUT",or1,"0")
	print("\n",xor2,"OUT",or1,"1")
	circuit.add_connection(and2,"OUT",or1,"1")
	print("\n",and2,"OUT",sum,"IN")
	circuit.add_connection(xor2,"OUT",sum,"IN")
	print("\n",or1,"OUT",cout,"IN")
	circuit.add_connection(or1,"OUT",cout,"IN")
	print("\n\n")
	printerr("Simulation")
	# Testing Values
	@warning_ignore("int_as_enum_without_cast")
	var wire_true = Wire.new(1)
	wire_true.set_value([true])
	@warning_ignore("int_as_enum_without_cast")
	var wire_false = Wire.new(1)
	
	var cin_a: Wire = wire_true if in_a else wire_false
	var cin_b: Wire = wire_true if in_b else wire_false
	var cin_cin: Wire = wire_true if in_cin else wire_false
	
	circuit.set_input("A",cin_a)
	circuit.set_input("B",cin_b)
	circuit.set_input("C IN",cin_cin)
	
	var res_sum = circuit.get_output("SUM").unwrap().copy()
	var res_cout = circuit.get_output("C OUT").unwrap().copy()
	print("\n\n")
	printerr("Result")
	print(str(res_sum))
	print(str(res_cout))
	
	for connection in circuit.connections:
		print("\n",connection)
		print(connection.src_gate," : ",connection.src_output)
		print(connection.dest_gate," : ",connection.dest_input)
		print(str(connection.is_valid()))
	
	print("\n\n")
	
	for gate in circuit.gates.keys():
		gate = circuit.get_gate(gate).unwrap()
		
		for key in gate.inputs:
			print(key," : ",gate.inputs[key].copy())
			
		for key in gate.outputs:
			print(key," : ",gate.outputs[key].copy())
			
		print("\n")
	
	printerr("TEST - ADDER : CIRCUIT # END")
	return [res_sum,res_cout]

func test_adder_tt(in_a: bool,in_b: bool,in_cin: bool) -> Array[bool]: # truth table
	printerr("TEST - ADDER : TT # START")
	var circuit: Circuit = Circuit.new()
	var tt: TruthTable = TruthTable.new()
	print("\n\n")
	printerr("Create TruthTable")
	# Testing Values
	@warning_ignore("int_as_enum_without_cast")
	var wire_true = Wire.new(1)
	wire_true.set_value([true])
	@warning_ignore("int_as_enum_without_cast")
	var wire_false = Wire.new(1)
	
	tt.add_input("A",Wire.new(Wire.Sizes.S1))
	tt.add_input("B",Wire.new(Wire.Sizes.S1))
	tt.add_input("C IN",Wire.new(Wire.Sizes.S1))
	tt.add_output("SUM",Wire.new(Wire.Sizes.S1))
	tt.add_output("C OUT",Wire.new(Wire.Sizes.S1))
	tt.add_entry(
		{"A":wire_false,
		"B":wire_false,
		"C IN":wire_false},
		{"SUM":wire_false,
		"C OUT":wire_false}
		)
	tt.add_entry(
		{"A":wire_true,
		"B":wire_false,
		"C IN":wire_false},
		{"SUM":wire_true,
		"C OUT":wire_false}
		)
	tt.add_entry(
		{"A":wire_false,
		"B":wire_true,
		"C IN":wire_false},
		{"SUM":wire_true,
		"C OUT":wire_false}
		)
	tt.add_entry(
		{"A":wire_false,
		"B":wire_false,
		"C IN":wire_true},
		{"SUM":wire_true,
		"C OUT":wire_false}
		)
	tt.add_entry(
		{"A":wire_true,
		"B":wire_true,
		"C IN":wire_false},
		{"SUM":wire_false,
		"C OUT":wire_true}
		)
	tt.add_entry(
		{"A":wire_true,
		"B":wire_false,
		"C IN":wire_true},
		{"SUM":wire_false,
		"C OUT":wire_true}
		)
	tt.add_entry(
		{"A":wire_false,
		"B":wire_true,
		"C IN":wire_true},
		{"SUM":wire_false,
		"C OUT":wire_true}
		)
	tt.add_entry(
		{"A":wire_true,
		"B":wire_true,
		"C IN":wire_true},
		{"SUM":wire_true,
		"C OUT":wire_true}
		)
	
	circuit.set_truth_table(tt)
	print("\n\n")
	printerr("Simulate")
	
	var cin_a: Wire = wire_true if in_a else wire_false
	var cin_b: Wire = wire_true if in_b else wire_false
	var cin_cin: Wire = wire_true if in_cin else wire_false
	
	circuit.set_input("A",cin_a)
	circuit.set_input("B",cin_b)
	circuit.set_input("C IN",cin_cin)
	
	print("\n\n")
	printerr("Result")
	print(tt,"\n")
	print(tt.inputs,"\n",circuit.inputs,"\n")
	print(tt.outputs,"\n",circuit.outputs,"\n")
	var res_sum = circuit.get_output("SUM").unwrap().copy()
	var res_cout = circuit.get_output("C OUT").unwrap().copy()
	
	printerr("TEST - ADDER : TT # END")
	print([res_sum,"\n",res_cout])
	return [res_sum,res_cout]

func test_adder_cic(in_a: bool,in_b: bool,in_cin: bool) -> Array [bool]: # circuit in circuit
	printerr("TEST - ADDER : CIRCUIT IN CIRCUIT # START")
	var half_adder: Circuit = Circuit.new()
	print("\n\n")
	printerr("Half Adder - Create Gates")
	var xorGate := XorGate.new(2)
	var andGate := AndGate.new(2)
	var a := InputGate.new(Wire.Sizes.S1,"A")
	var b := InputGate.new(Wire.Sizes.S1,"B")
	var s := OutputGate.new(Wire.Sizes.S1,"S") # sum
	var c := OutputGate.new(Wire.Sizes.S1,"C") # Carry
	print("\n\n")
	printerr("Half Adder - Add Gates")
	half_adder.add_gate(andGate)
	half_adder.add_gate(xorGate)
	half_adder.add_gate(a)
	half_adder.add_gate(b)
	half_adder.add_gate(s)
	half_adder.add_gate(c)
	print("\n\n")
	printerr("Half Adder - Add Connections")
	half_adder.add_connection(a,"OUT",xorGate,"0")
	half_adder.add_connection(b,"OUT",xorGate,"1")
	half_adder.add_connection(a,"OUT",andGate,"0")
	half_adder.add_connection(b,"OUT",andGate,"1")
	half_adder.add_connection(xorGate,"OUT",s,"IN")
	half_adder.add_connection(andGate,"OUT",c,"IN")
	print("\n\n")
	printerr("Half Adder - Done")
	var circuit := Circuit.new()
	print("\n\n")
	printerr("Full Adder - Create Gates")
	var c_in_a := InputGate.new(Wire.Sizes.S1,"A")
	var c_in_b := InputGate.new(Wire.Sizes.S1,"B")
	var c_in_c := InputGate.new(Wire.Sizes.S1,"C")
	
	var add_1 := half_adder.copy()
	var add_2 := half_adder.copy()
	var orGate := OrGate.new(2)
	
	var c_out_s := OutputGate.new(Wire.Sizes.S1,"S")
	var c_out_c := OutputGate.new(Wire.Sizes.S1,"C")
	print("\n\n")
	printerr("Full Adder - Add Gates")
	circuit.add_gate(c_in_a)
	circuit.add_gate(c_in_b)
	circuit.add_gate(c_in_c)
	circuit.add_gate(add_1)
	circuit.add_gate(add_2)
	circuit.add_gate(orGate)
	circuit.add_gate(c_out_s)
	circuit.add_gate(c_out_c)
	print("\n\n")
	printerr("Full Adder - Add Connections")
	circuit.add_connection(c_in_a,"OUT",add_1,"A")
	circuit.add_connection(c_in_b,"OUT",add_1,"B")
	circuit.add_connection(add_1,"S",add_2,"A")
	circuit.add_connection(c_in_c,"OUT",add_2,"B")
	circuit.add_connection(add_1,"C",orGate,"0")
	circuit.add_connection(add_2,"C",orGate,"1")
	circuit.add_connection(add_2,"S",c_out_s,"IN")
	circuit.add_connection(orGate,"OUT",c_out_s,"IN")
	print("\n\n")
	printerr("Full Adder - Simulate")
	# Testing Values
	var wire_true = Wire.new(Wire.Sizes.S1)
	wire_true.set_value([true])
	var wire_false = Wire.new(Wire.Sizes.S1)
	
	var cin_a: Wire = wire_true if in_a else wire_false
	var cin_b: Wire = wire_true if in_b else wire_false
	var cin_cin: Wire = wire_true if in_cin else wire_false
	
	circuit.set_input("A",cin_a)
	circuit.set_input("B",cin_b)
	circuit.set_input("C",cin_cin)
	
	var res_sum = circuit.get_output("S").unwrap().copy()
	var res_cout = circuit.get_output("C").unwrap().copy()
	
	print("\n\n")
	printerr("Full Adder - Result")
	print(str(res_sum))
	print(str(res_cout))
	
	for connection in circuit.connections:
		print("\n",connection)
		print(connection.src_gate," : ",connection.src_output)
		print(connection.dest_gate," : ",connection.dest_input)
		print(str(connection.is_valid()))
	
	print("\n\n")
	
	for gate in circuit.gates.keys():
		gate = circuit.get_gate(gate).unwrap()
		
		for key in gate.inputs:
			print(key," : ",gate.inputs[key].copy())
			
		for key in gate.outputs:
			print(key," : ",gate.outputs[key].copy())
			
		print("\n")
	return [res_sum,res_cout]
