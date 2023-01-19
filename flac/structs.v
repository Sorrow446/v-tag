module flac

pub struct FLACCover {
pub:
	colour_depth int
	description  string
	height       int
	mime_type    string
	picture_type string
	width        int
pub mut:
	picture_data []u8
}

pub struct FLACMeta {
pub:
	album        string
	album_artist string
	artist       string
	comment      string
	contact      string
	date         string
	encoder      string
	isrc         string
	lyrics       string
	media_type   string
	performer    string
	publisher    string
	title        string
pub mut:
	compilation     int
	covers          []FLACCover
	custom          map[string]string
	disk_number     int
	disk_total      int
	explicit        int
	has_covers      bool
	itunes_advisory int
	length          int
	track_number    int
	track_total     int
	year            int
}
