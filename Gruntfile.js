/* globals module, require */

module.exports = function(grunt) {

	grunt.loadNpmTasks('grunt-contrib-compress');

	grunt.initConfig({

		pkg: grunt.file.readJSON('package.json'),

		compress: {
			full: {
				options: {
					mode: "zip",
					archive: './release/farcrysolrpro-<%= pkg.version %>.zip'
				},
				files: [
					{
						expand: true,
						src: [
							"**/*",
							"!.git/",
							"!.gitignore",
							"!package.json",
							"!Gruntfile.js",
							"!release/**",
							"!node_modules/**",
							"!.project",
							"!.settings/**",
							"!settings.xml",
							"!.idea/**",
							"!.iml"
						],
						dest: "."
					}
				]
			},
			nosolr: {
				options: {
					mode: "zip",
					archive: './release/farcrysolrpro-nosolr-<%= pkg.version %>.zip'
				},
				files: [
					{
						expand: true,
						src: [
							"**/*",
							"!.git/",
							"!.gitignore",
							"!package.json",
							"!Gruntfile.js",
							"!release/**",
							"!node_modules/**",
							"!.project",
							"!.settings/**",
							"!settings.xml",
							"!.idea/**",
							"!.iml",
							"!packages/custom/cfsolrlib/contrib/**/*",
							"!packages/custom/cfsolrlib/solr-server/**/*"
						],
						dest: "."
					}
				]
			}
		}

	});

	grunt.registerTask('release', [ 'compress:full', 'compress:nosolr' ]);

};
