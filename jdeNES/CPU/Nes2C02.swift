//
//  Nes2C02.swift
//  jdeNES
//
//  Created by David Ensminger on 2/9/21.
//

class Nes2C02 {
	// Status
	let spriteOverflow: UInt8       = 0b0010_0000
	let spriteZero: UInt8           = 0b0100_0000
	let verticalBlank: UInt8        = 0b1000_0000

	// Mask
	let grayscale: UInt8            = 0b0000_0001
	let renderBackgroundLeft: UInt8 = 0b0000_0010
	let renderSpriteLeft: UInt8     = 0b0000_0100
	let renderBackground: UInt8     = 0b0000_1000
	let renderSprite: UInt8         = 0b0001_0000
	let enhanceRed: UInt8           = 0b0010_0000
	let enhanceGreen: UInt8         = 0b0100_0000
	let enhanceBlue: UInt8          = 0b1000_0000

	// Control
	let nameTableX: UInt8           = 0b0000_0001
	let nameTableY: UInt8           = 0b0000_0010
	let incrementMode: UInt8        = 0b0000_0100
	let patternSprite: UInt8        = 0b0000_1000
	let patternBackground: UInt8    = 0b0001_0000
	let spriteSize: UInt8           = 0b0010_0000
	let slaveMode: UInt8            = 0b0100_0000
	let enableNMI: UInt8            = 0b1000_0000

	// loopy
	let loopyCoarseX: UInt16    = 0b0000_0000_0001_1111
	let loopyCoarseY: UInt16    = 0b0000_0011_1110_0000
	let loopyNameTableX: UInt16 = 0b0000_0100_0000_0000
	let loopyNameTableY: UInt16 = 0b0000_1000_0000_0000
	let loopyFineY: UInt16      = 0b0111_0000_0000_0000

	// Registers
	var status: UInt8  = 0x00
	var mask: UInt8    = 0x00
	var control: UInt8 = 0x00
	var vram_addr: UInt16 = 0x0000
	var tram_addr: UInt16 = 0x0000

	var address_latch = false
	var ppu_data_buffer: UInt8 = 0x00
	var ppu_address: UInt16 = 0x0000
	var fine_x: UInt8 = 0x00

	var nmi = false
	
	var cart: Cartridge!
	
	// tblName dimensions = [2][1024]
	var tblName = Array(repeating: Array(repeating: UInt8(0), count: 1024), count: 2)
	
	// tblPalette dimensions = [32]
	var tblPalette = Array(repeating: UInt8(0), count: 32)
	
	// tblPattern dimensions = [2][4096]
	var tblPattern = Array(repeating: Array(repeating: UInt(0), count: 4096), count: 2)
	
	var bg_next_tile_id: UInt8 = 0x00
	var bg_next_tile_attrib: UInt8 = 0x00
	var bg_next_tile_lsb: UInt8 = 0x00
	var bg_next_tile_msb: UInt8 = 0x00
	
	var bg_shifter_pattern_lo: UInt16 = 0x0000
	var bg_shifter_pattern_hi: UInt16 = 0x0000
	var bg_shifter_attrib_lo: UInt16 = 0x0000
	var bg_shifter_attrib_hi: UInt16 = 0x0000
	
	private static func rgbToUInt32(_ r: Int, _ g: Int, _ b: Int) -> UInt32 {
		return 0xFF000000 | UInt32(r << 16) | UInt32(g << 8) | UInt32(b)
	}
	
