//
//  Bus.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Bus {
	let cpu = Nes6502()
	let ppu = Nes2C02()
	var cpuRam = [Int](repeating: 0, count: 0xFFFF)
	var cart: Cartridge!
	var controller = [Int](repeating: 0, count: 2)

	private var systemClockCounter: Int = 0
	private var controller_state = [Int](repeating: 0, count: 2)
	
	// DMA stuff
	private var dma_page = 0
	private var dma_addr = 0
	private var dma_data = 0
	private var dma_transfer = false
	private var dma_dummy = true

	init() {
		cpu.ConnectBus(self)
	}

	func cpuWrite(addr: Int, data: Int) {
		if let _ = cart.cpuWrite(addr: addr, data: data) {
		} else if addr >= 0x0000 && addr <= 0x1FFF {
			cpuRam[addr & 0x07FF] = data
		} else if addr >= 0x2000 && addr <= 0x3FFF {
			ppu.cpuWrite(addr: addr & 0x0007, data: data)
		} else if addr == 0x4014 {
			dma_page = data
			dma_addr = 0
			dma_transfer = true
		} else if addr >= 0x4016 && addr <= 0x4017 {
			controller_state[addr & 0x0001] = controller[addr & 0x0001]
		}
	}
	
	func cpuRead(addr: Int, readonly: Bool = false) -> Int {
		var data = 0x00
		if let cartData = cart.cpuRead(addr: addr) {
			data = cartData
		}
		else if addr >= 0x0000 && addr <= 0x1FFF {
			data = cpuRam[addr & 0x07FF]
		} else if addr >= 0x2000 && addr <= 0x3FFF {
			data = ppu.cpuRead(addr: addr & 0x0007, readonly: readonly)
		} else if addr >= 0x4016 && addr <= 0x4017 {
			data = (controller_state[addr & 0x0001] & 0x80) >> 7
			controller_state[addr & 0x0001] <<= 1
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
			if dma_transfer {
				if dma_dummy {
					if systemClockCounter % 2 == 1 {
						dma_dummy = false
					}
				} else {
					if systemClockCounter % 2 == 0 {
						dma_data = cpuRead(addr: (dma_page << 8) | dma_addr)
					} else {
						ppu.OAM[dma_addr] = dma_data
						dma_addr += 1
						
						if dma_addr > 255 {
							dma_transfer = false
							dma_dummy = true
						}
					}
				}
			} else {
				cpu.clock()
			}
		}

		if ppu.nmi {
			ppu.nmi = false
			cpu.nmi()
		}

		systemClockCounter += 1
	}
}
