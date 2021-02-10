//
//  Cartridge.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

import Foundation

class Cartridge {
	enum Mirror {
		case horizontal
		case vertical
		case oneScreen_Lo
		case oneScreen_Hi
	}
	
	var prgMemory: [UInt8]!
	var chrMemory: [UInt8]!
	var mapperID: UInt8 = 0
	var prgBanks: UInt8 = 0
	var chrBanks: UInt8 = 0
	var mapper: Mapper!
	var mirror = Mirror.horizontal

	init?(from filename: String) {
		if !populateWithContentsOf(filename) {
			return nil
		}

		switch (mapperID) {
		case 0:
			mapper = Mapper000(prgBanks: prgBanks, chrBanks: chrBanks)
		default:
			// ahh! this cart uses a mapper we don't know about
			return nil
		}
	}

	func populateWithContentsOf(_ filename: String) -> Bool {
		let data: Data
		do {
			data = try Data(contentsOf: URL(fileURLWithPath: filename))
		} catch {
			print(error)
			return false
		}

		let name1 = Int(data[0]) << 24
		let name2 = Int(data[1]) << 16
		let name3 = Int(data[2]) << 8
		let name4 = Int(data[3])
		let name = name1 + name2 + name3 + name4
		let prgRomChunks = Int(data[4])
		let chrRomChunks = Int(data[5])
		let mapper1 = Int(data[6])
		let mapper2 = Int(data[7])
		//let prgRamSize = Int(data[8])
		//let tvSystem1 = Int(data[9])
		//let tvSystem2 = Int(data[10])
		
		if name != 0x4E45531A {
			return false
		}

		var offset = 16
		if mapper1 & 0x04 > 0 {
			offset += 512
		}

		mapperID = UInt8(((mapper2 >> 4) << 4) | (mapper1 >> 4))
		mirror = (mapper1 & 0x01) > 0 ? .vertical : .horizontal

		let fileType = 1	// assume filetype 1 for now

		switch (fileType) {
		case 0:
			break
		case 1:
			prgBanks = UInt8(prgRomChunks)
			//self.prgMemory = list(f.read(self.prgBanks * 16384))
			prgMemory = Array(data[offset ..< offset + 16384 * prgRomChunks])
			offset += 16384 * prgRomChunks
			chrBanks = UInt8(chrRomChunks)
			chrMemory = Array(data[offset ..< offset + 8192 * chrRomChunks])
		case 2:
			break
		default:
			break
		}

		return true
	}

	func cpuRead(addr: UInt16) -> UInt8? {
		if let mapped_addr = mapper.cpuMapRead(addr: addr) {
			return prgMemory[Int(mapped_addr)]
		}
		return nil
	}

	func cpuWrite(addr: UInt16, data: UInt8) -> UInt8? {
		if let mapped_addr = mapper.cpuMapWrite(addr: addr) {
			prgMemory[Int(mapped_addr)] = data
			return data
		}
		return nil
	}
	
	func ppuRead(addr: UInt16) -> UInt8? {
		if let mapped_addr = mapper.ppuMapRead(addr: addr) {
			return chrMemory[Int(mapped_addr)]
		}
		return nil
	}
	
	func ppuWrite(addr: UInt16, data: UInt8) -> UInt8? {
		if let mapped_addr = mapper.ppuMapWrite(addr: addr) {
			chrMemory[Int(mapped_addr)] = data
			return data
		}
		return nil
	}
}
