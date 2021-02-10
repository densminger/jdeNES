//
//  GameEngine.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

import SpriteKit

class GameEngine: SKScene {
	static let width = 780
	static let height = 480
	static let screenSize = CGSize(width: GameEngine.width, height: GameEngine.height)

	private let node: SKSpriteNode
	private let screenFrame: Sprite

	init(file: String) {
		let screenSize = CGSize(width: GameEngine.width, height: GameEngine.height)
		node = SKSpriteNode()
		node.anchorPoint = CGPoint(x: 0, y: 0)
		node.size = screenSize
		
		screenFrame = Sprite(width: GameEngine.width, height: GameEngine.height)

		super.init(size: screenSize)

		scaleMode = .aspectFit

		addChild(node)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func update(_ currentTime: TimeInterval) {
		// just for testing
		//populateFrame()

		// display the frame
		let p = Data(bytesNoCopy: screenFrame.pixels.baseAddress!, count: screenFrame.pixelCount, deallocator: .none)
		let texture = SKTexture(data: p, size: CGSize(width: screenFrame.width, height: screenFrame.height), flipped: true)
		texture.filteringMode = .nearest

		node.texture = texture
	}
	
	var i = 0
	private func populateFrame() {
		i += 1
		let color: UInt32
		switch (i % 3) {
		case 0:
			color = 0xFF0000FF
		case 1:
			color = 0xFF00FF00
		case 2:
			color = 0xFFFF0000
		default:
			color = 0xFF000000
		}
		for x in 0 ..< screenFrame.width {
			for y in 0 ..< screenFrame.height {
				screenFrame[x, y] = color
			}
		}
	}

}
