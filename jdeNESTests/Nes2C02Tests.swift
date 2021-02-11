//
//  Nes2C02.swift
//  jdeNESTests
//
//  Created by David Ensminger on 2/10/21.
//

import XCTest
@testable import jdeNES

class Nes2C02Tests: XCTestCase {

	var sut: Nes2C02!
	override func setUpWithError() throws {
		sut = Nes2C02()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testStatus_get() {
		sut.status = 0b1000_0000
		XCTAssert(sut.status[sut.verticalBlank] == 1)
		XCTAssert(sut.status[sut.spriteZero] == 0)
		XCTAssert(sut.status[sut.spriteOverflow] == 0)
		XCTAssert(sut.status == 0b1000_0000)

		sut.status = 0b0100_0000
		XCTAssert(sut.status[sut.verticalBlank] == 0)
		XCTAssert(sut.status[sut.spriteZero] == 1)
		XCTAssert(sut.status[sut.spriteOverflow] == 0)
		XCTAssert(sut.status == 0b0100_0000)

		sut.status = 0b0010_0000
		XCTAssert(sut.status[sut.verticalBlank] == 0)
		XCTAssert(sut.status[sut.spriteZero] == 0)
		XCTAssert(sut.status[sut.spriteOverflow] == 1)
		XCTAssert(sut.status == 0b0010_0000)
	}
	
	func testStauts_set() {
		sut.status = 0
		sut.status[sut.verticalBlank] = 1
		XCTAssert(sut.status == 0b1000_0000)

		sut.status = 0
		sut.status[sut.spriteZero] = 1
		XCTAssert(sut.status == 0b0100_0000)

		sut.status = 0
		sut.status[sut.spriteOverflow] = 1
		XCTAssert(sut.status == 0b0010_0000)
	}
	
	func testMask_get() {
		sut.mask = 0b1000_0000
		XCTAssert(sut.mask[sut.enhanceBlue] == 1)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0100_0000
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 1)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0010_0000
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 1)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0001_0000
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 1)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0000_1000
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 1)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0000_0100
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 1)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0000_0010
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 1)
		XCTAssert(sut.mask[sut.grayscale] == 0)

		sut.mask = 0b0000_0001
		XCTAssert(sut.mask[sut.enhanceBlue] == 0)
		XCTAssert(sut.mask[sut.enhanceGreen] == 0)
		XCTAssert(sut.mask[sut.enhanceRed] == 0)
		XCTAssert(sut.mask[sut.renderSprite] == 0)
		XCTAssert(sut.mask[sut.renderBackground] == 0)
		XCTAssert(sut.mask[sut.renderSpriteLeft] == 0)
		XCTAssert(sut.mask[sut.renderBackgroundLeft] == 0)
		XCTAssert(sut.mask[sut.grayscale] == 1)
	}
	
	func testMask_set() {
		sut.mask = 0
		sut.mask[sut.enhanceBlue] = 1
		XCTAssert(sut.mask == 0b1000_0000)

		sut.mask = 0
		sut.mask[sut.enhanceGreen] = 1
		XCTAssert(sut.mask == 0b0100_0000)

		sut.mask = 0
		sut.mask[sut.enhanceRed] = 1
		XCTAssert(sut.mask == 0b0010_0000)

		sut.mask = 0
		sut.mask[sut.renderSprite] = 1
		XCTAssert(sut.mask == 0b0001_0000)

		sut.mask = 0
		sut.mask[sut.renderBackground] = 1
		XCTAssert(sut.mask == 0b0000_1000)

		sut.mask = 0
		sut.mask[sut.renderSpriteLeft] = 1
		XCTAssert(sut.mask == 0b0000_0100)

		sut.mask = 0
		sut.mask[sut.renderBackgroundLeft] = 1
		XCTAssert(sut.mask == 0b0000_0010)

		sut.mask = 0
		sut.mask[sut.grayscale] = 1
		XCTAssert(sut.mask == 0b0000_0001)
	}
	
	func testControl_get() {
		sut.control = 0b1000_0000
		XCTAssert(sut.control[sut.enableNMI] == 1)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0100_0000
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 1)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0010_0000
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 1)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0001_0000
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 1)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0000_1000
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 1)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0000_0100
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 1)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0000_0010
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 1)
		XCTAssert(sut.control[sut.nameTableX] == 0)

		sut.control = 0b0000_0001
		XCTAssert(sut.control[sut.enableNMI] == 0)
		XCTAssert(sut.control[sut.slaveMode] == 0)
		XCTAssert(sut.control[sut.spriteSize] == 0)
		XCTAssert(sut.control[sut.patternBackground] == 0)
		XCTAssert(sut.control[sut.patternSprite] == 0)
		XCTAssert(sut.control[sut.incrementMode] == 0)
		XCTAssert(sut.control[sut.nameTableY] == 0)
		XCTAssert(sut.control[sut.nameTableX] == 1)
	}
	
	func testControl_set() {
		sut.control = 0
		sut.control[sut.enableNMI] = 1
		XCTAssert(sut.control == 0b1000_0000)
		
		sut.control = 0
		sut.control[sut.slaveMode] = 1
		XCTAssert(sut.control == 0b0100_0000)
		
		sut.control = 0
		sut.control[sut.spriteSize] = 1
		XCTAssert(sut.control == 0b0010_0000)
		
		sut.control = 0
		sut.control[sut.patternBackground] = 1
		XCTAssert(sut.control == 0b0001_0000)
		
		sut.control = 0
		sut.control[sut.patternSprite] = 1
		XCTAssert(sut.control == 0b0000_1000)
		
		sut.control = 0
		sut.control[sut.incrementMode] = 1
		XCTAssert(sut.control == 0b0000_0100)
		
		sut.control = 0
		sut.control[sut.nameTableY] = 1
		XCTAssert(sut.control == 0b0000_0010)
		
		sut.control = 0
		sut.control[sut.nameTableX] = 1
		XCTAssert(sut.control == 0b0000_0001)
	}
	
	func testLoopy_get() {
		sut.vram_addr = 0b0000_0000_0001_0101
		XCTAssert(sut.vram_addr[sut.loopyCoarseX]    == 0b10101)
		XCTAssert(sut.vram_addr[sut.loopyCoarseY]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableX] == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableY] == 0)
		XCTAssert(sut.vram_addr[sut.loopyFineY]      == 0)

		sut.vram_addr = 0b0000_0010_1010_0000
		XCTAssert(sut.vram_addr[sut.loopyCoarseX]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyCoarseY]    == 0b10101)
		XCTAssert(sut.vram_addr[sut.loopyNameTableX] == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableY] == 0)
		XCTAssert(sut.vram_addr[sut.loopyFineY]      == 0)

		sut.vram_addr = 0b0000_0100_0000_0000
		XCTAssert(sut.vram_addr[sut.loopyCoarseX]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyCoarseY]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableX] == 1)
		XCTAssert(sut.vram_addr[sut.loopyNameTableY] == 0)
		XCTAssert(sut.vram_addr[sut.loopyFineY]      == 0)

		sut.vram_addr = 0b0000_1000_0000_0000
		XCTAssert(sut.vram_addr[sut.loopyCoarseX]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyCoarseY]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableX] == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableY] == 1)
		XCTAssert(sut.vram_addr[sut.loopyFineY]      == 0)

		sut.vram_addr = 0b0101_0000_0000_0000
		XCTAssert(sut.vram_addr[sut.loopyCoarseX]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyCoarseY]    == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableX] == 0)
		XCTAssert(sut.vram_addr[sut.loopyNameTableY] == 0)
		XCTAssert(sut.vram_addr[sut.loopyFineY]      == 0b101)

	}
	
	func testLoopy_set() {
		sut.vram_addr = 0b1100_0011_1100_0011
		sut.vram_addr[sut.loopyCoarseX] = 0b10101
		XCTAssert(sut.vram_addr == 0b1100_0011_1101_0101)

		sut.vram_addr = 0b1100_0011_1100_0011
		sut.vram_addr[sut.loopyCoarseY] = 0b10101
		XCTAssert(sut.vram_addr == 0b1100_0010_1010_0011)

		sut.vram_addr = 0b1100_0011_1100_0011
		sut.vram_addr[sut.loopyNameTableX] = 1
		XCTAssert(sut.vram_addr == 0b1100_0111_1100_0011)

		sut.vram_addr = 0b1100_0011_1100_0011
		sut.vram_addr[sut.loopyNameTableY] = 1
		XCTAssert(sut.vram_addr == 0b1100_1011_1100_0011)

		sut.vram_addr = 0b1100_0011_1100_0011
		sut.vram_addr[sut.loopyFineY] = 0b000
		XCTAssert(sut.vram_addr == 0b1000_0011_1100_0011)
	}

}
