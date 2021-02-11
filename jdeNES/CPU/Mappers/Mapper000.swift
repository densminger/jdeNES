//
//  Mapper000.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Mapper000: Mapper {
	override func cpuMapRead(addr: Int) -> Int? {
		if addr >= 0x8000 && addr <= 0xFFFF {
			return addr & (prgBanks > 1 ? 0x7FFF : 0x3FFF)
		}
		return nil
	}

	override func cpuMapWrite(addr: Int) -> Int? {
		if addr >= 0x8000 && addr <= 0xFFFF {
			return addr & (prgBanks > 1 ? 0x7FFF : 0x3FFF)
		}
		return nil
	}

	override func ppuMapRead(addr: Int) -> Int? {
		if addr >= 0x0000 && addr <= 0x1FFF {
			return addr
		}
		return nil
	}

	override func ppuMapWrite(addr: Int) -> Int? {
		if addr >= 0x0000 && addr <= 0x1FFF {
			if chrBanks == 0 {
				return addr
			}
		}
		return nil
	}
}