	var palScreen = [
		rgbToUInt32(84, 84, 84),       rgbToUInt32(0, 30, 116),       rgbToUInt32(8, 16, 144),       rgbToUInt32(48, 0, 136),       rgbToUInt32(68, 0, 100),       rgbToUInt32(92, 0, 48),        rgbToUInt32(84, 4, 0),         rgbToUInt32(60, 24, 0),        rgbToUInt32(32, 42, 0),        rgbToUInt32(8, 58, 0),         rgbToUInt32(0, 64, 0),         rgbToUInt32(0, 60, 0),         rgbToUInt32(0, 50, 60),        rgbToUInt32(0, 0, 0),          rgbToUInt32(0, 0, 0), rgbToUInt32(0, 0, 0),
		rgbToUInt32(152, 150, 152),    rgbToUInt32(8, 76, 196),       rgbToUInt32(48, 50, 236),      rgbToUInt32(92, 30, 228),      rgbToUInt32(136, 20, 176),     rgbToUInt32(160, 20, 100),     rgbToUInt32(152, 34, 32),      rgbToUInt32(120, 60, 0),       rgbToUInt32(84, 90, 0),        rgbToUInt32(40, 114, 0),       rgbToUInt32(8, 124, 0),        rgbToUInt32(0, 118, 40),       rgbToUInt32(0, 102, 120),      rgbToUInt32(0, 0, 0),          rgbToUInt32(0, 0, 0), rgbToUInt32(0, 0, 0),
		rgbToUInt32(236, 238, 236),    rgbToUInt32(76, 154, 236),     rgbToUInt32(120, 124, 236),    rgbToUInt32(176, 98, 236),     rgbToUInt32(228, 84, 236),     rgbToUInt32(236, 88, 180),     rgbToUInt32(236, 106, 100),    rgbToUInt32(212, 136, 32),     rgbToUInt32(160, 170, 0),      rgbToUInt32(116, 196, 0),      rgbToUInt32(76, 208, 32),      rgbToUInt32(56, 204, 108),     rgbToUInt32(56, 180, 204),     rgbToUInt32(60, 60, 60),       rgbToUInt32(0, 0, 0), rgbToUInt32(0, 0, 0),
		rgbToUInt32(236, 238, 236),    rgbToUInt32(168, 204, 236),    rgbToUInt32(188, 188, 236),    rgbToUInt32(212, 178, 236),    rgbToUInt32(236, 174, 236),    rgbToUInt32(236, 174, 212),    rgbToUInt32(236, 180, 176),    rgbToUInt32(228, 196, 144),    rgbToUInt32(204, 210, 120),    rgbToUInt32(180, 222, 120),    rgbToUInt32(168, 226, 144),    rgbToUInt32(152, 226, 180),    rgbToUInt32(160, 214, 228),    rgbToUInt32(160, 162, 160),    rgbToUInt32(0, 0, 0), rgbToUInt32(0, 0, 0)
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
					var tile_lsb = ppuRead(addr: UInt16(i * 0x1000 + offset + row))
					var tile_msb = ppuRead(addr: UInt16(i * 0x1000 + offset + row + 8))
					for col in 0 ..< 8 {
						let pixel = ((tile_msb & 0x01) << 1) | (tile_lsb & 0x01)
						tile_lsb >>= 1
						tile_msb >>= 1
						sprPatternTable[i][tileX * 8 + (7 - col), tileY * 8 + row] = GetColorFromPaletteRam(palette: palette, pixel: Int(pixel))
					}
				}
			}
		}
		return sprPatternTable[i]
	}

	func GetColorFromPaletteRam(palette: Int, pixel: Int) -> UInt32 {
		return palScreen[Int(ppuRead(addr: UInt16(0x3F00 + (palette << 2) + pixel) & 0x3F))]
	}

	func cpuWrite(addr: UInt16, data: UInt8) {
	}

	func cpuRead(addr: UInt16, readonly: Bool = false) -> UInt8 {
		return 0x00
	}
					
	func ppuRead(addr: UInt16) -> UInt8 {
		return 0x00
	}
	
	func ConnectCartridge(_ cart: Cartridge) {
	}
	
	func clock() {
	}
