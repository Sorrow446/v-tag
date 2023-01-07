# v-tag
Audio tag library written in V.


## Contributors
It's stable and tested, but currently only supports reading FLAC & ID3.
This is a solo project, so any contributors to help improve or implement read and write support for other formats would be appreciated. 

## Setup
`v install Sorrow446.vtag`
```v
import sorrow446.vtag
```

## Supported
|Format|Info|
| --- | --- |
|FLAC|read only
|MP3|ID3v2.3 - read only

## Examples
#### Read album title
```v
	tags := vtag.read_flac('1.flac') or {
		panic(err)
	}
	println(tags.album)
```
#### Extract all covers and save them locally
```v
	tags := vtag.read_id3('1.mp3') or {
		panic(err)
	}
	if tags.has_covers {
		for idx, cover in tags.covers {
			os.write_file_array("${idx+1}.jpg", cover.picture_data) or {
				panic(err)
			}
		}
	}
```

## Structs
#### FLAC
```v
pub struct FLACMeta {
	pub:
		album string
		album_artist string
		artist string
		comment string
		contact string
		date string
		encoder string
		isrc string
		lyrics string
		media_type string
		performer string
		publisher string
		title string
	pub mut:
		compilation int
		covers []FLACCover
		custom map[string]string
		disk_number int
		disk_total int
		explicit int
		has_covers bool
		itunes_advisory int
		length int
		track_number int
		track_total int
		year int
}

pub struct FLACCover {
	pub:
		colour_depth int
		description string
		height int
		mime_type string
		picture_type string
		width int
	pub mut:
		picture_data []u8
}
```
#### ID3
```v
struct ID3Meta {
	pub:
		album string
		album_artist string
		artist string
		composer string
		conductor string
		content_group string
		copyright string
		comment string
		date string
		encoded_by string
		publisher string
		isrc string
		www string
		title string
		unsynced_lyrics string	
	pub mut:
		covers []&ID3Cover
		custom map[string]string
		disk_number int
		disk_total int
		track_number int
		track_total int
		genre string
		year int
		bpm int
		has_covers bool
		compilation bool
}

pub struct ID3Cover {
	pub mut:
		description string
		picture_type string
		mime_type string
		picture_data []u8
}
```
