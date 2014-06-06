#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Cache::Memcached;
use XML::Simple;
use HTTP::Cookies;
use LWP::UserAgent;
use utf8;


my $flush = grep $_ eq "--flush", @ARGV;
if (my ($file) = grep $_ =~ /--idfile/, @ARGV) {

my @idfile = split(/\=/,$file);

print "$idfile[1]\n";

}
else { print "ID File not found exit!\n"; exit 0; }

my $memd = new Cache::Memcached {
    'servers' => ["127.0.0.1:11211"],
    'debug' => 1,
    'compress_threshold' => 10_000,
};


my $mysql_host = "10.200.80.152";
my $mysql_user = "nemesis";
my $mysql_pass = "sqlsql";
my $db_name = "cctv";

my $DBI = "dbi:mysql:$db_name:$mysql_host";
my $connect = DBI->connect($DBI, $mysql_user, $mysql_pass, {
                                                        PrintError => 0,
                    	                                   mysql_enable_utf8 => 1}) or die ("Cant connect to MySQL serever 21!!!");

open(LOOP,"<$idfile[1]");
	my @id = <LOOP>;
close(LOOP);

my $camera;
my $camera_groups;
my $sth;

print "|---------------------------------------------------|\n";
foreach my $id (@id){
	unless ($id eq "\n") {
		$id =~ s/^\s+//;
        	$id =~ s/\s+$//;
		$camera = &get_step_data

		while ($result = $sth->fetchrow_hashref()) {
					print "|  (DB_152) --> $result->{id}  -  ";
					print "$result->{short_name}  -  ";
			 		print "$result->{echd_id}\n";
					print "|---------------------------------------------------|\n";
					my $check = &check_camera($result->{echd_id});
						if ($check eq 0) {
							my $camuser = &get_user($result->{user_id},0);
		                                        my @splituser = split(/\;/,$camuser);
		                                        my @camgroup = &get_camera_groups($result->{id},0);

							print "|  (DB_ECHD_MOS_RU) Camera $result->{echd_id} not found\n";
							print "|  START SYNC CAMERA:\n";
							print "|  Insert data to DB...\n";
							print "|  Create camera user in db ...";
						
									
								$connect->do("INSERT INTO user (
										version,
										login,
										password) values ('0',
												'$splituser[1]',
												'$splituser[2]')");

					
							
								my $check_user = &get_user(0,1);
								my @checkuser = split (/\;/,$check_user);
								print " OK userid $checkuser[0]\n";
							
							print "|  Create camera in DB ...";
						
						
								$connect->do("INSERT INTO camera (version,
												   address,
											       	   api_type,
												   archive_id,
												   archive_url,
												   camera_type_id,
												   channel_id,
												   cisco_vsm2istream_params,
												   cisco_vsm_api_params,
												   create_date,
												   date_created,
												   district_id,
												   echd_id,
												   fixed,
												   has_archive,
												   ip,
												   last_change,
												   last_updated,
												   lat,
												   lng,
												   name,
												   short_name,
												   url,
												   user_id,
												   vsm_key,
												   echd_camera_state,
												   archive_ip,
												   stream_priority,
												   has_pvr_archive,
												   updating) values (
												'$result->{version}',
												'$result->{address}',
												'$result->{api_type}',
												'$result->{archive_id}',
												'$result->{archive_url}',
												'$result->{camera_type_id}',
												'$result->{channel_id}',
												'$result->{cisco_vsm2istream_params}',
												'$result->{cisco_vsm_api_params}',
												'$result->{create_date}',
												'$result->{date_created}',
												'$result->{district_id}',
												'$result->{echd_id}',
												'$result->{fixed}',
												TRUE,
												'$result->{ip}',
												'$result->{last_change}',
												'$result->{last_updated}',
												'$result->{lat}',
												'$result->{lng}',
												'$result->{name}',
												'$result->{short_name}',
												'$result->{url}',
												'$checkuser[0]',
												'$result->{vsm_key}',
												'$result->{echd_camera_state}',
												'$result->{archive_ip}',
												'$result->{stream_priority}',
												FALSE,
												'$result->{updating}')");
							
									
								my $check_new_cam = &check_camera($result->{echd_id});
		                                                if ($check_new_cam eq 0) {
									print "FAILED CREATE CAMERA!!!\n";
								}
								else {
									print "OK created camera id $check_new_cam\n";
									print "|  Create camera url's for camera id $check_new_cam...\n";
									print "|   Create live url...";	
									$connect->do("INSERT INTO camera_url (camera_id,
														host,
														path,
														port,
														protocol,
														type,
														url,
														direct) values (
														'$check_new_cam',
														'$result->{ip}',
														'/$result->{url}',
														'-1',
														'bwims',
														'1',
														'bwims://$result->{ip}/$result->{url}',
														FALSE)");
									print "OK!\n";
									print "|   Create archive url...";
									$connect->do("INSERT INTO camera_url (camera_id,
                                                                                                                host,
                                                                                                                path,
                                                                                                                port,
                                                                                                                protocol,
                                                                                                                type,
                                                                                                                url,
														direct) values (
                                                                                                                '$check_new_cam',
                                                                                                                '$result->{archive_ip}',
                                                                                                                '/$result->{archive_url}',
                                                                                                                '-1',
                                                                                                                'bwims',
                                                                                                                '2',
                                                                                                                'bwims://$result->{archive_ip}/$result->{archive_url}',
														FALSE)");
									print "OK!\n";
									print "|  Url's created!\n";
									print "|  Add camera to groups...\n";
										foreach my $group (@camgroup) {
											print "|   Add to group $group\n";
										$connect->do("INSERT INTO echd_camera_group_camera (camera_id,group_id) values ('$check_new_cam','$group')");
										}
								}
						print "|  END MIGRATE CAMERA $check_new_cam\n";


						}
						else {
							print "|  (DB_ECHD_MOS_RU) Camera found, id = $check\n";
							print "|  Check camera group on camera $check...\n";
							my @group_check = &get_camera_groups($check,1);
							if ($group_check[0]) {
								foreach my $gp (@group_check) {
									print "|   Group $gp found\n";
								}
							}
							else {
								print "|  Group on camera $check not found, SYNC camera group...";
								foreach my $gp (@group_check) {
									$connect->do("INSERT INTO echd_camera_group_camera (camera_id,group_id) values ('$check','$gp')");
								}
								print "OK!\n";
							}

						}
					print "|---------------------------------------------------|\n";

		}

	}
}

