module utils

import os
import encoding.binary

pub fn to_24(in_buf []u8) u32 {
	mut out_buf := []u8{len: 4}
	out_buf[1] = in_buf[0]
	out_buf[2] = in_buf[1]
	out_buf[3] = in_buf[2]
	return binary.big_endian_u32(out_buf)
}

pub fn read_le_u32(mut f os.File) !u32 {
	mut buf := []u8{len: 4}
	f.read(mut buf)!
	return binary.little_endian_u32(buf)
}

pub fn read_be_u16(mut f os.File) !u16 {
	mut buf := []u8{len: 2}
	f.read(mut buf)!
	return binary.big_endian_u16(buf)
}

pub fn read_be_u32(mut f os.File) !u32 {
	mut buf := []u8{len: 4}
	f.read(mut buf)!
	return binary.big_endian_u32(buf)
}

pub fn read_str(mut f os.File, str_len int) !string {
	mut buf := []u8{len: str_len}
	f.read(mut buf)!
	return buf.bytestr()
}
