//
//  Mapper.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Mapper {
	let prgBanks: UInt8
	let chrBanks: UInt8

	init(prgBanks: UInt8, chrBanks: UInt8) {
		self.prgBanks = prgBanks
		self.chrBanks = chrBanks
	}

	func cpuMapRead(addr: UInt16) -> UInt16? {
		return nil
	}
	
	func cpuMapWrite(addr: UInt16) -> UInt16? {
		return nil
	}
	
	func ppuMapRead(addr: UInt16) -> UInt16? {
		return nil
	}
	
	func ppuMapWrite(addr: UInt16) -> UInt16? {
		return nil
	}
}
