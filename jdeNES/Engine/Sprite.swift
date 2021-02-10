//
//  Frame.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Sprite {
	let pixelCount: Int
	let pointer: UnsafeMutablePointer<UInt32>
	private(set) var pixels: UnsafeMutableBufferPointer<UInt32>
	let width: Int
	let height: Int

	init(width: Int, height: Int) {
		self.width = width
		self.height = height
		pixelCount = Int(width * height)
		pointer = .allocate(capacity: pixelCount)
		pointer.initialize(repeating: 0, count: pixelCount)
		pixels = UnsafeMutableBufferPointer(start: pointer, count: pixelCount)
	}

	func deallocate() {
		pointer.deallocate()
	}
	
	private func calculateOffset(_ x: Int, _ y: Int) -> Int {
		x + y * Int(GameEngine.screenSize.width)
	}
	
	subscript(x: Int, y: Int) -> UInt32 {
		get {
			precondition(x < width)
			precondition(y < height)

			let offset = calculateOffset(x, y)

			return pixels[offset]
		}
		set(pixel) {
			precondition(x < width)
			precondition(y < height)

			let offset = calculateOffset(x, y)

			pixels[offset] = pixel
		}
	}
}
