module mp4

struct MP4Cover {
pub mut:
	picture_data []u8
}

struct MP4Meta {
pub:
	album             string
	album_artist      string
	album_artist_sort string
	album_sort        string
	artist            string
	artist_sort       string
	comment           string
	composer          string
	composer_sort     string
	conductor         string
	copyright         string
	description       string
	encoder           string
	narrator          string
	owner             string
	publisher         string
	title             string
	title_sort        string
	tv_episode        string
	tv_show_sort      string
	unsynced_lyrics   string
pub mut:
	bpm             int
	compilation     bool
	covers          []&MP4Cover
	custom          map[string]string
	date            string
	disk_number     int
	disk_total      int
	genre           string
	has_covers      bool
	itunes_advisory int
	track_number    int
	track_total     int
	year            int
}
