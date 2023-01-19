module flac

pub const (
	resolve_field_flac = {
		'album':          'album'
		'albumartist':    'album_artist'
		'artist':         'artist'
		'comment':        'comment'
		'contact':        'contact'
		'copyright':      'copyright'
		'date':           'date'
		'encoder':        'encoder'
		'genre':          'genre'
		'isrc':           'isrc'
		'itunesadvisory': 'itunes_advisory'
		'label':          'label'
		'lyrics':         'lyrics'
		'performer':      'performer'
		'publisher':      'publisher'
		'title':          'title'
	}

	resolve_pic_type_flac = {
		0:  'Other'
		1:  'Icon'
		2:  'Other Icon'
		3:  'Front Cover'
		4:  'Back Cover'
		5:  'Leaflet'
		6:  'Media'
		7:  'Lead Artist'
		8:  'Artist'
		9:  'Conductor'
		10: 'Band'
		11: 'Composer'
		12: 'Lyricist'
		13: 'Recording Location'
		14: 'During Recording'
		15: 'During Performance'
		16: 'Video Capture'
		18: 'Illustration'
		19: 'Band Logotype'
		20: 'Publisher Logotype'
	}
)
