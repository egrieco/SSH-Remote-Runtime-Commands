#!/usr/bin/expect

# setup environment variables
set remote_server [lindex $argv 0]
if {$remote_server == ""} {
	puts "No server specified. Exiting..."
	exit
}
set rc_file_path "$env(HOME)/.remote.zshrc"

# start ssh
spawn ssh $remote_server
expect "$remote_server%"

# read rc file and execute its commands in the remote shell
# :TODO: should look for blank or commented lines and skip them
# :TODO: should look for "." or "source" lines which include other files and override those by reading them and sending their content
if {[file readable "$rc_file_path"] == 1} {
	puts "Reading configuration from: $rc_file_path"
	set rc_file [open $rc_file_path r]
	while {[set rc_line [gets $rc_file]] != ""} {
		send "$rc_line\r"
		expect "$remote_server%"
	}
	close $rc_file
} else {
	puts "Cannot read remote RC file: $rc_file_path"
}

# pass control to the user
interact
exit
