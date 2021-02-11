//
//  Nes6502+AddressingModes.swift
//  jdeNES
//
//  Created by David Ensminger on 2/10/21.
//

extension Nes6502 {
	func IMP() -> Int {
		fetched = a
		return 0
	}

	func IMM() -> Int {
		addr_abs = pc
		pc = (pc + 1) & 0xFFFF
		return 0
	}

	func ZP0() -> Int {
		addr_abs = read(addr: pc)
		pc = (pc + 1) & 0xFFFF
		addr_abs &= 0x00FF
		return 0
	}

	func ZPX() -> Int {
		addr_abs = read(addr: pc) + x
		pc = (pc + 1) & 0xFFFF
		addr_abs &= 0x00FF
		return 0
	}

	func ZPY() -> Int {
		addr_abs = read(addr: pc) + y
		pc = (pc + 1) & 0xFFFF
		addr_abs &= 0x00FF
		return 0
	}

	func REL() -> Int {
		addr_rel = read(addr: pc)
		if addr_rel & 0x80 > 0 {
			addr_rel -= 256
		}
		pc = (pc + 1) & 0xFFFF
		return 0
	}

	func ABS() -> Int {
		let lo = read(addr: pc)
		pc = (pc + 1) & 0xFFFF
		let hi = read(addr: pc)
		pc = (pc + 1) & 0xFFFF

		addr_abs = (hi << 8) | lo
		return 0
	}

	func ABX() -> Int {
		let lo = read(addr: pc)
		pc = (pc + 1) & 0xFFFF
		let hi = read(addr: pc)
		pc = (pc + 1) & 0xFFFF

		addr_abs = (hi << 8) | lo
		addr_abs = (addr_abs + x) & 0xFFFF

		if (addr_abs & 0xFF00) != (hi << 8) {
			return 1
		}
		return 0
	}

	func ABY() -> Int {
		let lo = read(addr: pc)
		pc = (pc + 1) & 0xFFFF
		let hi = read(addr: pc)
		pc = (pc + 1) & 0xFFFF

		addr_abs = (hi << 8) | lo
		addr_abs = (addr_abs + y) & 0xFFFF

		if (addr_abs & 0xFF00) != (hi << 8) {
			return 1
		}
		return 0
	}

	func IND() -> Int {
		let ptr_lo = read(addr: pc)
		pc = (pc + 1) & 0xFFFF
		let ptr_hi = read(addr: pc)
		pc = (pc + 1) & 0xFFFF

		let ptr = (ptr_hi << 8) | ptr_lo

		// there's a 6502 hardware bug in this instruction - emulate the bug so we get correct behavior
		if ptr_lo == 0xFF {
			addr_abs = (read(addr: ptr & 0xFF00) << 8) | read(addr: ptr)
		} else {
			addr_abs = (read(addr: ptr + 1) << 8) | read(addr: ptr)
		}
		return 0
	}

	func IZX() -> Int {
		let t = read(addr: pc)
		pc = (pc + 1) & 0xFFFF

		let lo = read(addr: (t + x)     & 0x00FF)
		let hi = read(addr: (t + x + 1) & 0x00FF)

		addr_abs = (hi << 8) | lo
		return 0
	}
	
	func IZY() -> Int {
		let t = read(addr: pc)
		pc = (pc + 1) & 0xFFFF

		let lo = read(addr: t & 0x00FF)
		let hi = read(addr: (t + 1) & 0x00FF)

		addr_abs = (hi << 8) | lo
		addr_abs = (addr_abs + y) & 0xFFFF

		if (addr_abs & 0xFF00) != (hi << 8) {
			return 1
		}
		return 0
	}

}
