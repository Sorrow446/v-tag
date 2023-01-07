module vtag

import os
import encoding.binary

fn check_header(mut f os.File) !{
	magic := read_str(mut f, 3)!
	if magic != "ID3" {
		return error('bad magic')
	}


	mut ver_buf := []u8{len: 2}
	f.read(mut ver_buf)!
	if !(ver_buf[0] == 0x3 && ver_buf[1] == 0x0) {
		return error('unsupported id3 version')
	}
	mut flag_buf := []u8{len: 1}
	f.read(mut flag_buf)!
	if flag_buf[0] & 0x40 != 0 {
		return error('extended header is unsupported')
	}
	f.seek(4, .current) or {
		return err
	}
}

fn read_frame_id(f os.File) !string {
	mut buf := []u8{len: 4}
	f.read(mut buf) or {
		return err
	}
	if buf == []u8{len: 4} {
		return ""
	}
	frame_id_str := buf.bytestr()
	if frame_id_str !in id3_frames {
		return ""
	}
	return frame_id_str
}

fn read_size(f os.File) !u32 {
	mut buf := []u8{len: 4}
	f.read(mut buf) or {
		return err
	}
	return binary.big_endian_u32(buf) -1 
}

fn read_txxx(mut f os.File, str_len u32, mut parsed ID3Meta) !{
	f.seek(5, .current) or {
		return err
	}
	mut buf := []u8{len: int(str_len)}
	f.read(mut buf)!

	mut field := ""
	mut val := ""

	for idx, _ in buf {
		if buf[idx..idx+3] == []u8{len: 3} {
			field = buf[..idx].bytestr()
			val = buf[idx..].bytestr()
			break
		}
	}
	parsed.custom[field] = val
}

fn read_str_to_null(f os.File) !string {
	mut buf := []u8{len: 1}
	mut s := ""
	for {
		f.read(mut buf) or {
			return err
		}
		if buf == []u8{len: 1} {
			break
		}
		s += buf.bytestr()
	}
	return s
}

fn read_cover_type(f os.File) !string {
	mut buf := []u8{len: 1}
	f.read(mut buf)!
	return resolve_pic_type_id3[buf[0]]
}

fn read_apic(mut f os.File, data_len u32, mut parsed ID3Meta) !{

	f.seek(3, .current) or {
		return err
	}

	mime := read_str_to_null(f) or {
		return err
	}
	if mime == "" {
		f.seek(1, .current) or {
			return err
		}
	}

	cover_type := read_cover_type(f)!
	description := read_str_to_null(f) or {
		return err
	}
	if description == "" {
		f.seek(1, .current) or {
			return err
		}
	}

	mut buf := []u8{len: int(data_len)}
	f.read(mut buf)!
	cov := &ID3Cover{
		description: description
		mime_type: mime
		picture_data: buf
		picture_type: cover_type
	}
	parsed.covers << cov
	parsed.has_covers = true
}

fn read_trck(mut f os.File, str_len u32, mut parsed ID3Meta, is_disk bool) !{
	f.seek(3, .current) or {
		return err
	}
	val := read_str(mut f, int(str_len))!
	split_val := val.split('/')
	if split_val.len !in [1, 2] {
		mut tag := "track"
		if is_disk {
			tag = "disk"
		}
		return error('invalid $tag number / $tag total')
	}
	totals := split_val.len == 2

	num_one := split_val[0].int()
	mut num_two := 0
	if totals {
		num_two = split_val[1].int()
	}

	if is_disk {
		parsed.disk_number = num_one
		if totals {
			parsed.disk_total = num_two
		}
	} else {
		parsed.track_number = num_one
		if totals {
			parsed.track_total = num_two
		}
	}

}

fn set_field_val(mut parsed ID3Meta, frame_id string, val string) {
	resolved := resolve_field_id3[frame_id]
	if resolved == "" {
		return
	}
	$for field in ID3Meta.fields {
		$if field.typ is string {
			if field.name == resolved {
				parsed.$(field.name) = val
			}
		}
	}
}

fn set_genre(mut parsed ID3Meta, val string) {
	mut resolved := resolve_genre[val]
	if resolved == "" {
		resolved = val
	}
	parsed.genre = resolved
}

pub fn read_id3 (mp3Path string) !&ID3Meta {
	mut parsed := &ID3Meta{}
    mut f := os.open_file(mp3Path, 'rb', 0o755) or {
    	return err
    }
	defer {
		f.close()
	}
	check_header(mut f)!
	for {
		mut frame_id := read_frame_id(f)!
		if frame_id == "" {
			break
		}
		mut str_len := read_size(f)!

		match frame_id {
			'TXXX' {
				str_len = str_len-2
				read_txxx(mut f, str_len, mut parsed)!
				continue
			}
			'TRCK' {
				read_trck(mut f, str_len, mut parsed, false)!
				continue
			}
			'TPOS' {
				read_trck(mut f, str_len, mut parsed, true)!
				continue
			}			
			'APIC' {
				str_len = str_len-13
				read_apic(mut f, str_len, mut parsed)!
				continue
			}
			'COMM', 'USLT' {
				f.seek(3, .current) or {
					return err
				}
				str_len = str_len-3
			}
			else {}
		}

		if str_len == 0 {
			f.seek(3, .current) or {
				return err
			}
			continue
		}
		f.seek(3, .current) or {
			return err
		}
		val := read_str(mut f, int(str_len))!
		match frame_id {
			'TYER' {
				parsed.year = val.int()
			}
			'TBMP' {
				parsed.bpm = val.int()
			}
			'TCMP' {
				parsed.compilation = val.int() == 1
			}
			'TCON' {
				set_genre(mut parsed, val)
			}
			else {
				set_field_val(mut parsed, frame_id, val)
			}
		}
	}
	return parsed
}