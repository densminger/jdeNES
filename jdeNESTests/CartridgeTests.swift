//
//  Cartridge.swift
//  jdeNESTests
//
//  Created by David Ensminger on 2/10/21.
//

import XCTest
@testable import jdeNES

class CartridgeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testNesCart() {
		if let cart = Cartridge(from: "/Users/david/Projects/pyNES/smb.nes") {
			XCTAssert(cart.prgMemory.count == 32768)
			XCTAssert(cart.chrMemory.count == 8192)
			XCTAssert(cart.mapperID == 0)
			XCTAssert(cart.mirror == .vertical)
			XCTAssert(cart.prgMemory[234] == 0x20)
			XCTAssert(cart.chrMemory[234] == 0xF0)
		} else {
			XCTFail()
		}
	}
	

}
