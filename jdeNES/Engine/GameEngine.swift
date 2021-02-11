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
	private let screenNode: SKSpriteNode
	private let screenFrame: Sprite
	
	var nes: Bus!
	var mapAsm: [Int:String]?
	var keys:  [Dictionary<Int, String>.Keys.Element]?
	var completedFrame = false
	var emulationRun = false
	var keyPressed: UInt16?
	var residualTime: TimeInterval = 0.0
	var selectedPalette = 0

	init(file: String) {
		let screenSize = CGSize(width: GameEngine.width, height: GameEngine.height)
		node = SKSpriteNode()
		node.anchorPoint = CGPoint(x: 0, y: 0)
		node.size = screenSize
		
		screenFrame = Sprite(width: GameEngine.width, height: GameEngine.height)

		screenNode = SKSpriteNode()
		screenNode.anchorPoint = CGPoint(x: 0, y: 0)
		screenNode.size = CGSize(width: 512, height: 480)

		super.init(size: screenSize)

		scaleMode = .aspectFit

		addChild(node)
		node.addChild(screenNode)

		if let cart = Cartridge(from: file) {
			nes = Bus()
			nes.insertCartridge(cart)
			let a = nes.cpu
			
			a.reset()
			mapAsm = a.disassemble(start: 0x0000, stop: 0xFFFF)
			keys = Array(mapAsm!.keys).sorted()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func keyDown(with event: NSEvent) {
		keyPressed = event.keyCode
//		print("\(keyPressed!) down")
		switch (event.keyCode) {
		case 126:	// up
			nes.controller[0] |= 0x08
		case 125:	// down
			nes.controller[0] |= 0x04
		case 123:	// left
			nes.controller[0] |= 0x02
		case 124:	// right
			nes.controller[0] |= 0x01
		case 6:		// z
			nes.controller[0] |= 0x40	// B button
		case 7:		// x
			nes.controller[0] |= 0x80	// A button
		case 36:	// enter
			nes.controller[0] |= 0x10	// Start button
		case 48:	// tab
			nes.controller[0] |= 0x20	// Select button
		default:
			break
		}
	}
	
	override func keyUp(with event: NSEvent) {
		keyPressed = nil
		switch (event.keyCode) {
		case 126:	// up
			nes.controller[0] &= 0xF7
		case 125:	// down
			nes.controller[0] &= 0xFB
		case 123:	// left
			nes.controller[0] &= 0xFD
		case 124:	// right
			nes.controller[0] &= 0xFE
		case 6:		// z
			nes.controller[0] &= 0xBF	// B button
		case 7:		// x
			nes.controller[0] &= 0x7F	// A button
		case 36:	// enter
			nes.controller[0] &= 0xEF	// Start button
		case 48:	// tab
			nes.controller[0] &= 0xDF	// Select button
		default:
			break
		}
	}

	override func update(_ currentTime: TimeInterval) {
		node.removeAllChildren()
		// q 12
		// c 8
		// space 49
		// f 3
		completedFrame = false
		if emulationRun {
			if residualTime > 0.0 {
				residualTime -= currentTime
			} else {
				residualTime += (1.0/60.0) - currentTime
				repeat {
					nes.clock()
//					if nes.cpu.pc == 0x90E3 {
//						emulationRun = false
//						break
//					}
				} while !nes.ppu.frame_complete
				nes.ppu.frame_complete = false
				completedFrame = true
			}
		} else {
			if keyPressed == 8 {	// C
				repeat {
					nes.clock()
				} while nes.cpu.cycles > 0
				repeat {
					nes.clock()
				} while nes.cpu.cycles == 0
			} else if keyPressed == 3 {	// f
				repeat {
					nes.clock()
				} while !nes.ppu.frame_complete
				repeat {
					nes.clock()
				} while nes.cpu.cycles == 0
				nes.ppu.frame_complete = false
			}
		}
		if keyPressed == 15 {	// r
			nes.reset()
		} else if keyPressed == 49 {	// space
			emulationRun = !emulationRun
		} else if keyPressed == 35 {	// p
			selectedPalette = (selectedPalette + 1) & 0x07
		} else if keyPressed == 44 {	// "/"
		}
		
		
		drawPPUScreen()
//		drawCPU(x: 516, y: 2)
//		drawCode(x: 516, y: 72, lines: 26)
//		drawOAM(x: 516, y: 72, entries: 32)
//		drawPatternTable(i: 0, x: 516, y: 0)
//		drawPatternTable(i: 1, x: 648, y: 0)

		keyPressed = nil
	}
	
	func drawPPUScreen() {
		let f = nes.ppu.GetScreen()
		let p = Data(bytesNoCopy: f.pixels.baseAddress!, count: f.pixelCount, deallocator: .none)
		let texture = SKTexture(data: p, size: CGSize(width: f.width, height: f.height), flipped: true)
		texture.filteringMode = .nearest
		screenNode.texture = texture
		node.addChild(screenNode)
	}
	
	func drawPatternTable(i: Int, x: Int, y: Int) {
		let f = nes.ppu.GetPatternTable(i, palette: selectedPalette)
		let pattern = SKSpriteNode()
		pattern.anchorPoint = CGPoint(x: 0, y: 0)
		pattern.position = CGPoint(x: x, y: y)
		pattern.size = CGSize(width: f.width, height: f.height)
		let p = Data(bytesNoCopy: f.pixels.baseAddress!, count: f.pixelCount, deallocator: .none)
		let texture = SKTexture(data: p, size: CGSize(width: f.width, height: f.height), flipped: true)
		texture.filteringMode = .nearest
		pattern.texture = texture
		node.addChild(pattern)
	}
	
	func drawOAM(x: Int, y: Int, entries: Int) {
		for i in 0 ..< entries {
			let s = "\(hex(i, 2)): (\(nes.ppu.OAM[i * 4 + 3]), \(nes.ppu.OAM[i * 4 + 0])) ID: \(hex(nes.ppu.OAM[i * 4 + 1], 2)) AT: \(hex(nes.ppu.OAM[i * 4 + 2], 2))"
			node.drawString(x: x, y: y + i * 10, text: s)
		}
	}
	
	let COLOR_WHITE = 0xFFFFFFFF
	let COLOR_GREEN = 0xFF00FF00
	let COLOR_RED   = 0xFF0000FF
	let COLOR_CYAN  = 0xFFFFFF00
	
	let hex: (Int, Int) -> String = { (n, x) in
		if x == 2 {
			return String(format: "%02X", n)
		} else if x == 4 {
			return String(format: "%04X", n)
		}
		return ""
	}

	func drawCPU(x: Int, y: Int) {
		node.drawString(x: x , y: y , text: "STATUS:", color: self.COLOR_WHITE)
		node.drawString(x: x  + 64, y: y, text: "N", color: nes.cpu.status[nes.cpu.N] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 80, y: y , text: "V", color: nes.cpu.status[nes.cpu.V] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 96, y: y , text: "-", color: nes.cpu.status[nes.cpu.U] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 112, y: y , text: "B", color: nes.cpu.status[nes.cpu.B] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 128, y: y , text: "D", color: nes.cpu.status[nes.cpu.D] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 144, y: y , text: "I", color: nes.cpu.status[nes.cpu.I] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 160, y: y , text: "Z", color: nes.cpu.status[nes.cpu.Z] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 178, y: y , text: "C", color: nes.cpu.status[nes.cpu.C] > 0 ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x , y: y + 10, text: "PC: $" + hex(nes.cpu.pc, 4))
		node.drawString(x: x , y: y + 20, text: "A: $" +  hex(nes.cpu.a, 2) + "  [" + String(nes.cpu.a) + "]");
		node.drawString(x: x , y: y + 30, text: "X: $" +  hex(nes.cpu.x, 2) + "  [" + String(nes.cpu.x) + "]");
		node.drawString(x: x , y: y + 40, text: "Y: $" +  hex(nes.cpu.y, 2) + "  [" + String(nes.cpu.y) + "]");
		node.drawString(x: x , y: y + 50, text: "Stack P: $" + hex(nes.cpu.stkp, 4));
	}

	func drawCode(x: Int, y: Int, lines: Int) {
		guard let mapAsm = mapAsm, let keys = keys else {
			return
		}
//		node.drawString(x: x, y: y, text: mapAsm[nes.cpu.pc] ?? "???")
		if let pc_i = keys.firstIndex(of: nes.cpu.pc) {
			for i in pc_i ..< pc_i + lines {
				let s = mapAsm[keys[(pc_i+(i-pc_i-lines/2))]]!
				node.drawString(x: x, y: (i-pc_i)*10 + y, text: s, color: ((i-pc_i)==lines/2) ? COLOR_CYAN : COLOR_WHITE)
			}
		}
	}

	private func populateFrame(_ f: Sprite) {
		let color: UInt32 = 0xFF00FF00
		for x in 100 ..< 200 {
			for y in 100 ..< 200 {
				f[x, y] = color
			}
		}
//		var x = 0.0
//		var y = 0.0
//
//		while y < Double(f.height) && x < Double(f.width) {
//			f[Int(x), Int(y)] = 0xFF00FF00
//			x += Double(f.width)/Double(f.height)
//			y += Double(f.height)/Double(f.width)
//		}
	}

}

extension SKSpriteNode {
	func drawString(x: Int, y: Int, text: String, color: Int = 0xFFFFFFFF, fontName: String = "Press Start K", fontSize: CGFloat = 8) {
		let textNode = SKLabelNode(text: text)
		textNode.fontName = fontName
		textNode.fontSize = fontSize
		textNode.fontColor = NSColor(red: CGFloat((color & 0x000000FF))/255.0, green: CGFloat((color & 0x0000FF00) >> 8)/255.0, blue: CGFloat((color & 0x00FF0000) >> 16)/255.0, alpha: CGFloat((color & 0xFF000000) >> 24)/255.0)
		textNode.horizontalAlignmentMode = .left
		textNode.position = CGPoint(x: x, y: (Int(size.height) - y - Int(fontSize)))
		addChild(textNode)
	}
}
