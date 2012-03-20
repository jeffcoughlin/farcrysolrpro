FarCry Solr Pro 

To run the Solr instance that ships with the plugin run the following: 

  java -Dsolr.solr.home=multicore -jar start.jar

in this directory, and when Solr is started connect to 

  http://localhost:8983/solr/admin/

For assistance you may wish to run the executable bash script (for *nix/Mac) or the start.bat/stop.bat files (for Windows).  Just note that the sample scripts use a min/max RAM settings of 256/512 respectively.  You will likely want to increase those for production use (just edit the files as desired or create your own elsewhere on your server using these as starting templates).