/*
	def cpuRead(self, addr, readonly=False):
		data = 0x00

		if readonly:
			if addr == 0x0000:      # control
				data = self.control
			elif addr == 0x0001:    # mask
				data = self.mask
			elif addr == 0x0002:    # status
				data = self.status
			elif addr == 0x0003:    # oam address
				pass
			elif addr == 0x0004:    # oam data
				pass
			elif addr == 0x0005:    # scroll
				pass
			elif addr == 0x0006:    # ppu address
				pass
			elif addr == 0x0007:    # ppu data
				pass
		else:
			if addr == 0x0000:      # control
				pass
			elif addr == 0x0001:    # mask
				pass
			elif addr == 0x0002:    # status
				# if (self.status & self.STATUS_VERTBLANK) > 0:
				#     print("  (PPU) reading status - vertblank true")
				data = (self.status & 0xE0) | (self.ppu_data_buffer & 0x1F)
				# if (data & self.STATUS_VERTBLANK) > 0:
				#     print("  (PPU) data has vertblank (0x%02X)" % (data))
				self.status &= ~self.STATUS_VERTBLANK
				self.address_latch = 0
			elif addr == 0x0003:    # oam address
				pass
			elif addr == 0x0004:    # oam data
				pass
			elif addr == 0x0005:    # scroll
				pass
			elif addr == 0x0006:    # ppu address
				pass
			elif addr == 0x0007:    # ppu data
				data = self.ppu_data_buffer
				self.ppu_data_buffer = self.ppuRead(self.vram_addr)

				if self.vram_addr > 0x3F00:
					data = self.ppu_data_buffer

				self.vram_addr += 32 if (self.control & self.CONTROL_INC_MODE > 0) else 1
		# print("  (PPU) returning 0x%02X" % (data))
		return data

	def cpuWrite(self, addr, data):
		if addr == 0x0000:      # control
			self.control = data
			if self.control & self.CONTROL_NAMETBL_X > 0:
				self.tram_addr |= self.LOOPY_NAMETBL_X
			else:
				self.tram_addr &= ~self.LOOPY_NAMETBL_X
			if self.control & self.CONTROL_NAMETBL_Y > 0:
				self.tram_addr |= self.LOOPY_NAMETBL_Y
			else:
				self.tram_addr &= ~self.LOOPY_NAMETBL_Y
		elif addr == 0x0001:    # mask
			self.mask = data
		elif addr == 0x0002:    # status
			pass
		elif addr == 0x0003:    # oam address
			pass
		elif addr == 0x0004:    # oam data
			pass
		elif addr == 0x0005:    # scroll
			if self.address_latch == 0:
				self.fine_x = data & 0x07
				self.tram_addr = (self.tram_addr & ~self.LOOPY_COARSE_X) | (data >> 3)
				self.address_latch = 1
			else:
				self.fine_y = data & 0x07
				self.tram_addr = (self.tram_addr & ~self.LOOPY_COARSE_Y) | ((data >> 3) << 5)
				self.address_latch = 0
		elif addr == 0x0006:    # ppu address
			if self.address_latch == 0:
				self.tram_addr = (self.tram_addr & 0x00FF) | (data << 8)
				self.address_latch = 1
			else:
				self.tram_addr = (self.tram_addr & 0xFF00) | data
				self.vram_addr = self.tram_addr
				self.address_latch = 0
		elif addr == 0x0007:    # ppu data
			self.ppuWrite(self.vram_addr, data)
			self.vram_addr += 32 if (self.control & self.CONTROL_INC_MODE > 0) else 1

	def ppuRead(self, addr, readonly=False):
		data = 0x00
		addr &= 0x3FFF

		cartData = self.cart.ppuRead(addr)
		if cartData:
			data = cartData
		elif addr >= 0x0000 and addr <= 0x1FFF:
			data = self.tblPattern[(addr & 0x1000) >> 12][addr & 0x0FFF]
		elif addr >= 0x2000 and addr <= 0x3EFF:
			addr &= 0x0FFF
			if self.cart.mirror == self.cart.MIRROR_VERTICAL:
				if addr >= 0x0000 and addr <= 0x03FF:
					data = self.tblName[0][addr & 0x03FF]
				if addr >= 0x0400 and addr <= 0x07FF:
					data = self.tblName[1][addr & 0x03FF]
				if addr >= 0x0800 and addr <= 0x0BFF:
					data = self.tblName[0][addr & 0x03FF]
				if addr >= 0x0C00 and addr <= 0x0FFF:
					data = self.tblName[1][addr & 0x03FF]
			elif self.cart.mirror == self.cart.MIRROR_HORIZONTAL:
				if addr >= 0x0000 and addr <= 0x03FF:
					data = self.tblName[0][addr & 0x03FF]
				if addr >= 0x0400 and addr <= 0x07FF:
					data = self.tblName[0][addr & 0x03FF]
				if addr >= 0x0800 and addr <= 0x0BFF:
					data = self.tblName[1][addr & 0x03FF]
				if addr >= 0x0C00 and addr <= 0x0FFF:
					data = self.tblName[1][addr & 0x03FF]
		elif addr >= 0x3F00 and addr <= 0x3FFF:
			addr &= 0x001F
			if addr == 0x0010:
				addr = 0x0000
			elif addr == 0x0014:
				addr = 0x0004
			elif addr == 0x0018:
				addr = 0x0008
			elif addr == 0x001C:
				addr = 0x000C
			data = self.tblPalette[addr]
		
		return data

	def ppuWrite(self, addr, data):
		addr &= 0x3FFF

		if self.cart.ppuWrite(addr, data):
			pass
		elif addr >= 0x0000 and addr <= 0x1FFF:
			self.tblPattern[(addr & 0x1000) >> 12][addr & 0x0FFF] = data
		elif addr >= 0x2000 and addr <= 0x3EFF:
			addr &= 0x0FFF
			if self.cart.mirror == self.cart.MIRROR_VERTICAL:
				if addr >= 0x0000 and addr <= 0x03FF:
					self.tblName[0][addr & 0x03FF] = data
				if addr >= 0x0400 and addr <= 0x07FF:
					self.tblName[1][addr & 0x03FF] = data
				if addr >= 0x0800 and addr <= 0x0BFF:
					self.tblName[0][addr & 0x03FF] = data
				if addr >= 0x0C00 and addr <= 0x0FFF:
					self.tblName[1][addr & 0x03FF] = data
			elif self.cart.mirror == self.cart.MIRROR_HORIZONTAL:
				if addr >= 0x0000 and addr <= 0x03FF:
					self.tblName[0][addr & 0x03FF] = data
				if addr >= 0x0400 and addr <= 0x07FF:
					self.tblName[0][addr & 0x03FF] = data
				if addr >= 0x0800 and addr <= 0x0BFF:
					self.tblName[1][addr & 0x03FF] = data
				if addr >= 0x0C00 and addr <= 0x0FFF:
					self.tblName[1][addr & 0x03FF] = data
		elif addr >= 0x3F00 and addr <= 0x3FFF:
			addr &= 0x001F
			if addr == 0x0010:
				addr = 0x0000
			elif addr == 0x0014:
				addr = 0x0004
			elif addr == 0x0018:
				addr = 0x0008
			elif addr == 0x001C:
				addr = 0x000C
			self.tblPalette[addr] = data

	def ConnectCartridge(self, cartridge):
		self.cart = cartridge

	def IncrementScrollX(self):
		if self.mask & self.MASK_RENDER_BKGD > 0 or self.mask & self.MASK_RENDER_SPR > 0:
			if self.vram_addr_coarse_x == 31:
				self.vram_addr &= ~self.LOOPY_COARSE_X
				if self.vram_addr_nametbl_x:
					self.vram_addr &= ~self.LOOPY_NAMETBL_X
				else:
					self.vram_addr |= self.LOOPY_NAMETBL_X
			else:
				c = self.vram_addr_coarse_x + 1
				self.vram_addr = (self.vram_addr & ~self.LOOPY_COARSE_X) | c

	def IncrementScrollY(self):
		if self.mask & self.MASK_RENDER_BKGD > 0 or self.mask & self.MASK_RENDER_SPR > 0:
			if self.vram_addr_fine_y < 7:
				c = self.vram_addr_fine_y + 1
				self.vram_addr = (self.vram_addr & ~self.LOOPY_FINE_Y) | (c << 12)
			else:
				self.vram_addr &= ~self.LOOPY_FINE_Y

				if self.vram_addr_coarse_y == 29:
					self.vram_addr &= ~self.LOOPY_COARSE_Y
					if self.vram_addr_nametbl_x:
						self.vram_addr &= ~self.LOOPY_NAMETBL_X
					else:
						self.vram_addr |= self.LOOPY_NAMETBL_X
				elif self.vram_addr_coarse_y == 31:
					self.vram_addr &= ~self.LOOPY_COARSE_Y
				else:
					c = self.vram_addr_coarse_y + 1
					self.vram_addr = (self.vram_addr & ~self.LOOPY_COARSE_Y) | (c << 5)

	def TransferAddressX(self):
		if self.mask & self.MASK_RENDER_BKGD > 0 or self.mask & self.MASK_RENDER_SPR > 0:
			self.vram_addr = (self.vram_addr & ~self.LOOPY_NAMETBL_X) | (self.tram_addr & self.LOOPY_NAMETBL_X)
			self.vram_addr = (self.vram_addr & ~self.LOOPY_COARSE_X)  | (self.tram_addr & self.LOOPY_COARSE_X)

	def TransferAddressY(self):
		if self.mask & self.MASK_RENDER_BKGD > 0 or self.mask & self.MASK_RENDER_SPR > 0:
			self.vram_addr = (self.vram_addr & ~self.LOOPY_FINE_Y) | (self.tram_addr & self.LOOPY_FINE_Y)
			self.vram_addr = (self.vram_addr & ~self.LOOPY_NAMETBL_Y) | (self.tram_addr & self.LOOPY_NAMETBL_Y)
			self.vram_addr = (self.vram_addr & ~self.LOOPY_COARSE_Y)  | (self.tram_addr & self.LOOPY_COARSE_Y)

	def LoadBackgroundShifters(self):
		self.bg_shifter_pattern_lo = (self.bg_shifter_pattern_lo & 0xFF00) | self.bg_next_tile_lsb
		self.bg_shifter_pattern_hi = (self.bg_shifter_pattern_hi & 0xFF00) | self.bg_next_tile_msb
		self.bg_shifter_attrib_lo = (self.bg_shifter_attrib_lo & 0xFF00) | (0xFF if (self.bg_next_tile_attrib & 0x01) > 0 else 0x00)
		self.bg_shifter_attrib_hi = (self.bg_shifter_attrib_hi & 0xFF00) | (0xFF if (self.bg_next_tile_attrib & 0x02) > 0 else 0x00)

	def UpdateShifters(self):
		if self.mask & self.MASK_RENDER_BKGD:
			self.bg_shifter_pattern_lo <<= 1
			self.bg_shifter_pattern_hi <<= 1
			self.bg_shifter_attrib_lo <<= 1
			self.bg_shifter_attrib_hi <<= 1
		

	def clock(self):
		if self.scanline >= -1 and self.scanline < 240:
			if self.scanline == -1 and self.cycle == 1:
				self.status &= ~self.STATUS_VERTBLANK
			if (self.cycle >=2 and self.cycle < 258) or (self.cycle >= 321 and self.cycle < 338):
				self.UpdateShifters()
				cycle = (self.cycle - 1) % 8
				if cycle == 0:
					self.LoadBackgroundShifters()
					self.bg_next_tile_id = self.ppuRead(0x2000 | (self.vram_addr & 0x0FFF))
				elif cycle == 2:
					self.bg_next_tile_attrib = self.ppuRead(0x23C0 | (self.vram_addr_nametbl_y << 11)
						| (self.vram_addr_nametbl_x << 10)
						| ((self.vram_addr_coarse_y >> 2) << 3)
						| (self.vram_addr_coarse_x >> 2))
					if self.vram_addr_coarse_y & 0x02 > 0:
						self.bg_next_tile_attrib >>= 4
					if self.vram_addr_coarse_x & 0x02 > 0:
						self.bg_next_tile_attrib >>= 2
					self.bg_next_tile_attrib &= 0x03
				elif cycle == 4:
					self.bg_next_tile_lsb = self.ppuRead((1 << 12 if (self.control & self.CONTROL_PATT_BKGD > 0) else 0)
						+ (self.bg_next_tile_id << 4)
						+ (self.vram_addr_fine_y))
				elif cycle == 6:
					self.bg_next_tile_msb = self.ppuRead((1 << 12 if (self.control & self.CONTROL_PATT_BKGD > 0) else 0)
						+ (self.bg_next_tile_id << 4)
						+ (self.vram_addr_fine_y) + 8)
				elif cycle == 7:
					self.IncrementScrollX()
					
			if self.cycle == 256:
				self.IncrementScrollY()

			if self.cycle == 257:
				self.TransferAddressX()

			if self.scanline == -1 and self.cycle >= 280 and self.cycle <= 305:
				self.TransferAddressY()

		if self.scanline == 240:
			pass
		
		if self.scanline == 241 and self.cycle == 1:
			# print("Setting vertblank")
			self.status |= self.STATUS_VERTBLANK
			if self.control & self.CONTROL_ENABLE_NMI > 0:
				self.nmi = True

		bg_pixel = 0x00
		bg_palette = 0x00

		if self.mask & self.MASK_RENDER_BKGD:
			bit_mux = 0x8000 >> self.fine_x

			p0_pixel = 1 if (self.bg_shifter_pattern_lo & bit_mux) > 0 else 0
			p1_pixel = 1 if (self.bg_shifter_pattern_hi & bit_mux) > 0 else 0
			bg_pixel = (p1_pixel << 1) | p0_pixel

			bg_pal0 = 1 if (self.bg_shifter_attrib_lo & bit_mux) > 0 else 0
			bg_pal1 = 1 if (self.bg_shifter_attrib_hi & bit_mux) > 0 else 0
			bg_palette = (bg_pal1 << 1) | bg_pal0

		self.sprScreen.set_at((self.cycle - 1, self.scanline), self.GetColorFromPaletteRam(bg_palette, bg_pixel))
		self.cycle += 1
		if self.cycle >= 341:
			self.cycle = 0
			self.scanline += 1
			if self.scanline >= 261:
				self.scanline = -1
				self.frame_complete = True

	*/
}
