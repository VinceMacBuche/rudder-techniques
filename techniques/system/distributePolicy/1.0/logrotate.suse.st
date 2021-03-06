/var/log/rudder/apache2/*.log {
        daily
        missingok
        rotate 30
        compress
		notifempty
		create 640 root root
        sharedscripts
        postrotate
			/etc/init.d/apache2 reload > /dev/null
		endscript
}

/var/log/rudder/ldap/slapd.log {
        daily
        missingok
        rotate 30
        compress
        notifempty
		create 640 root root
}

/var/log/rudder/reports/*.log {
        daily
        missingok
        rotate 30
        compress
        notifempty
		create 640 root root
}

/var/log/rudder/core/*.log {
        daily
        missingok
        rotate 30
        compress
        notifempty
        create 640 root root
}

/var/log/rudder/compliance/non-compliant-reports.log {
        daily
        missingok
        rotate 365
        compress
        notifempty
        create 640 root root
}