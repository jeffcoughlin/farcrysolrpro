@echo off
rem description: Stops the Solr server for the FarCry Solr Pro plugin
rem author: Jeff Coughlin (www.jeffcoughlin.com), Sean Coyne (www.n42designs.com)

rem Folder location for solr-server (must end in a slash)
rem set SOLRDIR="C:\program files (x86)\solr-server\"
set SOLRDIR="./"

rem Set unique port and stop key
set DTSOPPORT="8079"
set DSTOPKEY="farcrysolrpro"

rem ###
rem Edit settings/variables above this line as needed

echo.
echo =======================
echo FarCry Solr Pro plugin
echo =======================
echo Stopping Solr Server...

cd %SOLRDIR%
java -Dsolr.solr.home=multicore -DSTOP.PORT=%DTSOPPORT% -DSTOP.KEY=%DSTOPKEY% -jar %SOLRDIR%start.jar --stop