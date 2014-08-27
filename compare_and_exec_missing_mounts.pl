#!/usr/bin/perl 

use strict;
use warnings;

die "\t Usage:> ./$0 <Hosts List for Env1> <Hosts List for Env2> \n\n" if ($#ARGV < 1);
my $FILENAME1 = $ARGV[0];
my $FILENAME2 = $ARGV[1];

my @array1 = ();
my @array2 = ();
my @missing_hosts = ();
my @missing_mount = ();
#my $headless_account_rsakey = "/home/sandeep/conf/psi_qa_regr_keys/keys/sandeep_id_rsa";
my $headless_account_rsakey = "/home/rsandeep/.ssh/id_rsa";

open (FILE1, "< $FILENAME1");
@array1=<FILE1>;
close(FILE1);
my $count1 = scalar(@array1);

open (FILE2, "< $FILENAME2");
@array2=<FILE2>;
close(FILE2);
my $count2 = scalar(@array2);

die "\t Number of Hosts in list $FILENAME1 is not equal to $FILENAME2 $count1 <> $count2 \n\n" if ($count1 ne $count2);

sub validate_hosts
{
	my ($host1, $host2) = @_; 
	chomp($host1);
	chomp($host2);
	my @host_keyswords = ("api", "auth", "batch", "bs", "csr", "fz", "iapp", "logs", "msft", "pg", "proxy", "report", "restapi", "selfcare", "ssn", "ws", "wyc", "ymon", "ycpbe");

	foreach my $pattern ( @host_keyswords )
	{
		chomp($pattern);
		#my $mat1 = ($host1 =~ m/$pattern/);
		#my $mat2 = ($host2 =~ m/$pattern/);
		#print "mat1=$mat1| and mat2=$mat2| \n"; 
		if ( (( $host1 =~ m/$pattern/) == 1) && (( $host2 =~ m/$pattern/) == 1) )
		{
			#print "FOUND THE MATCH \n ";
			return "TRUE";
		}
		else 
		{
			next;	
		}
	}
}
		


sub compare_mount
{

	my @arr1 = @{$_[0]};
	my @arr2 = @{$_[1]};
	my $host1 = undef;
	my $host2 = undef;
	my $comparing = "COMPARING ";
	my $entry_no = undef;
#my $i = 0;
	my $entry = undef;
	my $mount_status = "MOUNT_STATUS";
	my $status_of_host1 = undef;
	my $status_of_host2 = undef;
	my $issue = "ISSUE";
	my $details = undef;
	my $mount = "MOUNT";
	my $new_line = undef;

	open (MOUNT_FORMAT, "> COMPARISION_MOUNT_REPORT.txt");
	#open(STDERR, '>&', STDOUT) or die "Can't redirect stderr: $!";
	#open(STDERR, '>', 'STDOUT_STDERR.txt') or die "Can't redirect stderr: $!";
	print " HOST LIST1 <=> @arr1 \n HOST LIST2 <=> @arr2 \n ";
	open (FILE, "> MOUNT_REPORT.txt");
	open (TOBEMOUNTED, "> TO_BE_MOUNTED_REPORT.txt");
	select(STDOUT);
	$~ = "MOUNT_FORMAT";
	

	for(my $i=0;$i<scalar(@arr1);$i++)
	{
		$host1 = $arr1[$i];	
		chomp($host1); 
		$host1 =~ s/^\s+//g;
		$host1 =~ s/\s+$//g;
		
		$host2 = $arr2[$i];	
		chomp($host2);
		$host2 =~ s/^\s+//g;
		$host2 =~ s/\s+$//g;

		my $result = validate_hosts($host1,$host2);
		#print "\n RESULT= $result \n";
		if ($result eq "TRUE" )
		{
			print "HOSTS $host1 and $host2 names are similar \n\n";
			#print MOUNT_FORMAT "$host1 and $host2 names are similar \n\n";
		}
		else 
		{
			print "HOSTS $host1 and $host2 names are not similar hence not comparing\n\n";
			print MOUNT_FORMAT "$host1 and $host2 names are not similar hence not comparing\n\n";
			next;
		}
	
		#my $cmd_host1 = "ssh -i /home/sandeep/conf/psi_qa_regr_keys/keys/sandeep_id_rsa -o StrictHostKeychecking=no $host1 \"/home/sandeep app --cmd mount \"";
		# Change the below if you dont have env 
		#my $cmd_host1 = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host1 mount";
		my $cmd_host1 = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host1 mount;
		print FILE "MOUNT OF HOST1: [$host1]\n";
		my @args_host1 = ($cmd_host1, 'tee -a MOUNT_REPORT.txt');
		my @stdout_host1 = exec_cmd( @args_host1 );
		print FILE @stdout_host1;
		print FILE "\n";
		
		#my $cmd_host2 = "ssh -i /home/sandeep/conf/psi_qa_regr_keys/keys/sandeep_id_rsa -o StrictHostKeychecking=no $host2 \"/home/sandeep app --cmd mount \"";
		my $cmd_host2 = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host2 mount";
		print FILE "MOUNT OF HOST2: [$host2]\n";
		my @args_host2 = ($cmd_host2, 'tee -a MOUNT_REPORT.txt');
		my @stdout_host2 = exec_cmd( @args_host2 );
		print FILE @stdout_host2;
		print FILE "\n";
		
### TEST Command

		my $cmd = "diff \<\(ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host1  mount \) \<\(ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host2 mount\)";

		print "ENTRY $i/$count1 CMD = $cmd \n\n";

#system($cmd);
		my @args = ($cmd, 'tee -a MOUNT_REPORT.txt');
#print "COMMAND ARRAY @args \n";
#exit;
		print FILE "COMPARING MOUNT OF $host1\t<=>\t$host2\n";
		my @stdout = exec_cmd( @args );
		print FILE "\t MOUNT on $host1 and $host2 are SAME \n\n" if (!@stdout);
		print "\t MOUNT on $host1 and $host2 are SAME \n\n" if (!@stdout);
#print FILE join( "\n", @stdout );
#print "OUTPUT @stdout \n";
		my $host2_new = $host2;
		$host1 = "HOST1[". $host1 . "]";
		$host2 = "HOST2[". $host2 . "]";

		foreach my $line ( @stdout )
		{
			#next if ( $line =~ /(\/dev|\/proc|\/sys|^\d*|^-*)/g );
			next if ( $line =~ /\/dev|\/proc|\/sys|^-/g );
			$entry_no = "ENTRY" . $i;
			$entry = $comparing . $entry_no;
			if ( $line =~ m/^</ )
			{
				$line =~ s/^<//g;
				$line =~ s/\n//g;
				print FILE "\t$host2 Mount $line is Missing \n";
				$status_of_host1 = "PRESENT";
				$status_of_host2 = "MISSING";
				$details = "Mount $entry_no missing on HOST2";
				print TOBEMOUNTED "$host2\t $line\n";
				push (@missing_hosts, $host2_new);
				push (@missing_mount, $line);
			}
			elsif ( $line =~ m/^>/ )
			{
				$line =~ s/^>//g;
				$line =~ s/\n//g;
				print FILE "\t$host1 Mount $line is missing \n";
				$status_of_host1 = "MISSING";
				$status_of_host2 = "PRESENT";
				$details = "Mount $entry_no missing on HOST1";
			} 
			else 
			{
				#$line = ''; 
				#print FILE "\t Mount on $host1 and $host2 are same \n";
				next;
			}
			#print FILE "---------------------------------------------------------------------------------------------------------\n";
			$new_line = $line;
			write();
			write(MOUNT_FORMAT);
		}	

#print join( "|||||", @stdout );
	}
#print join( "\n", @stdout );
	close(FILE);
	close(MOUNT_FORMAT);
	close(TOBEMOUNTED);
	#close(STDERR);

format MOUNT_FORMAT =
@<<<<<<<<<<<<<<<<: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$entry,            $host1,                               	            $host2
@<<<<<<<<<<<<<<<<: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$mount_status,     $status_of_host1,                                        $status_of_host2
@<<<<<<<<<<<<<<<<: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$issue,            $details
@<<<<<<<<<<<<<<<<: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$mount,            $new_line
===========================================================================================================================================================================
.

}

sub exec_cmd
{
	my $cmd_str;
	#$cmd_str =  join( ' | ', @_ );
	if (scalar(@_) > 1)
	{
		$cmd_str =  join( ' | ', @_ );
	}
	else 
	{
		$cmd_str = @_;
	}
	#print "CMD STR $cmd_str \n";
	my @result = qx( bash -c '$cmd_str' );
	#print "Exe Command Array @result \n";
	#die "Failed to exec $cmd_str: $!" unless( $? == 0 && @result );
	return @result;
}

sub system_cmd
{

	my $cmd = shift;

	print "\t$cmd\n";
	my $returnCode = system($cmd);
	
	if ( $returnCode != 0 ) 
	{ 
		print "\tFailed executing [$cmd]\n"; 
		return "TRUE";
	}
	else
	{
		print "\tExecuted Successfully [$cmd]\n";
		return "FALSE";
	}
}

sub exec_mount
{
	for (my $i=0;$i<scalar(@missing_mount);$i++)
	{
		my $host = $missing_hosts[$i];
		my $line = $missing_mount[$i];
		print "LINE $line  \n";
		$line =~ s/\(|\)//g;
		$line =~ s/on//g;
		$line =~ s/type//g;
		my @arr = split(' ', $line);
		#print "ARRAY  = @arr \n";
		
		### Append the lines to /etc/fstab
		#my $app_cmd = "ssh -i /home/sandeep/conf/psi_qa_regr_keys/keys/sandeep_id_rsa -o StrictHostKeychecking=no $host \"/home/sandeep app --cmd \'echo $arr[0] $arr[1] >> /etc/fstab\'\"";
		my $app_cmd = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host \"/home/sandeep app --cmd \'echo $arr[0] $arr[1] >> /home/sandeep/a.txt\'\"";
		print "[APPENDING] the mount entries to /etc/fstab \n";
		system_cmd($app_cmd);

		### Exec the mount
		my $cmd = "\'mount $arr[1]\'";
		#my $mnt_cmd = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host \"/home/sandeep app --cmd \'mount $arr[1]\'\"";
		my $mnt_cmd = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host \"/home/sandeep app --cmd $cmd\"";
		print "[MOUNTING] the filesystem \n";
		#system_cmd($mnt_cmd);
		my @output =  `$mnt_cmd`;
	
		### Create a test file on the mount	
		my $touch_cmd = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host \"/home/sandeep app --cmd \'touch -a $arr[1]/mount_test.txt\'\"";
				print "[CREATING] the file mount_test.txt on [MOUNT]$arr[1]\n";
		system_cmd($touch_cmd);
		
		### Remove the test file
		my $rm_cmd = "ssh -i $headless_account_rsakey -o StrictHostKeychecking=no $host \"/home/sandeep app --cmd \'rm /home/sandeep/mount_test.txt\'\"";
		print "[REMOVING] the file mount_test.txt from [MOUNT]$arr[1]\n";
		system_cmd($rm_cmd);
		
	}
	
}


#MAIN
{

	compare_mount( \@array1, \@array2 );
	exec_mount();

}
