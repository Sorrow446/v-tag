module id3

pub struct ID3Cover {
pub mut:
	description  string
	picture_type string
	mime_type    string
	picture_data []u8
}

struct ID3Meta {
pub:
	album           string
	album_artist    string
	artist          string
	composer        string
	conductor       string
	content_group   string
	copyright       string
	comment         string
	date            string
	encoded_by      string
	publisher       string
	isrc            string
	www             string
	title           string
	unsynced_lyrics string
pub mut:
	covers       []&ID3Cover
	custom       map[string]string
	disk_number  int
	disk_total   int
	track_number int
	track_total  int
	genre        string
	year         int
	bpm          int
	has_covers   bool
	compilation  bool
}
