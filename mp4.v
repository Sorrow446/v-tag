module vtag

import os

fn check_magic_(mut f os.File) !{
	f.seek(4, .start)!
	magic := read_str(mut f, 7)!
	if magic != "ftypM4A" {
		return error('bad magic, currently only M4A is supported')
	}
	f.seek(0, .start)!
}

fn read_atom_name(mut f os.File) !string {
	mut buf := []u8{len: 4}
	f.read(mut buf)!
	return buf.hex()
}

fn read_regular(mut f os.File, mut parsed &MP4Meta, resolved string) !int {
	size := read_be_u32(mut f)!
	f.seek(12, .current) or {
		return err
	}

	val := read_str(mut f, int(size)-16)!
	$for field in MP4Meta.fields {
		$if field.typ is string {
			if field.name == resolved {
				parsed.$(field.name) = val
			}
		}
	}

	return int(size) + 8
}

fn contains_str(val string) bool {
	mut contains := false
	for c in val {
    	if !nums.contains(c) {
    		contains = true
    		break
    	}	
	}
	return contains
}

fn read_year(mut f os.File, mut parsed &MP4Meta) !int {
	size := read_be_u32(mut f)!
	f.seek(12, .current) or {
		return err
	}
	val := read_str(mut f, int(size)-16)!
	if contains_str(val) {
		parsed.date = val
	} else {
		parsed.year = val.int()
	}
	return int(size) + 8
}

fn read_custom(mut f os.File, mut parsed &MP4Meta) !int{
	mean_size := read_be_u32(mut f)!
	f.seek(mean_size-4, .current) or {
		return err
	}
	name_size := read_be_u32(mut f)!
	f.seek(8, .current) or {
		return err
	}
	atom_field := read_str(mut f, int(name_size)-12)!
	data_size := read_be_u32(mut f)!
	f.seek(12, .current) or {
		return err
	}
	v := read_str(mut f, int(data_size)-16)!
	parsed.custom[atom_field.to_upper()] = v
	return int(mean_size+name_size+data_size) + 8
}

fn read_covr(mut f os.File, mut parsed &MP4Meta) !int{
	f.seek(-8, .current) or {
		return err
	}
	covr_size := read_be_u32(mut f)!
	f.seek(4, .current) or {
		return err
	}

	mut read := 0
	for {
		size := read_be_u32(mut f)!
		read += int(size) + 4
		f.seek(12, .current) or {
			return err
		}
		mut buf := []u8{len: int(size)-16}
		f.read(mut buf) or {
			return err
		}
		parsed.covers << &MP4Cover{
			picture_data: buf
		}
		parsed.has_covers = true
		if read >= covr_size {
			break
		}
	}
	return int(covr_size) + 8
}

fn read_trkn(mut f os.File, mut parsed &MP4Meta, is_track bool) !int{
	size := read_be_u32(mut f)!
	f.seek(14, .current) or {
		return err
	}
	num := read_be_u16(mut f)!
	total := read_be_u16(mut f)!
	if is_track {
		parsed.track_number = num
		parsed.track_total = total
	} else {
		parsed.disk_number = num
		parsed.disk_total = total
	}
	f.seek(size-22, .current) or {
		return err
	}

	return int(size) + 8
}

fn read_comp(mut f os.File, mut parsed &MP4Meta, is_comp bool) !int{
	size := read_be_u32(mut f)!
	f.seek(12, .current) or {
		return err
	}
	mut buf := []u8{len: 1}
	f.read(mut buf)!
	if is_comp {
		parsed.compilation = buf[0] == 1
	} else {
		parsed.itunes_advisory = buf[0]
	}
	f.seek(size-17, .current) or {
		return err
	}
	return int(size) + 8
}

fn read_gnre(mut f os.File, mut parsed &MP4Meta) !int{
	size := read_be_u32(mut f)!
	f.seek(13, .current) or {
		return err
	}
	mut buf := []u8{len: 1}
	f.read(mut buf)!
	
	parsed.genre = resolve_genre_mp4[buf[0]]
	f.seek(size-18, .current) or {
		return err
	}

	return int(size) + 8
}

fn read_bpm(mut f os.File, mut parsed &MP4Meta) !int{
	size := read_be_u32(mut f)!
	f.seek(12, .current)!
	bpm := read_be_u16(mut f)!
	parsed.bpm = bpm
	f.seek(size-18, .current)!
	return int(size) + 8
}

fn seek_to_atom(mut f os.File, atom_name string) !{
	for {
		mut size := read_be_u32(mut f)!
		f.seek(size, .current) or {
			return err
		}
		atom_name_ := read_str(mut f, 4)!
		if atom_name_ == atom_name {
			break
		}
		f.seek(-8, .current)!
	}
}

fn seek_to_ilst(mut f os.File) !u32 {
	ftype_size := read_be_u32(mut f)!
	f.seek(ftype_size+4, .current) or {
		return err
	}
	mvhd_size := read_be_u32(mut f)!
	f.seek(mvhd_size-4, .current) or {
		return err
	}
	seek_to_atom(mut f, 'udta')!
	//meta_size := read_be_u32(mut f)!

	f.seek(12, .current)!
	seek_to_atom(mut f, 'ilst')!

	f.seek(-8, .current)!
	ilst_size := read_be_u32(mut f)!
	return ilst_size
}

pub fn read_mp4(mp4Path string) !&MP4Meta {
	mut f := os.open_file(mp4Path, 'rb', 0o755) or {
		panic(err)
	}
	defer {
		f.close()
	}
	check_magic_(mut f)!
	mut parsed := &MP4Meta{}
	ilst_size := seek_to_ilst(mut f)!

	mut read := 8
	for {
		mut s := 0
		atom_name := read_atom_name(mut f)!
		resolved := resolve_atom[atom_name]
		// use hex instead because .bytestr() disposes the (c) symbol
		match atom_name {
			"2d2d2d2d" {
				s = read_custom(mut f, mut parsed)!
			}
			"636f7672" {
				s = read_covr(mut f, mut parsed)!
			}
			"74726b6e" {
				s = read_trkn(mut f, mut parsed, true)!
			}
			"6469736b" {
				s = read_trkn(mut f, mut parsed, false)!
			}
			"6370696c" {
				s = read_comp(mut f, mut parsed, true)!
			}
			"72746e67" {
				s = read_comp(mut f, mut parsed, false)!
			}
			"746d706f" {
				s = read_bpm(mut f, mut parsed)!			
			}
			"676e7265" {
				s = read_gnre(mut f, mut parsed)!
			}
			"a9646179" {
				s = read_year(mut f, mut parsed)!
			}
			else {
				s = read_regular(mut f, mut parsed, resolved)!
			}
		}
		read += s
		if read >= ilst_size {
			break
		}
		f.seek(4, .current) or {
			panic(err)
		}
	}
	return parsed
}