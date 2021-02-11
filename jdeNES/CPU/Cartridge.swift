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
	
	var prgMemory: [Int]!
	var chrMemory: [Int]!
	var mapperID = 0
	var prgBanks = 0
	var chrBanks = 0
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
		let url = URL(fileURLWithPath: filename)
		print(url)
		let data: Data
		do {
				data = try Data(contentsOf: url)
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

		mapperID = ((mapper2 >> 4) << 4) | (mapper1 >> 4)
		mirror = (mapper1 & 0x01) > 0 ? .vertical : .horizontal

		let fileType = 1	// assume filetype 1 for now

		switch (fileType) {
		case 0:
			break
		case 1:
			prgBanks = prgRomChunks
			prgMemory = Array(data[offset ..< offset + 16384 * prgRomChunks]).map {Int($0)}
			offset += 16384 * prgRomChunks
			chrBanks = chrRomChunks
			chrMemory = Array(data[offset ..< offset + 8192 * chrRomChunks]).map {Int($0)}
		case 2:
			break
		default:
			break
		}

		return true
	}

	func cpuRead(addr: Int) -> Int? {
		if let mapped_addr = mapper.cpuMapRead(addr: addr) {
			return prgMemory[mapped_addr]
		}
		return nil
	}

	func cpuWrite(addr: Int, data: Int) -> Int? {
		if let mapped_addr = mapper.cpuMapWrite(addr: addr) {
			prgMemory[mapped_addr] = data
			return data
		}
		return nil
	}
	
	func ppuRead(addr: Int) -> Int? {
		if let mapped_addr = mapper.ppuMapRead(addr: addr) {
			return chrMemory[mapped_addr]
		}
		return nil
	}
	
	func ppuWrite(addr: Int, data: Int) -> Int? {
		if let mapped_addr = mapper.ppuMapWrite(addr: addr) {
			chrMemory[mapped_addr] = data
			return data
		}
		return nil
	}
}
