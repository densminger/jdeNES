//
//  Nes6502.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Nes6502 {
	// Status
	let C = 0b0000_0001
	let Z = 0b0000_0010
	let I = 0b0000_0100
	let D = 0b0000_1000
	let B = 0b0001_0000
	let U = 0b0010_0000
	let V = 0b0100_0000
	let N = 0b1000_0000
	
	var bus: Bus!
	var a = 0x00
	var x = 0x00
	var y = 0x00
	var stkp = 0x00
	var pc = 0x0000
	var status = 0x00
	var fetched = 0x00
	var addr_abs = 0x0000
	var addr_rel = 0x00
	var opcode = 0x00
	var cycles = 0
	var clock_count = 0
	
	var lookup: [Instruction] = []
	func setupLookupTable() {
		lookup = [
			Instruction("BRK", BRK, "IMM", IMM, 7), Instruction("ORA", ORA, "IZX", IZX, 6), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 3), Instruction("ORA", ORA, "ZP0", ZP0, 3), Instruction("ASL", ASL, "ZP0", ZP0, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("PHP", PHP, "IMP", IMP, 3), Instruction("ORA", ORA, "IMM", IMM, 2), Instruction("ASL", ASL, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", NOP, "IMP", IMP, 4), Instruction("ORA", ORA, "ABS", ABS, 4), Instruction("ASL", ASL, "ABS", ABS, 6), Instruction("???", XXX, "IMP", IMP, 6),
			Instruction("BPL", BPL, "REL", REL, 2), Instruction("ORA", ORA, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 4), Instruction("ORA", ORA, "ZPX", ZPX, 4), Instruction("ASL", ASL, "ZPX", ZPX, 6), Instruction("???", XXX, "IMP", IMP, 6), Instruction("CLC", CLC, "IMP", IMP, 2), Instruction("ORA", ORA, "ABY", ABY, 4), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 7), Instruction("???", NOP, "IMP", IMP, 4), Instruction("ORA", ORA, "ABX", ABX, 4), Instruction("ASL", ASL, "ABX", ABX, 7), Instruction("???", XXX, "IMP", IMP, 7),
			Instruction("JSR", JSR, "ABS", ABS, 6), Instruction("AND", AND, "IZX", IZX, 6), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("BIT", BIT, "ZP0", ZP0, 3), Instruction("AND", AND, "ZP0", ZP0, 3), Instruction("ROL", ROL, "ZP0", ZP0, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("PLP", PLP, "IMP", IMP, 4), Instruction("AND", AND, "IMM", IMM, 2), Instruction("ROL", ROL, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("BIT", BIT, "ABS", ABS, 4), Instruction("AND", AND, "ABS", ABS, 4), Instruction("ROL", ROL, "ABS", ABS, 6), Instruction("???", XXX, "IMP", IMP, 6),
			Instruction("BMI", BMI, "REL", REL, 2), Instruction("AND", AND, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 4), Instruction("AND", AND, "ZPX", ZPX, 4), Instruction("ROL", ROL, "ZPX", ZPX, 6), Instruction("???", XXX, "IMP", IMP, 6), Instruction("SEC", SEC, "IMP", IMP, 2), Instruction("AND", AND, "ABY", ABY, 4), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 7), Instruction("???", NOP, "IMP", IMP, 4), Instruction("AND", AND, "ABX", ABX, 4), Instruction("ROL", ROL, "ABX", ABX, 7), Instruction("???", XXX, "IMP", IMP, 7),
			Instruction("RTI", RTI, "IMP", IMP, 6), Instruction("EOR", EOR, "IZX", IZX, 6), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 3), Instruction("EOR", EOR, "ZP0", ZP0, 3), Instruction("LSR", LSR, "ZP0", ZP0, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("PHA", PHA, "IMP", IMP, 3), Instruction("EOR", EOR, "IMM", IMM, 2), Instruction("LSR", LSR, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("JMP", JMP, "ABS", ABS, 3), Instruction("EOR", EOR, "ABS", ABS, 4), Instruction("LSR", LSR, "ABS", ABS, 6), Instruction("???", XXX, "IMP", IMP, 6),
			Instruction("BVC", BVC, "REL", REL, 2), Instruction("EOR", EOR, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 4), Instruction("EOR", EOR, "ZPX", ZPX, 4), Instruction("LSR", LSR, "ZPX", ZPX, 6), Instruction("???", XXX, "IMP", IMP, 6), Instruction("CLI", CLI, "IMP", IMP, 2), Instruction("EOR", EOR, "ABY", ABY, 4), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 7), Instruction("???", NOP, "IMP", IMP, 4), Instruction("EOR", EOR, "ABX", ABX, 4), Instruction("LSR", LSR, "ABX", ABX, 7), Instruction("???", XXX, "IMP", IMP, 7),
			Instruction("RTS", RTS, "IMP", IMP, 6), Instruction("ADC", ADC, "IZX", IZX, 6), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 3), Instruction("ADC", ADC, "ZP0", ZP0, 3), Instruction("ROR", ROR, "ZP0", ZP0, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("PLA", PLA, "IMP", IMP, 4), Instruction("ADC", ADC, "IMM", IMM, 2), Instruction("ROR", ROR, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("JMP", JMP, "IND", IND, 5), Instruction("ADC", ADC, "ABS", ABS, 4), Instruction("ROR", ROR, "ABS", ABS, 6), Instruction("???", XXX, "IMP", IMP, 6),
			Instruction("BVS", BVS, "REL", REL, 2), Instruction("ADC", ADC, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 4), Instruction("ADC", ADC, "ZPX", ZPX, 4), Instruction("ROR", ROR, "ZPX", ZPX, 6), Instruction("???", XXX, "IMP", IMP, 6), Instruction("SEI", SEI, "IMP", IMP, 2), Instruction("ADC", ADC, "ABY", ABY, 4), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 7), Instruction("???", NOP, "IMP", IMP, 4), Instruction("ADC", ADC, "ABX", ABX, 4), Instruction("ROR", ROR, "ABX", ABX, 7), Instruction("???", XXX, "IMP", IMP, 7),
			Instruction("???", NOP, "IMP", IMP, 2), Instruction("STA", STA, "IZX", IZX, 6), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 6), Instruction("STY", STY, "ZP0", ZP0, 3), Instruction("STA", STA, "ZP0", ZP0, 3), Instruction("STX", STX, "ZP0", ZP0, 3), Instruction("???", XXX, "IMP", IMP, 3), Instruction("DEY", DEY, "IMP", IMP, 2), Instruction("???", NOP, "IMP", IMP, 2), Instruction("TXA", TXA, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("STY", STY, "ABS", ABS, 4), Instruction("STA", STA, "ABS", ABS, 4), Instruction("STX", STX, "ABS", ABS, 4), Instruction("???", XXX, "IMP", IMP, 4),
			Instruction("BCC", BCC, "REL", REL, 2), Instruction("STA", STA, "IZY", IZY, 6), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 6), Instruction("STY", STY, "ZPX", ZPX, 4), Instruction("STA", STA, "ZPX", ZPX, 4), Instruction("STX", STX, "ZPY", ZPY, 4), Instruction("???", XXX, "IMP", IMP, 4), Instruction("TYA", TYA, "IMP", IMP, 2), Instruction("STA", STA, "ABY", ABY, 5), Instruction("TXS", TXS, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 5), Instruction("???", NOP, "IMP", IMP, 5), Instruction("STA", STA, "ABX", ABX, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("???", XXX, "IMP", IMP, 5),
			Instruction("LDY", LDY, "IMM", IMM, 2), Instruction("LDA", LDA, "IZX", IZX, 6), Instruction("LDX", LDX, "IMM", IMM, 2), Instruction("???", XXX, "IMP", IMP, 6), Instruction("LDY", LDY, "ZP0", ZP0, 3), Instruction("LDA", LDA, "ZP0", ZP0, 3), Instruction("LDX", LDX, "ZP0", ZP0, 3), Instruction("???", XXX, "IMP", IMP, 3), Instruction("TAY", TAY, "IMP", IMP, 2), Instruction("LDA", LDA, "IMM", IMM, 2), Instruction("TAX", TAX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("LDY", LDY, "ABS", ABS, 4), Instruction("LDA", LDA, "ABS", ABS, 4), Instruction("LDX", LDX, "ABS", ABS, 4), Instruction("???", XXX, "IMP", IMP, 4),
			Instruction("BCS", BCS, "REL", REL, 2), Instruction("LDA", LDA, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 5), Instruction("LDY", LDY, "ZPX", ZPX, 4), Instruction("LDA", LDA, "ZPX", ZPX, 4), Instruction("LDX", LDX, "ZPY", ZPY, 4), Instruction("???", XXX, "IMP", IMP, 4), Instruction("CLV", CLV, "IMP", IMP, 2), Instruction("LDA", LDA, "ABY", ABY, 4), Instruction("TSX", TSX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 4), Instruction("LDY", LDY, "ABX", ABX, 4), Instruction("LDA", LDA, "ABX", ABX, 4), Instruction("LDX", LDX, "ABY", ABY, 4), Instruction("???", XXX, "IMP", IMP, 4),
			Instruction("CPY", CPY, "IMM", IMM, 2), Instruction("CMP", CMP, "IZX", IZX, 6), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("CPY", CPY, "ZP0", ZP0, 3), Instruction("CMP", CMP, "ZP0", ZP0, 3), Instruction("DEC", DEC, "ZP0", ZP0, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("INY", INY, "IMP", IMP, 2), Instruction("CMP", CMP, "IMM", IMM, 2), Instruction("DEX", DEX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 2), Instruction("CPY", CPY, "ABS", ABS, 4), Instruction("CMP", CMP, "ABS", ABS, 4), Instruction("DEC", DEC, "ABS", ABS, 6), Instruction("???", XXX, "IMP", IMP, 6),
			Instruction("BNE", BNE, "REL", REL, 2), Instruction("CMP", CMP, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 4), Instruction("CMP", CMP, "ZPX", ZPX, 4), Instruction("DEC", DEC, "ZPX", ZPX, 6), Instruction("???", XXX, "IMP", IMP, 6), Instruction("CLD", CLD, "IMP", IMP, 2), Instruction("CMP", CMP, "ABY", ABY, 4), Instruction("NOP", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 7), Instruction("???", NOP, "IMP", IMP, 4), Instruction("CMP", CMP, "ABX", ABX, 4), Instruction("DEC", DEC, "ABX", ABX, 7), Instruction("???", XXX, "IMP", IMP, 7),
			Instruction("CPX", CPX, "IMM", IMM, 2), Instruction("SBC", SBC, "IZX", IZX, 6), Instruction("???", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("CPX", CPX, "ZP0", ZP0, 3), Instruction("SBC", SBC, "ZP0", ZP0, 3), Instruction("INC", INC, "ZP0", ZP0, 5), Instruction("???", XXX, "IMP", IMP, 5), Instruction("INX", INX, "IMP", IMP, 2), Instruction("SBC", SBC, "IMM", IMM, 2), Instruction("NOP", NOP, "IMP", IMP, 2), Instruction("???", SBC, "IMP", IMP, 2), Instruction("CPX", CPX, "ABS", ABS, 4), Instruction("SBC", SBC, "ABS", ABS, 4), Instruction("INC", INC, "ABS", ABS, 6), Instruction("???", XXX, "IMP", IMP, 6),
			Instruction("BEQ", BEQ, "REL", REL, 2), Instruction("SBC", SBC, "IZY", IZY, 5), Instruction("???", XXX, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 8), Instruction("???", NOP, "IMP", IMP, 4), Instruction("SBC", SBC, "ZPX", ZPX, 4), Instruction("INC", INC, "ZPX", ZPX, 6), Instruction("???", XXX, "IMP", IMP, 6), Instruction("SED", SED, "IMP", IMP, 2), Instruction("SBC", SBC, "ABY", ABY, 4), Instruction("NOP", NOP, "IMP", IMP, 2), Instruction("???", XXX, "IMP", IMP, 7), Instruction("???", NOP, "IMP", IMP, 4), Instruction("SBC", SBC, "ABX", ABX, 4), Instruction("INC", INC, "ABX", ABX, 7), Instruction("???", XXX, "IMP", IMP, 7)
		]
	}
	
	init() {
		setupLookupTable()
	}

	func ConnectBus(_ bus: Bus) {
		self.bus = bus
	}
	
	func read(addr: Int) -> Int {
		return bus.cpuRead(addr: addr & 0xFFFF) & 0xFF
	}
	
	func write(addr: Int, data: Int) {
		bus.cpuWrite(addr: addr & 0xFFFF, data: data & 0xFF)
	}
	
	func clock() {
		if cycles == 0 {
			opcode = read(addr: pc)
			pc = (pc + 1) & 0xFFFF

			let instruction = lookup[opcode]
			cycles = instruction.cycles
			let additional_cycle1 = instruction.addrMode()
			let additional_cycle2 = instruction.operate()

			if additional_cycle1 == 1 && additional_cycle2 == 1 {
				cycles += 1
			}
		}
		cycles -= 1
		clock_count += 1
	}
	
	func reset() {
		a = 0x00
		x = 0x00
		y = 0x00
		stkp = 0xFD
		status = 0x00 | U

		addr_abs = 0xFFFC
		let lo = read(addr: addr_abs)
		let hi = read(addr: addr_abs + 1)

		pc = (hi << 8) | lo

		addr_rel = 0x0000
		addr_abs = 0x0000
		fetched = 0x00

		cycles = 8
	}

	func irq() {
		if status[I] == 0 {
			write(addr: 0x0100 + stkp, data: (pc >> 8) & 0x00FF)
			stkp = (stkp - 1) & 0xFF
			write(addr: 0x0100 + stkp, data: pc & 0x00FF)
			stkp = (stkp - 1) & 0xFF

			status[B] = 0
			status[U] = 1
			status[I] = 1
			write(addr: 0x0100 + stkp, data: status)
			stkp = (stkp - 1) & 0xFF

			addr_abs = 0xFFFE
			let lo = read(addr: addr_abs)
			let hi = read(addr: addr_abs + 1)
			pc = (hi << 8) | lo

			cycles = 7
		}
	}

	func nmi() {
		write(addr: 0x0100 + stkp, data: (pc >> 8) & 0x00FF)
		stkp = (stkp - 1) & 0xFF
		write(addr: 0x0100 + stkp, data: pc & 0x00FF)
		stkp = (stkp - 1) & 0xFF

		status[B] = 0
		status[U] = 1
		status[I] = 1
		write(addr: 0x0100 + stkp, data: status)
		stkp = (stkp - 1) & 0xFF

		addr_abs = 0xFFFA
		let lo = read(addr: addr_abs)
		let hi = read(addr: addr_abs + 1)
		pc = (hi << 8) | lo

		cycles = 8
	}
	
	func fetch() {
		if lookup[opcode].modeName != "IMP" {
			fetched = read(addr: addr_abs)
		}
	}
	
	func disassemble(start: Int, stop: Int) -> [Int:String] {
		var addr = start
		var mapLines = [Int:String]()

		let hex: (Int, Int) -> String = { (n, x) in
			if x == 2 {
				return String(format: "%02X", n)
			} else if x == 4 {
				return String(format: "%04X", n)
			}
			return ""
		}

		while addr <= stop {
			let line_addr = addr

			var inst = "$" + hex(addr, 4) + ": "

			opcode = bus.cpuRead(addr: addr, readonly: true)
			addr += 1
			inst += lookup[opcode].name + " "

			if lookup[opcode].modeName == "IMP" {
				inst += " {IMP}"
			} else if lookup[opcode].modeName == "IMM" {
				let value = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "#$" + hex(value, 2) + " {IMM}"
			} else if lookup[opcode].modeName == "ZP0" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "$" + hex(lo, 2) + " {ZP0}"
			} else if lookup[opcode].modeName == "ZPX" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "$" + hex(lo, 2) + ", X {ZPX}"
			} else if lookup[opcode].modeName == "ZPY" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "$" + hex(lo, 2) + ", Y {ZPY}"
			} else if lookup[opcode].modeName == "IZX" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "($" + hex(lo, 2) + ", X) {IZX}"
			} else if lookup[opcode].modeName == "IZY" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "($" + hex(lo, 2) + "), Y {IZY}"
			} else if lookup[opcode].modeName == "ABS" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				let hi = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "$" + hex((hi << 8) | lo, 4) + " {ABS}"
			} else if lookup[opcode].modeName == "ABX" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				let hi = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "$" + hex((hi << 8) | lo, 4) + ", X {ABX}"
			} else if lookup[opcode].modeName == "ABY" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				let hi = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "$" + hex((hi << 8) | lo, 4) + ", Y {ABY}"
			} else if lookup[opcode].modeName == "IND" {
				let lo = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				let hi = bus.cpuRead(addr: addr, readonly: true)
				addr += 1
				inst += "($" + hex((hi << 8) | lo, 4) + ") {IND}"
			} else if lookup[opcode].modeName == "REL" {
				var value = bus.cpuRead(addr: addr, readonly: true)
				if value & 0x80 > 0 {
					value -= 256
				}
				addr += 1
				inst += "$" + hex(value & 0xFF, 2) + " [$" + hex(addr + value, 4) + "] {REL}"
			}

			mapLines[line_addr] = inst
		}

		return mapLines
	}
}
