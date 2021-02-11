import types

type Mapper2* = ref object of RootRef
  cartridge: Cartridge
  prgBanks, prgBank1, prgBank2: int

proc step*(m: Mapper2) =
  discard

proc `[]`*(m: Mapper2, adr: uint16): uint8 =
  case adr
  of 0x0000..0x1FFF: result = m.cartridge.chr[adr.int]
  of 0x6000..0x7FFF: result = m.cartridge.sram[adr.int - 0x6000]
  of 0x8000..0xBFFF: result = m.cartridge.prg[m.prgBank1*0x4000 + int(adr - 0x8000)]
  of 0xC000..0xFFFF: result = m.cartridge.prg[m.prgBank2*0x4000 + int(adr - 0xC000)]
  else: raise newException(ValueError, "unhandled mapper2 read at: " & $adr)

proc `[]=`*(m: Mapper2, adr: uint16, val: uint8) =
  case adr
  of 0x0000..0x1FFF: m.cartridge.chr[adr.int] = val
  of 0x6000..0x7FFF: m.cartridge.sram[adr.int - 0x6000] = val
  of 0x8000..0xFFFF: m.prgBank1 = val.int mod m.prgBanks
  else: raise newException(ValueError, "unhandled mapper2 write at: " & $adr)

proc newMapper2*(cartridge: Cartridge): Mapper2 =
  result = Mapper2(
    cartridge: cartridge,
    prgBanks: cartridge.prg.len div 0x4000,
    prgBank1: 0,
    prgBank2: cartridge.prg.len div 0x4000 - 1
  )
