#!/usr/bin/env python
#
# Copyright (C) 2013 Chris McClelland
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
import json, base64, httplib, codecs, sys
from os.path import expanduser

sys.stdout = codecs.getwriter('utf-8')(sys.stdout)

def getCredentials():
    home = expanduser("~")
    with open(home + "/.netrc") as nrcFile:
        for line in nrcFile:
            tokens = line.split()
            if ( tokens[0] != "machine" or tokens[2] != "login" or tokens[4] != "password" ):
                raise SyntaxError("The .netrc file is badly formatted")
            elif ( tokens[1] == "api.github.com" ):
                return (tokens[3], tokens[5])
        raise LookupError("Cannot find an entry for api.github.com in .netrc")

(user, password) = getCredentials()
credentials = base64.encodestring("%s:%s" % (user, password)).replace("\n", "")
headers = {"Authorization": "Basic %s" % credentials, "User-Agent": user}
conn = httplib.HTTPSConnection("api.github.com")

def filterDesc(repoList, prefix):
    for repo in repoList:
        description = repo["description"]
        if ( description.startswith(prefix) ):
            fullName = repo["full_name"]
            print "  " + fullName + ": " + description[4:]
            conn.request("GET", "/repos/" + fullName + "/branches", None, headers)
            branchList = json.load(conn.getresponse())
            for branch in branchList:
                print "    " + branch["name"]

conn.request("GET", "/users/" + user + "/repos?per_page=100000", None, headers)
repoList = json.load(conn.getresponse())

print "APPLICATIONS:"
filterDesc(repoList, "APP:")
print "\nLIBRARIES:"
filterDesc(repoList, "LIB:")
