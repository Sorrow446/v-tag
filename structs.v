module vtag

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

pub struct ID3Cover {
	pub mut:
		description string
		picture_type string
		mime_type string
		picture_data []u8
}

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

struct MP4Cover {
	pub mut:
		picture_data []u8
}

struct MP4Meta {
	pub:
		album string
		album_artist string
		album_artist_sort string
		album_sort string
		artist string
		artist_sort string
		comment string
		composer string
		composer_sort string
		conductor string
		copyright string
		description string
		encoder string
		narrator string
		owner string
		publisher string
		title string
		title_sort string
		tv_episode string
		tv_show_sort string
		unsynced_lyrics string
	pub mut:
		bpm int
		compilation bool
		covers []&MP4Cover
		custom map[string]string
		date string
		disk_number int
		disk_total int
		genre string
		has_covers bool
		itunes_advisory int
		track_number int
		track_total int
		year int
}