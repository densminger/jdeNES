//
//  Nes2C02.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Nes2C02 {
	// Status
	let spriteOverflow       = 0b0010_0000
	let spriteZero           = 0b0100_0000
	let verticalBlank        = 0b1000_0000

	// Mask
	let grayscale            = 0b0000_0001
	let renderBackgroundLeft = 0b0000_0010
	let renderSpriteLeft     = 0b0000_0100
	let renderBackground     = 0b0000_1000
	let renderSprite         = 0b0001_0000
	let enhanceRed           = 0b0010_0000
	let enhanceGreen         = 0b0100_0000
	let enhanceBlue          = 0b1000_0000

	// Control
	let nameTableX           = 0b0000_0001
	let nameTableY           = 0b0000_0010
	let incrementMode        = 0b0000_0100
	let patternSprite        = 0b0000_1000
	let patternBackground    = 0b0001_0000
	let spriteSize           = 0b0010_0000
	let slaveMode            = 0b0100_0000
	let enableNMI            = 0b1000_0000

	// loopy
	let loopyCoarseX    = 0b0000_0000_0001_1111
	let loopyCoarseY    = 0b0000_0011_1110_0000
	let loopyNameTableX = 0b0000_0100_0000_0000
	let loopyNameTableY = 0b0000_1000_0000_0000
	let loopyFineY      = 0b0111_0000_0000_0000

	// Registers
	var status    = 0x00
	var mask      = 0x00
	var control   = 0x00
	var vram_addr = 0x0000
	var tram_addr = 0x0000
	
	// OAM
