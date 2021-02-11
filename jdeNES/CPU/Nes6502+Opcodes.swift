//
//  Nes6502+Opcodes.swift
//  jdeNES
//
//  Created by David Ensminger on 2/10/21.
//

extension Nes6502 {
	func ADC() -> Int {
		fetch()

		let temp = a + fetched + status[C]
		status[C] = (temp > 255) ? 1 : 0
		status[Z] = (temp & 0xFF) == 0 ? 1 : 0
		status[N] = (temp & 0x80) > 0 ? 1 : 0
		status[V] = (~(a ^ fetched) & (a ^ temp) & 0x0080) > 0 ? 1 : 0

		a = temp & 0xFF
		return 1
	}

	func AND() -> Int {
		fetch()
		a &= fetched
		status[Z] = a == 0x00 ? 1 : 0
		status[N] = a & 0x80 > 0 ? 1 : 0
		return 1
	}

	func ASL() -> Int {
		fetch()
		let temp = fetched << 1
		status[C] = (temp & 0xFF00) > 0 ? 1 : 0
		status[Z] = (temp & 0x00FF) == 0 ? 1 : 0
		status[N] = (temp & 0x80) > 0 ? 1 : 0
		if lookup[opcode].modeName == "IMP" {
			a = temp & 0xFF
		} else {
			write(addr: addr_abs, data: temp & 0x00FF)
		}
		return 0
	}

