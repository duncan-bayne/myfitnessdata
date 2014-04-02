myfitnessdata
=============
myfitnessdata is an application to extract diet progress data from the [MyFitnessPal](http://www.myfitnesspal.com/) website.

status
------
I have released MyFitnessData 1.1; release notes are available on [the wiki](https://github.com/duncan-bayne/myfitnessdata/wiki).  This version is currently broken as a result of website changes at MyFitnessPal.

[MyFitnessData 2.0](https://github.com/duncan-bayne/myfitnessdata/tree/2.0) is under development.  It will feature several major improvements including a GUI written with [mcclim](http://common-lisp.net/project/mcclim/).

licence
-------
myfitnessdata is licensed under the GNU Lesser General Public License.

### why the LGPL?
The GPL is specifically designed to reduce the usefulness of GPL-licensed code to closed-source, proprietary software. The BSD license (and similar) don't mandate code-sharing if the BSD-licensed code is modified by licensees. The LGPL achieves the best of both worlds: an LGPL-licensed library can be incorporated within closed-source proprietary code, and yet those using an LGPL-licensed library are required to release source code to that library if they change it.

roadmap
-------
1. script that executes on any POSIX system running SBCL [done]
2. Windows executable [done]
3. parse just Weight information into arbitrary CSV file [done]
4. sort data by date [done]
4. Windows installer [done]
5. test suite and runner [done]
6. web proxy support
7. additional export features
8. Debian / Ubuntu installer [if requested]

debian / ubuntu
---------------
To build on Ubuntu, you'll need to install:

* SBCL (using apt-get)
* [Quicklisp](http://www.quicklisp.org/) (using install_quicklisp.sh)
* [Buildapp](http://www.xach.com/lisp/buildapp/) (using install_buildapp.sh)

As of 9 January 2011, there is a bug in the SBCL package for Debian & Ubuntu which will cause myfitnessdata to fail with an error like:

`Not an absolute pathname #P"~/.clc/systems/"`

The fix to this is documented [here](http://ikki.ws/showpost?postid=103).

ms windows
----------
To build on MS Windows, you'll need to install:

* [SBCL for Windows](http://www.sbcl.org/platform-table.html)
* [Quicklisp](http://www.quicklisp.org/) (using install_quicklisp.sh)
* [Buildapp](http://www.xach.com/lisp/buildapp/) (manually, see below)
* [OpenSSL](http://www.slproweb.com/products/Win32OpenSSL.html)
* [Git](http://code.google.com/p/msysgit/)
* [GnuWin32 packages](http://gnuwin32.sourceforge.net/packages.html) wget, coreutils, gmake. Ensure that your GnuWin32 bin directory is in your Windows PATH.
* [Inno Setup](http://www.jrsoftware.org/isinfo.php). Ensure that the location of iscc.exe is in your PATH.

When installing buildapp, note that the Makefile that comes with buildapp doesn't work on Windows.  So instead of using install_buildapp.sh, you'll need to run make, then manually copy buildapp.exe into place.


