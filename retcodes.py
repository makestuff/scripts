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
import re
import glob
import argparse
from subprocess import Popen, PIPE

funcDict = dict()
enumList = []

def doCompile(headerData, incList):
    global enumList
    cmdLine = [
        'clang', 'prog.c', '-S', '-emit-llvm',
        '-o', '-',
        '-I', '.'
    ]
    for i in incList:
        cmdLine.append('-I')
        cmdLine.append(i)
    for srcFile in glob.glob("*.c"):
        print "Compiling %s" % srcFile
        cmdLine[1] = srcFile
        llvmData = Popen(cmdLine, stdout=PIPE).communicate()[0]
        for funcMatch in re.finditer(r"\ndefine\s.*?@([a-zA-Z][a-zA-Z0-9_]*)\(.*?{(.*?)\n}", llvmData, re.MULTILINE | re.DOTALL):
            funcName = funcMatch.group(1)
            funcBody = funcMatch.group(2)
            callSet = set()
            codeSet = set()
            for callMatch in re.finditer(r"call\s.*?@([a-zA-Z][a-zA-Z0-9_\.]*)", funcBody):
                callSet.add(callMatch.group(1))
            for codeMatch in re.finditer(r"store i32 ([0-9]+), i32\* %retVal, align 4", funcBody):
                codeSet.add(int(codeMatch.group(1)))
            funcDict[funcName] = (callSet, codeSet)

    l = re.findall(r"typedef enum {(.*?)} ([A-Z][A-Za-z0-9]*Status);", headerData, re.MULTILINE | re.DOTALL)
    if ( len(l) == 1 ):
        (enums, status) = l[0]
        enumList = re.findall(r"^\s+([A-Z][A-Z0-9_]*)", enums, re.MULTILINE)
    elif ( len(l) == 0 ):
        raise Exception("No status enums found")
    else:
        raise Exception("More than one status enum found")
    return status

def walkTree(func, codeAccum, contextAccum):
    if ( func in funcDict ):
        (callSet, codeSet) = funcDict[func]
        if ( callSet or codeSet ):
            for code in codeSet:
                if ( not code in codeAccum ):
                    codeAccum[code] = set()
                contextSet = codeAccum[code]
                contextSet.add(contextAccum)
            for called in callSet:
                walkTree(called, codeAccum, contextAccum + "->" + called + "()")

if __name__ == "__main__":
    print "Error Code Enumeration Tool Copyright (C) 2013 Chris McClelland\n"
    parser = argparse.ArgumentParser(description='Enumerate the error codes thrown by a top-level API.')
    parser.add_argument('-i', action="store", nargs='+', required=True, metavar="<incDir>", help="include directory")
    parser.add_argument('-d', action="store", nargs=1, required=True, metavar="<header.h>", help="top-level header file")
    parser.add_argument('-c', action="store_true", default=False, help="print context information")
    argList = parser.parse_args()

    # Read in the entire header file
    with open(argList.d[0], "r") as myfile:
        headerData = myfile.read()

    # Do the compilation step to populate the function dictionary
    status = doCompile(headerData, argList.i)

    # Find all the functions returning a status
    for m in re.finditer("DLLEXPORT\(" + status + "\)\s+([A-Za-z][A-Za-z0-9]*)\(.*?;", headerData, re.MULTILINE | re.DOTALL):
        funcName = m.group(1)
        print "\n----------------------------------------------------------------------------------------------------\n%s():" % funcName
        resultDict = dict()
        walkTree(funcName, resultDict, funcName+"()")
        for code in sorted(resultDict):
            print "  %s" % enumList[code]
            if ( argList.c ):
                for cxt in sorted(resultDict[code]):
                    print "    %s" % cxt
