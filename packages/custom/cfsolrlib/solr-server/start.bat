@echo off
rem description: Starts the Solr server for the FarCry Solr Pro plugin
rem author: Jeff Coughlin (www.jeffcoughlin.com), Sean Coyne (www.n42designs.com)

rem Set min and max memory
set XMS="256M"
set XMX="512M"

rem Folder location for solr-server (must end in a slash)
rem set SOLRDIR="C:\program files (x86)\solr-server\"
set SOLRDIR="./"

rem Set unique port and stop key
set DTSOPPORT="8079"
set DSTOPKEY="farcrysolrpro"

rem Add java bin folder to system path
@path=%path%;c:\program files\java\jre6\bin;c:\program files (x86)\java\jre6\bin;c:\program files\java\jre7\bin;c:\program files (x86)\java\jre7\bin;

rem ###
rem Edit settings/variables above this line as needed

echo.
echo =======================
echo FarCry Solr Pro plugin
echo =======================
echo Starting Solr Server...

cd %SOLRDIR%
java -Dsolr.solr.home=multicore -DSTOP.PORT=%DTSOPPORT% -DSTOP.KEY=%DSTOPKEY% -Xms%XMS%  -Xmx%XMX% -jar %SOLRDIR%start.jar