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
# changing this to a simpler pattern to match since a direct hostname match is not possible. Higher level domains are not printed on the host (at least at work).
expect {
	-ex "Are you sure you want to continue connecting (yes/no)?" {send "yes\r"}
	"% "
}

# read rc file and execute its commands in the remote shell
# :TODO: should look for "." or "source" lines which include other files and override those by reading them and sending their content
# :TODO: should hide the output from ssh for cosmetic reasons. "log_user 0" and "stty -echo" do not seem to be the answer
if {[file readable "$rc_file_path"] == 1} {
	puts "Reading configuration from: $rc_file_path"

	# read file
	set rc_file [open $rc_file_path r]
	set rc_file_data [read $rc_file]
	close $rc_file

	# iterate over file
	set rc_lines [split $rc_file_data "\n"]
	foreach rc_line $rc_lines {
		if [regexp {^\s*$} $rc_line] {continue}
		if [regexp {^\s*#} $rc_line] {continue}
		send "[string trim $rc_line]\r"
	}
	# this is a temporary workaround until we can properly hide send data and output from ssh
	send "clear\r"
} else {
	puts "Cannot read remote RC file: $rc_file_path"
}

# pass control to the user
interact
exit
