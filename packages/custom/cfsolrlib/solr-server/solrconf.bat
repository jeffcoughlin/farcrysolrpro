@echo off
rem description: Configure the Solr server start/stop scripts for the FarCry Solr Pro plugin
rem author: Jeff Coughlin (www.jeffcoughlin.com), Sean Coyne (www.n42designs.com), Dennis Clark (github.com/boomfish)

rem All user-configurable settings are in solrvars.bat
call "%CONFDIR%\solrvars.bat"

:checkJavaHome

if "%JAVA_HOME%x" == "x" goto noJavaHome

rem Use full path to the java.exe in JAVA_HOME
set _EXECJAVA="%JAVA_HOME%\bin\java"

goto setOptions

:noJavaHome

set _EXECJAVA=java
@path=%path%;c:\program files\java\jre6\bin;c:\program files (x86)\java\jre6\bin;c:\program files\java\jre7\bin;c:\program files (x86)\java\jre7\bin;

:setOptions

set _SHAREDOPTS=-Djetty.home=%SOLRDIR% -Dsolr.solr.home=multicore -DSTOP.PORT=%STOPPORT% -DSTOP.KEY=%STOPKEY%
set _JAROPTS=-jar %SOLRDIR%\start.jar
set _STARTOPTS=-server -Xmx%XMS% -Xmx%XMX% -Djava.io.tmpdir=work
SET _XMLARGS=etc\jetty.xml

:checkLogsSetting

if "%JETTYLOGS%x" == "x" goto checkHostSetting

set _STARTOPTS=%_STARTOPTS% -Djetty.logs=%JETTYLOGS%
set _XMLARGS=%_XMLARGS% etc\jetty-logging.xml

:checkHostSetting

if "%JETTYHOST%x" == "x" goto endConfig

set _SHAREDOPTS=%_SHAREDOPTS% -Djetty.host=%JETTYHOST%

:endConfig
