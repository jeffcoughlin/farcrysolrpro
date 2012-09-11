@echo off
rem description: Stops the Solr server for the FarCry Solr Pro plugin
rem author: Jeff Coughlin (www.jeffcoughlin.com), Sean Coyne (www.n42designs.com), Dennis Clark (github.com/boomfish)

rem Assume config scripts are in the directory as this batch file
set CONFDIR=%~dp0

call "%CONFDIR%\solrconf.bat"

echo.
echo =======================
echo FarCry Solr Pro plugin
echo =======================
echo Stopping Solr Server...

cd %SOLRDIR%
%_EXECJAVA% %_SHAREDOPTS% %_JAROPTS% --stop
