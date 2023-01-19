module main

import flac
import id3
import mp4

fn main() {
	flac_tags := flac.read('1.flac') or {
		panic(err)
	}
	println(flac_tags.album)

	mp4_tags := mp4.read('1.m4a') or { panic(err) }
	println(mp4_tags.album)

	id3_tags := id3.read('1.mp3') or { panic(err) }

	println(id3_tags.album)
}
