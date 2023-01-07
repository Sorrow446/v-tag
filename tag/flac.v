module tag

import os

fn check_magic(mut f os.File) !{
	magic := read_str(mut f, 4)!
	if magic != "fLaC" {
		return error('bad magic')
	}
}

fn parse_vorb_block(mut f os.File, mut parsed &FLACMeta) !{
	f.seek(3, .current) or {
		return err
	}

	vendor_len := read_le_u32(mut f)!

	f.seek(vendor_len, .current) or {
		return err
	}
	com_count := read_le_u32(mut f)!

	for _ in 0..com_count {
		com_len := read_le_u32(mut f)!
		
		mut com_buf := []u8{len: int(com_len)}
		f.read(mut com_buf)!
		com := com_buf.bytestr()
		split_com := com.split_nth('=', 2)
		if split_com.len != 2 {
			return error('invalid comment')
		}
		field_ := split_com[0]
		val := split_com[1]

		field_lower := field_.to_lower()

		match field_lower {
			"tracknumber" {
				parsed.track_number = val.int()
				continue
			}
			"tracktotal" {
				parsed.track_total = val.int()
				continue
			}
			"discnumber" {
				parsed.disk_number = val.int()
				continue
			}
			"disctotal" {
				parsed.disk_total = val.int()
				continue
			}
			"year" {
				parsed.year = val.int()
				continue
			}
			"itunesadvisory" {
				parsed.itunes_advisory = val.int()
				continue
			}
			"compilation" {
				parsed.compilation = val.int()
				continue
			}	
			"explicit" {
				parsed.explicit = val.int()
				continue
			}
			"length" {
				parsed.length = val.int()
				continue
			}				

			else {}
		}

		resolved := resolve_field_flac[field_lower]
		if resolved == "" {
			parsed.custom[field_.to_upper()] = val
			continue
		}

		$for field in FLACMeta.fields {
			$if field.typ is string {
				if field.name == resolved {
					parsed.$(field.name) = val
				}
			}
		}
	}
}

fn parse_pic_block(mut f os.File, mut parsed &FLACMeta) !{
	mut description := ""
	f.seek(3, .current) or {
		return err
	}
	picture_type := read_be_u32(mut f)!
	mime_len := read_be_u32(mut f)!
	mime_type := read_str(mut f, int(mime_len))!
	desc_len := read_be_u32(mut f)!
	if desc_len > 0 {
		description = read_str(mut f, int(desc_len))!
	}
	width := read_be_u32(mut f)!
	height := read_be_u32(mut f)!
	colour_depth := read_be_u32(mut f)!
	f.seek(4, .current) or {
		return err
	}
	data_len := read_be_u32(mut f)!
	mut cov_buf := []u8{len: int(data_len)}
	f.read(mut cov_buf)!
	cov := FLACCover{
		picture_data: cov_buf,
		description: description,
		width: int(width),
		height: int(height),
		mime_type: mime_type,
		colour_depth: int(colour_depth),
		picture_type: resolve_pic_type_flac[int(picture_type)],
	}
	parsed.covers << cov
	parsed.has_covers = true
}

fn skip(mut f os.File) !{
	mut buf := []u8{len: 3}
	f.read(mut buf)!
	size := to_24(buf)
	f.seek(size, .current) or {
		return err
	}
}

pub fn read_flac(flacPath string) !&FLACMeta {
	mut parsed := &FLACMeta{}
	mut f := os.open_file(flacPath, 'rb', 0o755) or {
		return err
	}
	defer {
		f.close()
	}
	check_magic(mut f)!
	for {
		mut buf := []u8{len: 1}
		f.read(mut buf)!
		
		t := buf[0] & 0x7F
		match t {
			0x4 {
				parse_vorb_block(mut f, mut parsed)!
			}
			0x6 {
				parse_pic_block(mut f, mut parsed)!
			}
			else {
				skip(mut f)!
			}
		}
		last := 1 & (buf[0] >> 7) == 1
		if last {
			break
		}
	}
	return parsed
}