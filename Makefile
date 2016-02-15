#####################################################################################
# Copyright 2016 Normation SAS
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

WGET := $(if $(PROXY), http_proxy=$(PROXY) ftp_proxy=$(PROXY)) /usr/bin/wget -q

all: rudder-templates-cli.jar
	cp techniques/system/common/1.0/rudder-stdlib.cf initial-promises/node-server/common/1.0/
	java -jar rudder-templates-cli.jar --outext .cf --outdir initial-promises/node-server/common/1.0/ techniques/system/common/1.0/rudder-stdlib-core.st

rudder-templates-cli.jar:
	$(WGET) -O rudder-templates-cli.jar http://www.normation.com/tarball/rudder-templates-cli/rudder-templates-cli.jar