if ($flush == 1) {
	print "|| FLUSH AGREGATION \n";
	my $table;
	my $switch;
	my $arg = $connect->prepare("SELECT s_value FROM persistent_setting WHERE name = 'CAMERA_AGGREGATE_BUFFER'");
	$arg->execute();
	my $status = $arg->fetchrow_array();
	if ($status eq "SECONDARY") {
		$table = "agregate_map";
		$switch = "PRIMARY";
	}
	elsif ($status eq "PRIMARY") {
		$table = "aggregate_map_secondary";
		$switch = "SECONDARY";
	}
	print "|| Truncate table $table...";
	$connect->do("truncate table $table");
	print "OK!\n";
	print "|| CALCULATE AGREGATION...";
	$connect->do("INSERT INTO $table (camera_id, zoom, x, y, lng, lat, tile_x, tile_y) select 
        											c.id, 
        											o.zoom,
        											c.lng * 1000000 div o.w,     
        											c.lat * 1000000 div o.h,
        											c.lng * 1000000,
        											c.lat * 1000000,
        											(c.lng * 1000000) div (o.w * o.tileH),     
        											(c.lat * 1000000) div (o.h * o.tileW) 
							from camera c, agregate_option o where c.lat is not null and c.lng is not null");
	print "DONE!\n";
	print "|| Change AGREGATION BUFFER to $switch...";
	$connect->do("UPDATE persistent_setting SET s_value = '$switch'  WHERE name = 'CAMERA_AGGREGATE_BUFFER'");
	print "DONE!\n";
}

$sth->finish();
$connect->disconnect;

exit 0;	


sub check_camera {
	my $echd_id = $_[0];
	$sth = $connect->prepare("SELECT id FROM camera WHERE echd_id = '$echd_id'");
	$sth->execute();
	my $camera_id = $sth->fetchrow_array();
	unless($camera_id){ return "0"; }
	else {return $camera_id; }
}

sub get_camera_groups {
	my $camera_id = $_[0];
	$sth = $connect->prepare("SELECT group_id FROM echd_camera_group_camera WHERE camera_id = '$camera_id'");
	$sth->execute();
	my @groups;
	while (my $group_id = $sth->fetchrow_array()) {
		push(@groups, $group_id);
	}
	return @groups;
}

sub check_url {
	my $type = $_[0];
	my $id = $_[1];
	if ($type eq "live") {
		$sth = $connect->prepare("SELECT id FROM camera_url WHERE camera_id = '$id' and type = 1");
	}
	elsif ($type eq "archive") {
       		$sth = $connect->prepare("SELECT id FROM camera_url WHERE camera_id = '$id' and type = 2");
	}
	$sth->execute();
	my $camera_url = $sth->fetchrow_array();
	unless($camera_url){ return "0"; }
        else {return $camera_url; }
}

sub get_user {
	$sth = $connect->prepare("SELECT * FROM user ORDER BY id DESC LIMIT 1");
	$sth->execute();
	my $user = $sth->fetchrow_hashref();
	return "$user->{id};$user->{login};$user->{password}";
}

sub get_step_data {
	my $cam_echd_id = $_[0];
	my $type = $_[1];
	my $uri = "http://10.200.80.6:84/CameraWcf.svc";
	my $get = new LWP::UserAgent;
	$get->cookie_jar(HTTP::Cookies->new());
	push @{$get->requests_redirectable}, 'POST';
	my $request = '
		<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
		   <soapenv:Header/>
		   <soapenv:Body>
		      <tem:'.$type.'>
		         <!--Optional:-->
		         <tem:cameraId>'.$cam_echd_id.'</tem:cameraId>
		      </tem:'.$type.'>
		   </soapenv:Body>
		</soapenv:Envelope>
	';

	my $header = new HTTP::Headers (
	        'Content-Type'   => 'text/xml; charset=utf-8',
	        'User-Agent'     => 'Perl SOAP 0.1',
	        'SOAPAction'     =>  "http://tempuri.org/ICameraWcf/$type",
	);

	my $req = new HTTP::Request('POST',$uri,$header,$request);
	my $res = $get->request($req);
	my $response = $res->content;
	my $parcer = new XML::Simple;
	my $body = $parcer->XMLin($response);
	return $body;
}