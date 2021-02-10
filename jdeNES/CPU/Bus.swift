//
//  Bus.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Bus {
	let cpu = Nes6502()
	let ppu = Nes2C02()
	var cpuRam = [UInt8](repeating: 0, count: 0x1000)
	var cart: Cartridge!
	var systemClockCounter: UInt32 = 0
	
	init() {
		cpu.ConnectBus(self)
	}

	private subscript(x: UInt16) -> UInt8 {
		get {
			precondition(x < cpuRam.count)
			
			return cpuRam[Int(x)]
		}
		set(v) {
			precondition(x < cpuRam.count)
			
			cpuRam[Int(x)] = v
		}
	}

	func cpuWrite(addr: UInt16, data: UInt8) {
		if let _ = cart.cpuWrite(addr: addr, data: data) {
		} else if addr >= 0x0000 && addr <= 0x1FFF {
			self[addr & 0x07FF] = data
		} else if addr >= 0x2000 && addr <= 0x3FFF {
			ppu.cpuWrite(addr: addr & 0x0007, data: data)
		}
	}
	
	func cpuRead(addr: UInt16, readonly: Bool = false) -> UInt8 {
		var data: UInt8 = 0x00
		if let cartData = cart.cpuRead(addr: addr) {
			data = cartData
		}
		else if addr >= 0x0000 && addr <= 0x1FFF {
			data = self[addr & 0x07FF]
		} else if addr >= 0x2000 && addr <= 0x3FFF {
			data = ppu.cpuRead(addr: addr & 0x0007, readonly: readonly)
		}
		return data
	}
	
	func insertCartridge(_ cartridge: Cartridge) {
		cart = cartridge
		ppu.ConnectCartridge(cartridge)
	}

	func reset() {
		cpu.reset()
		systemClockCounter = 0
	}

	func clock() {
		ppu.clock()
		if systemClockCounter % 3 == 0 {
			cpu.clock()
		}

		if ppu.nmi {
			ppu.nmi = false
			cpu.nmi()
		}

		systemClockCounter += 1
	}
}
