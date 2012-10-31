package Homyaki::Task_Manager::Task::Build_Gallery::Image_Processor::Resize_For_HTML;

use strict;

use Imager;

use Homyaki::Imager qw(rotate change_size);
use Homyaki::Logger;

use base 'Homyaki::Task_Manager::Task::Build_Gallery::Image_Processor';

use constant EXIF_GPS_DATA_MAP => {
		GPSLatitude         => 'GPS',
		GPSLatitudeRef      => 'GPS',
		GPSLongitude        => 'GPS',
		GPSLongitudeRef     => 'GPS',
		GPSAltitude         => 'GPS',
		GPSAltitudeRef      => 'GPS',
		GPSMapDatum         => 'GPS',
		GPSImgDirection     => 'GPS',
		GPSImgDirectionRef  => 'GPS',
		GPSDateTime         => 'XMP'
};

sub process {
	my $self = shift;

	my %h = @_;
	my $image       = $h{image};
	my $dest_path   = $h{dest_path};
	my $source_path = $h{source_path};

	my $img = rotate($image);

	Homyaki::Logger::print_log("Build_Gallery: load_images: Change $source_path size:");

	my $thumb = change_size($img, 64);
	
	unless ($thumb->write(file => $dest_path->{thumb})) {
		Homyaki::Logger::print_log("Build_Gallery: load_images: Error: ($dest_path->{thumb})" . $img->errstr());
		print STDERR "$dest_path->{thumb} - ",$img->errstr(),"\n";
	}
	
	my $fullpic = change_size($img, 800);

	if ($fullpic->write(file=>$dest_path->{pic})) {

		my $exif_data = $self->{exif_tool}->ImageInfo($source_path);
		if ($exif_data->{GPSLatitude}) {
			foreach my $gps_key (keys %{&EXIF_GPS_DATA_MAP}) {
				$self->{exif_tool}->SetNewValue($gps_key, $exif_data->{$gps_key}, &EXIF_GPS_DATA_MAP->{$gps_key});
			}
			$self->{exif_tool}->WriteInfo($dest_path->{pic});
		}

	} else {
		Homyaki::Logger::print_log("Build_Gallery: load_images: Error: ($dest_path->{pic})" . $img->errstr());
		print STDERR "$dest_path->{pic} - ",$img->errstr(),"\n";
	}

	

	return $fullpic;
}

1;
