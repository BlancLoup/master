#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use utf8;

my $mysql_host = "10.200.80.152";
my $mysql_user = "nemesis";
my $mysql_pass = "sqlsql";
my $db_name = "cctv";
#my $file = "./all_camera_id_18_02_2013.txt";


my $mysql_host2 = "10.200.82.46";
my $mysql_port2 = "3307";
my $mysql_user2 = "cctv";
my $mysql_pass2 = "sqlsql";
my $db_name2 = "cctv";


my $DBI = "dbi:mysql:$db_name:$mysql_host";
my $connect = DBI->connect($DBI, $mysql_user, $mysql_pass, {
                                                       PrintError => 1, 
                 	                                   mysql_enable_utf8 => 1}) or die ("Cant connect to MySQL serever 21!!!");

#open(LOOP,"<$file");
#	my @id = <LOOP>;
#close(LOOP);

#my @arr = split /\,/, $id[0];

my $DBI2 = "dbi:mysql:$db_name2:$mysql_host2:$mysql_port2";
my $connect2 = DBI->connect($DBI2, $mysql_user2, $mysql_pass2, {
                                                        PrintError => 1,
								mysql_enable_utf8 => 1}) or die ("Cant connect to MySQL serever 19!!!");
my @array1;
my @array2;
my $result;
my $result2;
my $sth = $connect->prepare('select id from abstract_user');
$sth->execute();
my $sth2;
my $sth3;
my $sth4;

while(my $id = $sth->fetchrow_array()) {

#foreach my $id (@arr){
#	unless ($id eq "\n") {
		$id =~ s/^\s+//;
        	$id =~ s/\s+$//;
#		$sth = $connect->prepare("select echd_id from camera where echd_id is not NULL");
#		$sth2 = $connect2->prepare("select id,echd_id from camera where echd_id = '$id'");
#		$sth = $connect->prepare('select distinct(object_id) from notify_event');
#		$sth->execute();
#		$sth2->execute();
	print "Get settings for user id: $id\n";
	my $all_user_settings = &get_all_user_settings($id,1);

		while (my $settings = $all_user_settings->fetchrow_array()) {

#		$connect->do("UPDATE camera SET hidden = 'TRUE' WHERE echd_id = '$line'");
#		while ($result = $sth->fetchrow_hashref()) {

			print "Found setting: $settings\n";
			print "params:\n";
				my $settings_params = &get_user_setting($settings,1);
					foreach my $key (keys($settings_params)) {

						print "$settings_params->{$key}\n";



					}
                                     #   unless ($result->{echd_id} eq $id) { print "$id\n"; }
#					print "$result->{short_name}, $result->{address}, http://195.208.65.189:2020/$result->{ip}/$result->{url}/12345/0\n";
#					print "$result->{id}\n";
#					print "$result->{echd_id}\n";
#			 		print "$result->{name}\n";
#					print "$result->{hidden}\n";
#					print "$result->{archive_ip}\n";
#					print "$result->{archive_url}\n";
#					print "$result->{archive_ip}\n";
#					print "$result->{archive_url}\n";
#					$connect->do("UPDATE camera SET hidden = false WHERE echd_id = '$result->{echd_id}'");
#					$connect2->do("UPDATE camera SET hidden = false WHERE echd_id = '$result->{echd_id}'");

#					$connect2->do("UPDATE camera SET ip = '$result->{ip}', url = '$result->{url}', archive_ip = '$result->{archive_ip}', archive_url = '$result->{archive_url}' WHERE echd_id = '$result->{echd_id}'");

#					$connect2->do("UPDATE camera_url SET host = '$result->{ip}', path = '/$result->{url}', url = 'bwims://$result->{ip}/$result->{url}' WHERE camera_id = '$result->{id}' and type = 1");

#					$connect2->do("UPDATE camera_url SET host = '$result->{archive_ip}', path = '/$result->{archive_url}', url = 'bwims://$result->{archive_ip}/$result->{archive_url}' WHERE camera_id = '$result->{id}' and type = 2");
#					print "UPDATED!\n";
#					$connect->do("UPDATE camera SET channel_id = '$id' WHERE echd_id = '$line'");


#	my $sth2 = $connect->prepare("SELECT id FROM camera WHERE echd_id = '$result->{echd_id}'");
#	$sth2->execute();
#	my $asset_id = $sth2->fetchrow_array();
#	unless($asset_id){print "$result->{echd_id}\n";}
	
#		$connect->do("UPDATE camera SET asset_id = '$asset_id' WHERE echd_id = '$id'");
#		print "$id - $asset_id\n";
			

#		}

	}
#}

}

$sth->finish();
$sth2->finish();

$connect2->disconnect;
$connect2->disconnect;

exit 0;	

sub get_user_setting {
	my $setting_id = $_[0];
	my $db = $_[1];
	if ($db == 1) {
		my $sth3 = $connect->prepare("select * from user_settings where id = '$setting_id'");
	}
	elsif ($db == 2) {
		my $sth3 = $connect2->prepare("select * from user_settings where id = '$setting_id'");
	}
	$sth->execute();
	return $sth3;
}

sub get_all_user_settings {
	my $user_id = $_[0];
        my $db = $_[1];
        if ($db == 1) {
              my  $sth4 = $connect->prepare("select id from user_settings where user_id = '$user_id'");
        }
        elsif ($db == 2) {
              my  $sth4 = $connect2->prepare("select id from user_settings where user_id = '$user_id'");
        }
        $sth->execute();
        return $sth4;
}