	func BCC() -> Int {
		if status[C] == 0 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BCS() -> Int {
		if status[C] == 1 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BEQ() -> Int {
		if status[Z] == 1 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BIT() -> Int {
		fetch()
		let temp = a & fetched
		status[Z] = temp == 0x00 ? 1 : 0
		status[N] = fetched & 0x80 > 0 ? 1 : 0
		status[V] = fetched & 0x40 > 0 ? 1 : 0
		return 0
	}

	func BMI() -> Int {
		if status[N] == 1 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BNE() -> Int {
		if status[Z] == 0 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BPL() -> Int {
		if status[N] == 0 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BRK() -> Int {
		pc = (pc + 1) & 0xFFFF

		status[I] = 1
		write(addr: 0x0100 + stkp, data: (pc >> 8) & 0x00FF)
		stkp = (stkp - 1) & 0xFF
		write(addr: 0x0100 + stkp, data: pc & 0x00FF)
		stkp = (stkp - 1) & 0xFF

		status[B] = 1
		write(addr: 0x0100 + stkp, data: status)
		stkp = (stkp - 1) & 0xFF
		status[B] = 0

		addr_abs = 0xFFFE
		let lo = read(addr: addr_abs)
		let hi = read(addr: addr_abs + 1)
		pc = (hi << 8) | lo
		return 0
	}

	func BVC() -> Int {
		if status[V] == 0 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func BVS() -> Int {
		if status[V] == 1 {
			cycles += 1
			addr_abs = (pc + addr_rel) & 0xFFFF

			if (addr_abs & 0xFF00) != (pc & 0xFF00) {
				cycles += 1
			}

			pc = addr_abs
		}
		return 0
	}

	func CLC() -> Int {
		status[C] = 0
		return 0
	}

	func CLD() -> Int {
		status[D] = 0
		return 0
	}

	func CLI() -> Int {
		status[I] = 0
		return 0
	}

	func CLV() -> Int {
		status[V] = 0
		return 0
	}

	func CMP() -> Int {
		fetch()
		let temp = a - fetched
		status[C] = a >= fetched ? 1 : 0
		status[Z] = temp == 0x00 ? 1 : 0
		status[N] = temp & 0x80 > 0 ? 1 : 0
		return 1
	}

	func CPX() -> Int {
		fetch()
		let temp = x - fetched
		status[C] = x >= fetched ? 1 : 0
		status[Z] = temp == 0x00 ? 1 : 0
		status[N] = temp & 0x80 > 0 ? 1 : 0
		return 1
	}

	func CPY() -> Int {
		fetch()
		let temp = y - fetched
		status[C] = y >= fetched ? 1 : 0
		status[Z] = temp == 0x00 ? 1 : 0
		status[N] = temp & 0x80 > 0 ? 1 : 0
		return 1
	}

	func DEC() -> Int {
		fetch()
		let temp = fetched - 1
		write(addr: addr_abs, data: temp)
		status[Z] = temp == 0x00 ? 1 : 0
		status[N] = (temp & 0x80) > 0 ? 1 : 0
		return 0
	}

	func DEX() -> Int {
		x = (x - 1) & 0xFF
		status[Z] = x == 0x00 ? 1 : 0
		status[N] = (x & 0x80) > 0 ? 1 : 0
		return 0
	}

	func DEY() -> Int {
		y = (y - 1) & 0xFF
		status[Z] = y == 0x00 ? 1 : 0
		status[N] = (y & 0x80) > 0 ? 1 : 0
		return 0
	}

	// Thanks for noticing me...
	func EOR() -> Int {
		fetch()
		a ^= fetched
		status[Z] = a == 0x00 ? 1 : 0
		status[N] = (a & 0x80) > 0 ? 1 : 0
		return 0
	}

	func INC() -> Int {
		fetch()
		let temp = (fetched + 1) & 0xFF
		write(addr: addr_abs, data: temp & 0xFF)
		status[Z] = temp == 0x00 ? 1 : 0
		status[N] = (temp & 0x80) > 0 ? 1 : 0
		return 0
	}

	func INX() -> Int {
		x = (x + 1) & 0xFF
		status[Z] = x == 0x00 ? 1 : 0
		status[N] = (x & 0x80) > 0 ? 1 : 0
		return 0
	}

	func INY() -> Int {
		y = (y + 1) & 0xFF
		status[Z] = y == 0x00 ? 1 : 0
		status[N] = (y & 0x80) > 0 ? 1 : 0
		return 0
	}

	func JMP() -> Int {
		pc = addr_abs
		return 0
	}

	func JSR() -> Int {
		pc = (pc - 1) & 0xFFFF

		write(addr: 0x0100 + stkp, data: (pc >> 8) & 0x00FF)
		stkp = (stkp - 1) & 0xFF
		write(addr: 0x0100 + stkp, data: pc & 0x00FF)
		stkp = (stkp - 1) & 0xFF

		pc = addr_abs
		return 0
	}

	func LDA() -> Int {
		fetch()
		a = fetched & 0xFF
		status[Z] = a == 0x00 ? 1 : 0
		status[N] = (a & 0x80) > 0 ? 1 : 0
		return 0
	}

	func LDX() -> Int {
		fetch()
		x = fetched & 0xFF
		status[Z] = x == 0x00 ? 1 : 0
		status[N] = (x & 0x80) > 0 ? 1 : 0
		return 0
	}

	func LDY() -> Int {
		fetch()
		y = fetched & 0xFF
		status[Z] = y == 0x00 ? 1 : 0
		status[N] = (y & 0x80) > 0 ? 1 : 0
		return 0
	}

	func LSR() -> Int {
		fetch()
		status[C] = fetched & 0x0001 > 0 ? 1 : 0
		let temp = fetched >> 1
		status[Z] = (temp & 0x00FF) == 0x0000 ? 1 : 0
		status[N] = (temp & 0x0080) > 0 ? 1 : 0
		if lookup[opcode].modeName == "IMP" {
			a = temp & 0xFF
		} else {
			write(addr: addr_abs, data: temp & 0x00FF)
		}
		return 0
	}

	func NOP() -> Int {
		if opcode == 0x1C || opcode == 0x3C || opcode == 0x5C || opcode == 0x7C || opcode == 0xDC || opcode == 0xFC {
			return 1
		}
		return 0
	}

	func ORA() -> Int {
		fetch()
		a |= fetched
		status[Z] = a == 0x00 ? 1 : 0
		status[N] = (a & 0x80) > 0 ? 1 : 0
		return 0
	}

	func PHA() -> Int {
		write(addr: 0x0100 + stkp, data: a)
		stkp = (stkp - 1) & 0xFF
		return 0
	}

	func PHP() -> Int {
		write(addr: 0x0100 + stkp, data: status | B | U)
		status[B] = 0
		status[U] = 0
		stkp = (stkp - 1) & 0xFF
		return 0
	}

	func PLA() -> Int {
		stkp = (stkp + 1) & 0xFF
		a = read(addr: 0x0100 + stkp)
		status[Z] = a == 0x00 ? 1 : 0
		status[N] = a & 0x80 > 0 ? 1 : 0
		return 0
	}

	func PLP() -> Int {
		stkp = (stkp + 1) & 0xFF
		status = read(addr: 0x0100 + stkp)
		status[U] = 1
		return 0
	}

	func ROL() -> Int {
		fetch()
		let temp = (fetched << 1) | status[C]
		status[C] = (temp & 0xFF00) > 0 ? 1 : 0
		status[Z] = (temp & 0x00FF) == 0x0000 ? 1 : 0
		status[N] = (temp & 0x0080) > 0 ? 1 : 0
		if lookup[opcode].modeName == "IMP" {
			a = temp & 0xFF
		} else {
			write(addr: addr_abs, data: temp & 0x00FF)
		}
		return 0
	}

	func ROR() -> Int {
		fetch()
		let temp = (status[C] << 7) | (fetched >> 1)
		status[C] = (fetched & 0x0001) > 0 ? 1 : 0
		status[Z] = (temp & 0x00FF) == 0x0000 ? 1 : 0
		status[N] = (temp & 0x0080) > 0 ? 1 : 0
		if lookup[opcode].modeName == "IMP" {
			a = temp & 0xFF
		} else {
			write(addr: addr_abs, data: temp & 0x00FF)
		}
		return 0
	}

	func RTI() -> Int {
		stkp = (stkp + 1) & 0xFF
		status = read(addr: 0x0100 + stkp)
		status[B] = 0
		status[U] = 0

		stkp = (stkp + 1) & 0xFF
		let lo = read(addr: 0x0100 + stkp)
		stkp = (stkp + 1) & 0xFF
		let hi = read(addr: 0x0100 + stkp)
		pc = (hi << 8) | lo
		return 0
	}

	func RTS() -> Int {
		stkp = (stkp + 1) & 0xFF
		let lo = read(addr: 0x0100 + stkp)
		stkp = (stkp + 1) & 0xFF
		let hi = read(addr: 0x0100 + stkp)

		pc = (hi << 8) | lo
		pc = (pc + 1) & 0xFFFF
		return 0
	}

	func SBC() -> Int {
		fetch()
		
		let value = fetched ^ 0x00FF
		let temp = a + value + status[C]
		status[C] = temp > 255 ? 1 : 0
		status[Z] = (temp & 0x00FF) == 0 ? 1 : 0
		status[N] = (temp & 0x80) > 0 ? 1 : 0
		status[V] = (((a ^ temp) & (value ^ temp)) & 0x0080) > 0 ? 1 : 0

		a = temp & 0xFF
		return 1
	}

	func SEC() -> Int {
		status[C] = 1
		return 0
	}

	func SED() -> Int {
		status[D] = 1
		return 0
	}

	func SEI() -> Int {
		status[I] = 1
		return 0
	}

	func STA() -> Int {
		write(addr: addr_abs, data: a)
		return 0
	}

	func STX() -> Int {
		write(addr: addr_abs, data: x)
		return 0
	}

	func STY() -> Int {
		write(addr: addr_abs, data: y)
		return 0
	}

	func TAX() -> Int {
		x = a & 0xFF
		status[Z] = (x & 0x00FF) == 0 ? 1 : 0
		status[N] = (x & 0x80) > 0 ? 1 : 0
		return 0
	}

	func TAY() -> Int {
		y = a & 0xFF
		status[Z] = (y & 0x00FF) == 0 ? 1 : 0
		status[N] = (y & 0x80) > 0 ? 1 : 0
		return 0
	}

	func TSX() -> Int {
		x = stkp & 0xFF
		status[Z] = (x & 0x00FF) == 0 ? 1 : 0
		status[N] = (x & 0x80) > 0 ? 1 : 0
		return 0
	}

	func TXA() -> Int {
		a = x & 0xFF
		status[Z] = (a & 0x00FF) == 0 ? 1 : 0
		status[N] = (a & 0x80) > 0 ? 1 : 0
		return 0
	}

	func TXS() -> Int {
		stkp = x
		return 0
	}

	func TYA() -> Int {
		a = y & 0xFF
		status[Z] = (a & 0x00FF) == 0 ? 1 : 0
		status[N] = (a & 0x80) > 0 ? 1 : 0
		return 0
	}

	func XXX() -> Int {
		return 0
	}
}