//	var oamY         = 0xFF000000
//	var oamID        = 0x00FF0000
//	var oamAttribute = 0x0000FF00
//	var oamX         = 0x000000FF
	var OAM = Array(repeating: 0, count: 64*4)
	private var spriteScanline = Array(repeating: 0, count: 8*4)
	private var sprite_count = 0
	private var sprite_shifter_pattern_lo = Array(repeating: 0, count: 8)
	private var sprite_shifter_pattern_hi = Array(repeating: 0, count: 8)

	var address_latch = false
	var ppu_data_buffer = 0x00
	var ppu_address = 0x0000
	var fine_x = 0x00
	var oam_addr = 0
	
	var nmi = false
	
	var cart: Cartridge!
	
	// tblName dimensions = [2][1024]
	var tblName = Array(repeating: Array(repeating: 0, count: 1024), count: 2)
	
	// tblPalette dimensions = [32]
	var tblPalette = Array(repeating: 0, count: 32)
	
	// tblPattern dimensions = [2][4096]
	var tblPattern = Array(repeating: Array(repeating: 0, count: 4096), count: 2)
	
	var bg_next_tile_id = 0x00
	var bg_next_tile_attrib = 0x00
	var bg_next_tile_lsb = 0x00
	var bg_next_tile_msb = 0x00
	
	var bg_shifter_pattern_lo = 0x0000
	var bg_shifter_pattern_hi = 0x0000
	var bg_shifter_attrib_lo = 0x0000
	var bg_shifter_attrib_hi = 0x0000
	
	private static func rgbToInt(_ r: Int, _ g: Int, _ b: Int) -> UInt32 {
		return UInt32(0xFF000000 | (b << 16) | (g << 8) | r)
	}
	
	var palScreen = [
		rgbToInt(84, 84, 84),       rgbToInt(0, 30, 116),       rgbToInt(8, 16, 144),       rgbToInt(48, 0, 136),       rgbToInt(68, 0, 100),       rgbToInt(92, 0, 48),        rgbToInt(84, 4, 0),         rgbToInt(60, 24, 0),        rgbToInt(32, 42, 0),        rgbToInt(8, 58, 0),         rgbToInt(0, 64, 0),         rgbToInt(0, 60, 0),         rgbToInt(0, 50, 60),        rgbToInt(0, 0, 0),          rgbToInt(0, 0, 0), rgbToInt(0, 0, 0),
		rgbToInt(152, 150, 152),    rgbToInt(8, 76, 196),       rgbToInt(48, 50, 236),      rgbToInt(92, 30, 228),      rgbToInt(136, 20, 176),     rgbToInt(160, 20, 100),     rgbToInt(152, 34, 32),      rgbToInt(120, 60, 0),       rgbToInt(84, 90, 0),        rgbToInt(40, 114, 0),       rgbToInt(8, 124, 0),        rgbToInt(0, 118, 40),       rgbToInt(0, 102, 120),      rgbToInt(0, 0, 0),          rgbToInt(0, 0, 0), rgbToInt(0, 0, 0),
		rgbToInt(236, 238, 236),    rgbToInt(76, 154, 236),     rgbToInt(120, 124, 236),    rgbToInt(176, 98, 236),     rgbToInt(228, 84, 236),     rgbToInt(236, 88, 180),     rgbToInt(236, 106, 100),    rgbToInt(212, 136, 32),     rgbToInt(160, 170, 0),      rgbToInt(116, 196, 0),      rgbToInt(76, 208, 32),      rgbToInt(56, 204, 108),     rgbToInt(56, 180, 204),     rgbToInt(60, 60, 60),       rgbToInt(0, 0, 0), rgbToInt(0, 0, 0),
		rgbToInt(236, 238, 236),    rgbToInt(168, 204, 236),    rgbToInt(188, 188, 236),    rgbToInt(212, 178, 236),    rgbToInt(236, 174, 236),    rgbToInt(236, 174, 212),    rgbToInt(236, 180, 176),    rgbToInt(228, 196, 144),    rgbToInt(204, 210, 120),    rgbToInt(180, 222, 120),    rgbToInt(168, 226, 144),    rgbToInt(152, 226, 180),    rgbToInt(160, 214, 228),    rgbToInt(160, 162, 160),    rgbToInt(0, 0, 0), rgbToInt(0, 0, 0)
	]
	
	var sprScreen = Sprite(width: 256, height: 240)
	var sprNameTable = Array(repeating: Sprite(width: 256, height: 240), count: 2)
	var sprPatternTable = Array(repeating: Sprite(width: 128, height: 128), count: 2)
	
	var frame_complete = false
	
	var scanline = 0
	var cycle = 0

	func GetScreen() -> Sprite {
		return sprScreen
	}
	
	func GetNameTable(_ i: Int) -> Sprite {
		return sprNameTable[i]
	}
	
	func GetPatternTable(_ i: Int, palette: Int) -> Sprite {
		for tileY in 0 ..< 16 {
			for tileX in 0 ..< 16 {
				let offset = tileY * 256 + tileX * 16
				for row in 0 ..< 8 {
					var tile_lsb = ppuRead(addr: i * 0x1000 + offset + row)
					var tile_msb = ppuRead(addr: i * 0x1000 + offset + row + 8)
					for col in 0 ..< 8 {
						let pixel = ((tile_msb & 0x01) << 1) | (tile_lsb & 0x01)
						tile_lsb >>= 1
						tile_msb >>= 1
//						let xx = tileX * 8 + (7 - col)
//						let yy = tileY * 8 + row
//						if xx < 0 || xx > 127 || yy < 0 || yy > 127 {
//							print("oh no! [\(xx), \(yy)]")
//						}
//						print("[x,y] = [\(tileX * 8 + (7 - col)), \(tileY * 8 + row)] (tileX = \(tileX), tileY = \(tileY), col = \(col), row = \(row)")
						sprPatternTable[i][tileX * 8 + (7 - col), tileY * 8 + row] = GetColorFromPaletteRam(palette: palette, pixel: pixel)
					}
				}
			}
		}
		return sprPatternTable[i]
	}

	func GetColorFromPaletteRam(palette: Int, pixel: Int) -> UInt32 {
		return palScreen[ppuRead(addr: 0x3F00 + (palette << 2) + pixel) & 0x3F]
	}

	func cpuWrite(addr: Int, data: Int) {
		switch addr {
		case 0x0000:		// control
			control = data
			tram_addr[loopyNameTableX] = control[nameTableX]
			tram_addr[loopyNameTableY] = control[nameTableY]
		case 0x0001:		// mask
			mask = data
		case 0x0002:		// status
			break
		case 0x0003:		// oam address
			oam_addr = data
		case 0x0004:		// oam data
			OAM[oam_addr] = data
			break
		case 0x0005:		// scroll
			if address_latch {
				tram_addr[loopyFineY] = data & 0x07
				tram_addr[loopyCoarseY] = data >> 3
				address_latch = false
			} else {
				fine_x = data & 0x07
				tram_addr[loopyCoarseX] = data >> 3
				address_latch = true
			}
		case 0x0006:		// ppu address
			if address_latch {
				tram_addr = (tram_addr & 0xFF00) | data
				vram_addr = tram_addr
				address_latch = false
			} else {
				tram_addr = (tram_addr & 0x00FF) | (data << 8)
				address_latch = true
			}
		case 0x0007:		// ppu data
			ppuWrite(addr: vram_addr, data: data)
			vram_addr += control[incrementMode] > 0 ? 32 : 1
		default:
			break
		}
	}

	func cpuRead(addr: Int, readonly: Bool = false) -> Int {
		var data = 0x00

		if readonly {
			switch addr {
			case 0x0000:			// control
				data = control
			case 0x0001:			// mask
				data = mask
			case 0x0002:			// status
				data = status
			case 0x0003:			// oam address
				break
			case 0x0004:    		// oam data
				break
			case 0x0005:			// scroll
				break
			case 0x0006:			// ppu address
				break
			case 0x0007:			// ppu data
				break
			default:
				break
			}
		}
		else {
			switch addr {
			case 0x0000:			// control
				break
			case 0x0001:			// mask
				break
			case 0x0002:			// status
				data = (status & 0xE0) | (ppu_data_buffer & 0x1F)
				status[verticalBlank] = 0
				address_latch = false
			case 0x0003:			// oam address
				break
			case 0x0004:			// oam data
				data = OAM[oam_addr]
			case 0x0005:			// scroll
				break
			case 0x0006:			// ppu address
				break
			case 0x0007:			// ppu data
				data = ppu_data_buffer
				ppu_data_buffer = ppuRead(addr: vram_addr)

				if vram_addr > 0x3F00 {
					data = ppu_data_buffer
				}

				vram_addr += control[incrementMode] > 0 ? 32 : 1
			default:
				break
			}
		}
		return data
	}
					
	func ppuRead(addr inAddr: Int) -> Int {
		var data = 0x00
		var addr = inAddr & 0x3FFF

		if let cartData = cart.ppuRead(addr: addr) {
			data = cartData
		} else if addr >= 0x0000 && addr <= 0x1FFF {
			data = tblPattern[(addr & 0x1000) >> 12][addr & 0x0FFF]
		} else if addr >= 0x2000 && addr <= 0x3EFF {
			addr &= 0x0FFF
			if cart.mirror == .vertical {
				if addr >= 0x0000 && addr <= 0x03FF {
					data = tblName[0][addr & 0x03FF]
				} else if addr >= 0x0400 && addr <= 0x07FF {
					data = tblName[1][addr & 0x03FF]
				} else if addr >= 0x0800 && addr <= 0x0BFF {
					data = tblName[0][addr & 0x03FF]
				} else if addr >= 0x0C00 && addr <= 0x0FFF {
					data = tblName[1][addr & 0x03FF]
				}
			} else if cart.mirror == .horizontal {
				if addr >= 0x0000 && addr <= 0x03FF {
					data = tblName[0][addr & 0x03FF]
				} else if addr >= 0x0400 && addr <= 0x07FF {
					data = tblName[0][addr & 0x03FF]
				} else if addr >= 0x0800 && addr <= 0x0BFF {
					data = tblName[1][addr & 0x03FF]
				} else if addr >= 0x0C00 && addr <= 0x0FFF {
					data = tblName[1][addr & 0x03FF]
				}
			}
		} else if addr >= 0x3F00 && addr <= 0x3FFF {
			addr &= 0x001F
			if addr == 0x0010 {
				addr = 0x0000
			} else if addr == 0x0014 {
				addr = 0x0004
			} else if addr == 0x0018 {
				addr = 0x0008
			} else if addr == 0x001C {
				addr = 0x000C
			}
			data = tblPalette[addr] & (mask[grayscale] > 0 ? 0x30 : 0x3F)
		}
		return data
	}
	
	func ppuWrite(addr inAddr: Int, data: Int) {
		var addr = inAddr & 0x3FFF

		if let _ = cart.ppuWrite(addr: addr, data: data) {
		} else if addr >= 0x0000 && addr <= 0x1FFF {
			tblPattern[(addr & 0x1000) >> 12][addr & 0x0FFF] = data
		} else if addr >= 0x2000 && addr <= 0x3EFF {
			addr &= 0x0FFF
			if cart.mirror == .vertical {
				if addr >= 0x0000 && addr <= 0x03FF {
					tblName[0][addr & 0x03FF] = data
				} else if addr >= 0x0400 && addr <= 0x07FF {
					tblName[1][addr & 0x03FF] = data
				} else if addr >= 0x0800 && addr <= 0x0BFF {
					tblName[0][addr & 0x03FF] = data
				} else if addr >= 0x0C00 && addr <= 0x0FFF {
					tblName[1][addr & 0x03FF] = data
				}
			} else if cart.mirror == .horizontal {
				if addr >= 0x0000 && addr <= 0x03FF {
					tblName[0][addr & 0x03FF] = data
				} else if addr >= 0x0400 && addr <= 0x07FF {
					tblName[0][addr & 0x03FF] = data
				} else if addr >= 0x0800 && addr <= 0x0BFF {
					tblName[1][addr & 0x03FF] = data
				} else if addr >= 0x0C00 && addr <= 0x0FFF {
					tblName[1][addr & 0x03FF] = data
				}
			}
		} else if addr >= 0x3F00 && addr <= 0x3FFF {
			addr &= 0x001F
			if addr == 0x0010 {
				addr = 0x0000
			} else if addr == 0x0014 {
				addr = 0x0004
			} else if addr == 0x0018 {
				addr = 0x0008
			} else if addr == 0x001C {
				addr = 0x000C
			}
			tblPalette[addr] = data
		}
	}
	
	func ConnectCartridge(_ cart: Cartridge) {
		self.cart = cart
	}
	
	func clock() {
		func IncrementScrollX() {
			if mask[renderBackground] > 0 || mask[renderSprite] > 0 {
				if vram_addr[loopyCoarseX] == 31 {
					vram_addr[loopyCoarseX] = 0
					if vram_addr[loopyNameTableX] > 0 {
						vram_addr[loopyNameTableX] = 0
					} else {
						vram_addr[loopyNameTableX] = 1
					}
				} else {
					vram_addr[loopyCoarseX] += 1
				}
			}
		}

		func IncrementScrollY() {
			if mask[renderBackground] > 0 || mask[renderSprite] > 0 {
				if vram_addr[loopyFineY] < 7 {
					vram_addr[loopyFineY] += 1
				} else {
					vram_addr[loopyFineY] = 0

					if vram_addr[loopyCoarseY] == 29 {
						vram_addr[loopyCoarseY] = 0
						if vram_addr[loopyNameTableY] > 0 {
							vram_addr[loopyNameTableY] = 0
						} else {
							vram_addr[loopyNameTableY] = 1
						}
					} else if vram_addr[loopyCoarseY] == 31 {
						vram_addr[loopyCoarseY] = 0
					} else {
						vram_addr[loopyCoarseY] += 1
					}
				}
			}
		}

		func TransferAddressX() {
			if mask[renderBackground] > 0 || mask[renderSprite] > 0 {
				vram_addr[loopyNameTableX] = tram_addr[loopyNameTableX]
				vram_addr[loopyCoarseX]    = tram_addr[loopyCoarseX]
			}
		}

		func TransferAddressY() {
			if mask[renderBackground] > 0 || mask[renderSprite] > 0 {
				vram_addr[loopyFineY]      = tram_addr[loopyFineY]
				vram_addr[loopyNameTableY] = tram_addr[loopyNameTableY]
				vram_addr[loopyCoarseY]    = tram_addr[loopyCoarseY]
			}
		}


		func LoadBackgroundShifters() {
			bg_shifter_pattern_lo = (bg_shifter_pattern_lo & 0xFF00) | bg_next_tile_lsb
			bg_shifter_pattern_hi = (bg_shifter_pattern_hi & 0xFF00) | bg_next_tile_msb

			bg_shifter_attrib_lo  = (bg_shifter_attrib_lo & 0xFF00) | ((bg_next_tile_attrib & 0b01) > 0 ? 0xFF : 0x00)
			bg_shifter_attrib_hi  = (bg_shifter_attrib_hi & 0xFF00) | ((bg_next_tile_attrib & 0b10) > 0 ? 0xFF : 0x00)
		}


		func UpdateShifters() {
			if mask[renderBackground] > 0 {
				bg_shifter_pattern_lo <<= 1
				bg_shifter_pattern_hi <<= 1
				bg_shifter_attrib_lo <<= 1
				bg_shifter_attrib_hi <<= 1
			}
			
			if mask[renderSprite] > 0 && cycle >= 1 && cycle < 258 {
				for i in 0 ..< sprite_count {
					if spriteScanline[i*4 + 3] > 0 {
						spriteScanline[i*4 + 3] -= 1
					} else {
						sprite_shifter_pattern_lo[i] <<= 1
						sprite_shifter_pattern_hi[i] <<= 1
					}
				}
			}
		}

		if scanline >= -1 && scanline < 240 {
			if scanline == 0 && cycle == 0 {
				cycle = 1
			}
			if scanline == -1 && cycle == 1 {
				status[verticalBlank] = 0
				
				status[spriteOverflow] = 0
				
				for i in 0 ..< 8 {
					sprite_shifter_pattern_lo[i] = 0
					sprite_shifter_pattern_hi[i] = 0
				}
			}
			if (cycle >= 2 && cycle < 258) || (cycle >= 321 && cycle < 338) {
				UpdateShifters()
				switch (cycle - 1) % 8 {
				case 0:
					LoadBackgroundShifters()
					bg_next_tile_id = ppuRead(addr: 0x2000 | (vram_addr & 0x0FFF))
				case 2:
					bg_next_tile_attrib = ppuRead(addr: 0x23C0 | (vram_addr[loopyNameTableY] << 11)
															   | (vram_addr[loopyNameTableX] << 10)
															   | ((vram_addr[loopyCoarseY] >> 2) << 3)
															   | (vram_addr[loopyCoarseX] >> 2))
					if vram_addr[loopyCoarseY] & 0x02 > 0 {
						bg_next_tile_attrib >>= 4
					}
					if vram_addr[loopyCoarseX] & 0x02 > 0 {
						bg_next_tile_attrib >>= 2
					}
					bg_next_tile_attrib &= 0x03
				case 4:
					bg_next_tile_lsb = ppuRead(addr: (control[patternBackground] << 12)
													| (bg_next_tile_id << 4)
													| vram_addr[loopyFineY])
				case 6:
					bg_next_tile_msb = ppuRead(addr: (control[patternBackground] << 12)
													| (bg_next_tile_id << 4)
													| vram_addr[loopyFineY] + 8)
				case 7:
					IncrementScrollX()
				default:
					break
				}
			}
					
			if cycle == 256 {
				IncrementScrollY()
			}

			if cycle == 257 {
				LoadBackgroundShifters()
				TransferAddressX()
			}
			
			if cycle == 338 || cycle == 340 {
				bg_next_tile_id = ppuRead(addr: 0x2000 | (vram_addr & 0x0FFF))
			}

			if scanline == -1 && cycle >= 280 && cycle < 305 {
				TransferAddressY()
			}
			
			
			// ********************
			// Foreground Rendering
			// ********************
			
			if cycle == 257 && scanline >= 0 {
				spriteScanline = Array(repeating: 0xFF, count: 8*4)
				sprite_count = 0
				var nOAMEntry = 0
				while (nOAMEntry < 64 && sprite_count < 9) {
					let diff = scanline - OAM[nOAMEntry * 4 + 0]
					if diff >= 0 && diff < (control[spriteSize] > 0 ? 16 : 8) {
						if sprite_count < 8 {
							for i in 0 ..< 4 {
								spriteScanline[sprite_count * 4 + i] = OAM[nOAMEntry * 4 + i]
							}
							sprite_count += 1
						}
					}
					nOAMEntry += 1
				}
				status[spriteOverflow] = (sprite_count > 8) ? 1 : 0
				if sprite_count == 9 {
					sprite_count = 8
				}
			}
			
			if cycle == 340 {
				var sprite_pattern_bits_lo = 0
				var sprite_pattern_bits_hi = 0
				var sprite_pattern_addr_lo = 0
				var sprite_pattern_addr_hi = 0
				//	var oamY         = 0xFF000000
				//	var oamID        = 0x00FF0000
				//	var oamAttribute = 0x0000FF00
				//	var oamX         = 0x000000FF

				for i in 0 ..< sprite_count {
					if control[spriteSize] == 0 {
						// 8x8
						if spriteScanline[i*4 + 2] & 0x80 == 0 {
							// not flipped
							sprite_pattern_addr_lo =
								(control[patternSprite] << 12)
								| (spriteScanline[i*4 + 1] << 4)
								| (scanline - spriteScanline[i*4 + 0])
							
						} else {
							// flipped
							sprite_pattern_addr_lo =
								(control[patternSprite] << 12)
								| (spriteScanline[i*4 + 1] << 4)
								| (7 - (scanline - spriteScanline[i*4 + 0]))
						}
					} else {
						// 8x16
						if spriteScanline[i*4 + 2] & 0x80 == 0 {
							// not flipped
							if scanline - spriteScanline[i*4 + 0] < 8 {
								// top half
								sprite_pattern_addr_lo =
									((spriteScanline[i*4 + 1] & 0x01) << 12)
									| ((spriteScanline[i*4 + 1] & 0xFE) << 4)
									| ((scanline - spriteScanline[i*4 + 0]) & 0x07)
							} else {
								// bottom half
								sprite_pattern_addr_lo =
									((spriteScanline[i*4 + 1] & 0x01) << 12)
									| (((spriteScanline[i*4 + 1] & 0xFE) + 1) << 4)
									| ((scanline - spriteScanline[i*4 + 0]) & 0x07)
							}
						} else {
							// flipped
							if scanline - spriteScanline[i*4 + 0] < 8 {
								// top half
								sprite_pattern_addr_lo =
									((spriteScanline[i*4 + 1] & 0x01) << 12)
									| (((spriteScanline[i*4 + 1] & 0xFE) + 1) << 4)
									| (7 - (scanline - spriteScanline[i*4 + 0]) & 0x07)
							} else {
								// bottom half
								sprite_pattern_addr_lo =
									((spriteScanline[i*4 + 1] & 0x01) << 12)
									| ((spriteScanline[i*4 + 1] & 0xFE) << 4)
									| (7 - (scanline - spriteScanline[i*4 + 0]) & 0x07)
							}
						}
					}
					sprite_pattern_addr_hi = sprite_pattern_addr_lo + 8
					sprite_pattern_bits_lo = ppuRead(addr: sprite_pattern_addr_lo)
					sprite_pattern_bits_hi = ppuRead(addr: sprite_pattern_addr_hi)
					
					if spriteScanline[i*4 + 2] & 0x40 > 0 {
						func flipByte(_ n: Int) -> Int {
							var b = n
							b = (b & 0xF0) >> 4 | (b & 0x0F) << 4
							b = (b & 0xCC) >> 2 | (b & 0x33) << 2
							b = (b & 0xAA) >> 1 | (b & 0x55) << 1
							return b
						}
						
						sprite_pattern_bits_lo = flipByte(sprite_pattern_bits_lo)
						sprite_pattern_bits_hi = flipByte(sprite_pattern_bits_hi)
					}
					
					sprite_shifter_pattern_lo[i] = sprite_pattern_bits_lo
					sprite_shifter_pattern_hi[i] = sprite_pattern_bits_hi
				}
			}
		}

		if scanline == 240 {
		}
		
		if scanline >= 241 && scanline < 261 {
			if scanline == 241 && cycle == 1 {
				status[verticalBlank] = 1
				if control[enableNMI] > 0 {
					nmi = true
				}
			}
		}

		var bg_pixel = 0x00
		var bg_palette = 0x00

		if mask[renderBackground] > 0 {
			let bit_mux = 0x8000 >> fine_x

			let p0_pixel = (bg_shifter_pattern_lo & bit_mux) > 0 ? 1 : 0
			let p1_pixel = (bg_shifter_pattern_hi & bit_mux) > 0 ? 1 : 0
			bg_pixel = (p1_pixel << 1) | p0_pixel

			let bg_pal0 = (bg_shifter_attrib_lo & bit_mux) > 0 ? 1 : 0
			let bg_pal1 = (bg_shifter_attrib_hi & bit_mux) > 0 ? 1 : 0
			bg_palette = (bg_pal1 << 1) | bg_pal0
		}
		
		var fg_pixel = 0x00
		var fg_palette = 0x00
		var fg_priority = 0x00
		
		if mask[renderSprite] > 0 {
			for i in 0 ..< sprite_count {
				if spriteScanline[i*4 + 3] == 0 {
					let fg_pixel_lo = (sprite_shifter_pattern_lo[i] & 0x80) > 0 ? 1 : 0
					let fg_pixel_hi = (sprite_shifter_pattern_hi[i] & 0x80) > 0 ? 1 : 0
					fg_pixel = (fg_pixel_hi << 1) | fg_pixel_lo
					
					fg_palette = (spriteScanline[i*4 + 2] & 0x03) + 0x04
					fg_priority = (spriteScanline[i*4 + 2] & 0x20) == 0 ? 1 : 0
					
					if fg_pixel != 0 {
						break
					}
				}
			}
		}
		
		var pixel = 0
		var palette = 0
		
		if bg_pixel == 0 && fg_pixel == 0 {
			pixel = 0
			palette = 0
		} else if bg_pixel == 0 && fg_pixel > 0 {
			pixel = fg_pixel
			palette = fg_palette
		} else if bg_pixel > 0 && fg_pixel == 0 {
			pixel = bg_pixel
			palette = bg_palette
		} else {
			if fg_priority > 0 {
				pixel = fg_pixel
				palette = fg_palette
			} else {
				pixel = bg_pixel
				palette = bg_palette
			}
		}

		let color = GetColorFromPaletteRam(palette: palette, pixel: pixel)
		sprScreen[cycle - 1, scanline] = color
		
		cycle += 1
		if cycle >= 341 {
			cycle = 0
			scanline += 1
			if scanline >= 261 {
				scanline = -1
				frame_complete = true
			}
		}
	}
}
