//
//  Mapper.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Mapper {
	let prgBanks: Int
	let chrBanks: Int

	init(prgBanks: Int, chrBanks: Int) {
		self.prgBanks = prgBanks
		self.chrBanks = chrBanks
	}

	func cpuMapRead(addr: Int) -> Int? {
		return nil
	}
	
	func cpuMapWrite(addr: Int) -> Int? {
		return nil
	}
	
	func ppuMapRead(addr: Int) -> Int? {
		return nil
	}
	
	func ppuMapWrite(addr: Int) -> Int? {
		return nil
	}
}
