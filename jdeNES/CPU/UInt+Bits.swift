//
//  UInt+Bits.swift
//  jdeNES
//
//  Created by David Ensminger on 2/10/21.
//

extension UnsignedInteger {
	// This convenience function will perform a bitwise AND of self with mask
	// and then shift all the bits over so that they are the right-most bits.
	// This is useful for flags, where certain bits in a flag represent
	// a particular value.
	// Example:
	// let a    = UInt(0b0110_0000)
	// let mask = UInt(0b0111_0000)
	// a[mask] == 0b0000_0110
	subscript(mask: Self) -> Self {
		get {
			var n = self & mask
			var m = mask
			if mask > 0 {
				while m & 0x01 == 0 {
					m >>= 1
					n >>= 1
				}
			}
			return n
		}
		set(value) {
			var m = mask
			var v = value
			if mask > 0 {
				while m & 0x01 == 0 {
					m >>= 1
					v <<= 1
				}
			}
			self = (self & ~mask) | v
		}
	}
}

