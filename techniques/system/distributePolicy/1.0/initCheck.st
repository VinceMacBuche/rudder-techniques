#####################################################################################
# Copyright 2011 Normation SAS
#####################################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, Version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#####################################################################################

bundle agent root_init_check() {

	vars:

		"service[1][binary]" string => "/opt/rudder/libexec/slapd";
		"service[1][initscript]" string => "slapd";

		"service[2][binary]" string => ".*java.*/opt/rudder/jetty7/start.jar";
		"service[2][initscript]" string => "jetty";

		"service[3][binary]" string => "postgres: writer process";
		"service[3][initscript]" string => "postgresql";

		"service[5][binary]" string => "apache2";
		"service[5][initscript]" string => "apache2";

		"index" slist => getindices("service");

	methods:

		"any" usebundle => generic_process_check_process("$(service[$(index)][binary])", "$(service[$(index)][initscript])", "false");
		"any" usebundle => generic_process_check_bootstart("$(service[$(index)][binary])", "$(service[$(index)][initscript])");

}

bundle agent generic_process_check_process(binary, initscript, force_restart) {

	vars:

			"canoname" string => canonify("$(binary)");

	classes:

			"forced_trigger_$(canoname)" expression => strcmp("$(force_restart)", "true");

	processes:

		# check the service status
		"$(binary)"
				comment => "Check the process status",
				restart_class => "process_restart_$(canoname)",
				classes => kept_if_else("service_running_$(canoname)", "service_anomaly_$(canoname)", "service_error_$(canoname)");

	commands:

		"/etc/init.d/$(initscript)"
			args => "restart </dev/null >/dev/null 2>/dev/null",
			contain => in_shell_silent,
			# action => bg("0", "120"),
			classes => kept_if_else("process_restart_ok_$(canoname)", "process_restart_ok_$(canoname)", "process_restart_error_$(canoname)"),
			ifvarclass => "process_restart_$(canoname)|forced_trigger_$(canoname)";

	reports:

	  linux::

		"@@DistributePolicy@@result_success@@&TRACKINGKEY&@@Check $(initscript) process@@None@@$(g.execRun)##$(g.uuid)@#The $(initscript) process is already running"
			ifvarclass => "!process_restart_$(canoname).!forced_trigger_$(canoname)";

		"@@DistributePolicy@@result_repaired@@&TRACKINGKEY&@@Check $(initscript) process@@None@@$(g.execRun)##$(g.uuid)@#The $(initscript) process was not running and has been restarted"
			ifvarclass => "process_restart_$(canoname).process_restart_ok_$(canoname).!forced_trigger_$(canoname)";

		"@@DistributePolicy@@result_repaired@@&TRACKINGKEY&@@Check $(initscript) process@@None@@$(g.execRun)##$(g.uuid)@#The $(initscript) process has been restarted"
			ifvarclass => "process_restart_ok_$(canoname).forced_trigger_$(canoname)";

		"@@DistributePolicy@@result_error@@&TRACKINGKEY&@@Check $(initscript) process@@None@@$(g.execRun)##$(g.uuid)@#The $(initscript) process couldn't be restarted"
			ifvarclass => "process_restart_error_$(canoname)";

}

bundle agent generic_process_check_bootstart(binary, initscript) {

	vars:

			"canoname" string => canonify("$(binary)");

	commands:

	(SuSE|redhat)::

			"/sbin/chkconfig"
				args => "--check $(initscript)",
				classes => if_else("service_bootstarted_$(canoname)", "service_unbootstarted_$(canoname)"),
				comment => "Check if the service $(initscript) is started on boot";

			"/sbin/insserv"
				args => "-d $(initscript)",
				classes => if_else("service_bootstarted_ok_$(canoname)", "service_bootstarted_fail_$(canoname)"),
				ifvarclass => "service_unbootstarted_$(canoname)",
				comment => "Set the service $(initscript) to start on boot";

	debian::

			"/usr/sbin/update-rc.d $(initscript) remove \&\& /usr/sbin/update-rc.d $(initscript) defaults"
				contain => in_shell,
				classes => if_else("service_bootstarted_ok_$(canoname)", "service_bootstarted_fail_$(canoname)"),
				ifvarclass => "service_unbootstarted_$(canoname)",
				comment => "Set the service $(initscript) to start on boot";

	files:

		debian::

                        "/etc/rc2.d/S.*$(initscript).*"
                                create => "true",
                                action => WarnOnly,
                                classes => if_else("service_bootstarted_$(canoname)", "service_unbootstarted_$(canoname)");

	reports:

	  linux::

		"@@DistributePolicy@@result_success@@&TRACKINGKEY&@@Check $(initscript) boot script@@None@@$(g.execRun)##$(g.uuid)@#$(initscript) is started on boot as required"
			ifvarclass => "service_bootstarted_$(canoname)";

		"@@DistributePolicy@@result_repaired@@&TRACKINGKEY&@@Check $(initscript) boot script@@None@@$(g.execRun)##$(g.uuid)@#$(initscript) has been set to start on boot"
			ifvarclass => "!service_bootstarted_$(canoname).service_bootstarted_ok_$(canoname)";

		"@@DistributePolicy@@result_error@@&TRACKINGKEY&@@Check $(initscript) boot script@@None@@$(g.execRun)##$(g.uuid)@#Could not set $(initscript) to start on boot!"
			ifvarclass => "!service_bootstarted_$(canoname).service_bootstarted_fail_$(canoname)";

}
