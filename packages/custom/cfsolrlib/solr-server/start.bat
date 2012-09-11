@echo off
rem description: Starts the Solr server for the FarCry Solr Pro plugin
rem author: Jeff Coughlin (www.jeffcoughlin.com), Sean Coyne (www.n42designs.com), Dennis Clark (github.com/boomfish)

rem Assume config scripts are in the same directory as this batch file
set CONFDIR=%~dp0

call "%CONFDIR%\solrconf.bat"

echo.
echo =======================
echo FarCry Solr Pro plugin
echo =======================
echo Starting Solr Server...

cd %SOLRDIR%

rem Make sure work directory exists
mkdir work 2>nul

%_EXECJAVA% %_STARTOPTS% %_SHAREDOPTS% %_JAROPTS% %_XMLARGS%
