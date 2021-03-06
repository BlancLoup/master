#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use utf8;


#Connect to DB 152
my $mysql_host = "10.200.80.152";
my $mysql_user = "nemesis";
my $mysql_pass = "sqlsql";
my $db_name = "cctv";

#Connect to DB 46
my $mysql_host2 = "10.200.82.46";
my $mysql_port2 = "3307";
my $mysql_user2 = "cctv";
my $mysql_pass2 = "sqlsql";
my $db_name2 = "cctv";


my $DBI = "dbi:mysql:$db_name:$mysql_host";
my $connect = DBI->connect($DBI, $mysql_user, $mysql_pass, {
                                                       PrintError => 1, 
                 	                                   mysql_enable_utf8 => 1}) or die ("Cant connect to MySQL serever 21!!!");


my $DBI2 = "dbi:mysql:$db_name2:$mysql_host2:$mysql_port2";
my $connect2 = DBI->connect($DBI2, $mysql_user2, $mysql_pass2, {
                                                        PrintError => 1,
								mysql_enable_utf8 => 1}) or die ("Cant connect to MySQL serever 19!!!");
								
my $sth = $connect->prepare('select id,username from abstract_user');
$sth->execute();

while(my $name = $sth->fetchrow_hashref()) {
	my @all_user_settings = &get_all_user_settings($name->{id},1);
	my $ext_id = &get_user_id($name->{username});
		if (($all_user_settings[0]) && ($ext_id ne "NOT_FOUND")) {
			my @usrset46 = &get_all_user_settings($ext_id,2);
				unless ($usrset46[0]){
					print "Get settings for user: $name->{username} id in 46: $ext_id\n";
					foreach my $line (@all_user_settings) {
					print "Found setting: $line\n";
						my @settings_params = &get_user_setting($line,1);
							foreach my $params (@settings_params) {	
								my @par = split(/\;/, $params);
								print "Migrate user setting for user $name->{username} param $par[3]\n";
								$connect2->do("insert into user_settings (version,
																			name,
																			user_id,
																			user_value) values (0,
																								'$par[1]',
																								'$ext_id',
																								'$par[3]')");
							}
					}
				}
		}
}

$sth->finish();

$connect->disconnect;
$connect2->disconnect;

exit 0;	

sub get_user_setting {
	my $id = $_[0];
	my $db = $_[1];
	my @result;
	my $line;
	my $sth2;
	if ($db == 1) {
		$sth2 = $connect->prepare("select * from user_settings where id = '$id' and name = 'advanced-presets'");
	}
	elsif ($db == 2) {
		$sth2 = $connect2->prepare("select * from user_settings where user_id = '$id' and name = 'advanced-presets'");
	}
	$sth2->execute();
	while ($line = $sth2->fetchrow_hashref()) {
		if ($line->{id}){
			push (@result, "$line->{id};$line->{name};$line->{user_id};$line->{user_value}");
		}
	}
	return @result;
	$sth2->finish();
}

sub get_all_user_settings {
	my $user_id = $_[0];
    my $db = $_[1];
    my @result;
    my $sth3;
        if ($db == 1) {
              $sth3 = $connect->prepare("select id from user_settings where user_id = '$user_id' and name = 'advanced-presets'");
        }
        elsif ($db == 2) {
              $sth3 = $connect2->prepare("select id from user_settings where user_id = '$user_id' and name = 'advanced-presets'");
        }
        if ($sth3) {
        $sth3->execute();
        while (my $line = $sth3->fetchrow_array()) {
        	push (@result, $line);
        }
        return @result;
        $sth3->finish();
        }
        else {return "ERROR\n";}
}

sub get_user_id {
	my $username = $_[0];
	my $sth4;
	my $result;
		$sth4 = $connect2->prepare("select id from abstract_user where username = '$username'");
		$sth4->execute();
		if ($result = $sth4->fetchrow_array()){
			return $result;
		}
		else {
			return "NOT_FOUND";
		}
	$sth4->finish();	
}