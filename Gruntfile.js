/* globals module, require */

module.exports = function(grunt) {

	grunt.loadNpmTasks('grunt-contrib-compress');
	grunt.loadNpmTasks('grunt-bump');

	grunt.initConfig({

		pkg: grunt.file.readJSON('package.json'),

		bump: {
			options: {
				files: ['package.json','install/manifest.cfc'],
				updateConfigs: [ 'pkg' ],
				commit: true,
				commitMessage: 'release version %VERSION%',
				commitFiles: ['package.json','install/manifest.cfc'],
				createTag: true,
				tagName: '%VERSION%',
				tagMessage: 'version %VERSION%',
				push: true,
				pushTo: 'origin',
				gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d',
				globalReplace: false,
				prereleaseName: false,
				metadata: '',
				regExp: (/(['|"]?version['|"]?[ ]*[:|=][ ]*['|"]?)(\d+\.\d+\.\d+(-\.\d+)?(-\d+)?)[\d||A-a|.|-]*(['|"]?)/i)
			}
		},
		
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
