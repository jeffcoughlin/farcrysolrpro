@echo off
rem description: Configuration for starting and stopping the Solr server
rem author: Jeff Coughlin (www.jeffcoughlin.com), Sean Coyne (www.n42designs.com), Dennis Clark (github.com/boomfish)

rem Set min and max memory
set XMS=256M
set XMX=512M

rem Folder location for solr-server (need not end in a slash)
rem set SOLRDIR=C:\program files (x86)\solr-server\
set SOLRDIR=%~dp0

rem Set unique port and key for stopping the server
set STOPPORT=8079
set STOPKEY=farcrysolrpro

rem Set hostname of network interface to listen on (use empty value to listen on all interfaces)
rem If set, this must match the host setting in the Solr Pro Plugin config
set JETTYHOST=localhost

rem Set directory for detailed logging to files (use empty value for standard logging to console only)
rem Path may be relative to SOLRDIR
set JETTYLOGS=logs

rem To force the use of a specific JRE set JAVA_HOME to its location
rem If JAVA_HOME is not set, the system path and standard locations will be searched
rem set JAVA_HOME=c:\program files\java\jre6
