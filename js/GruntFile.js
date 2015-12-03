/*global module*/

/*
Installing Grunt and associated contributions

- once only per machine
install node and npm:
	http://nodejs.org/download/
install grunt cli:
	npm install -g grunt-cli

- per project
npm install
*/
module.exports = function (grunt) {
	'use strict';
	var packagingFiles = {
			css: {},
			js: {}
		};

	packagingFiles.js['site/map-swift-editor.min.js'] = ['site/lib/external/*.js', 'site/lib/editor/*.js'];
	packagingFiles.css['site/map-swift-editor.min.css'] = ['src/style/editor/map-swift-editor.css'];

	grunt.initConfig({
		htmlbuild: {
			site: {
				src: 'site/*.html',
				dest: 'site/',
				options: {
					prefix: '/',
					scripts: {
						external: ['site/lib/external/*.js', 'site/external/*.js'],
						editor: ['site/lib/editor/*.js', 'site/map-swift-editor*.min.js'],
						inlined: 'site/lib/inline/*.js'
					},
					styles: {
						editor: ['site/style/editor/map-swift-editor.css', 'site/map-swift-editor*.min.css']
					}
				}
			}
		},
		connect: {
			server: {
				options: {
					port: 5000,
					base: 'site',
					middleware: function (connect, options, middlewares) {
						middlewares.unshift(function (req, res, next) {
							if (req.url === '/editor') {
								req.url = '/mapswift.html';
							}

							return next();
						});
						return middlewares;
					}
				}
			}
		},
		clean: {
			site: ['site'],
			sitelib: ['site/lib'],
			sitecss: ['site/style'],
			packagedsite: ['site/lib', 'site/style', 'site/browserify']
		},
		copy: {
			site: {
				expand: true,
				src: '**',
				cwd: 'src/',
				dest: 'site/'
			},
			inline: {
				expand: true,
				src: '**',
				cwd: 'src/lib/inline/',
				dest: 'site/lib/inline/'
			}
		},
		watch: {
			site: {
				files: ['src/**/*'],
				tasks: ['buildsite'],
				options: {
					spawn: false
				}
			}
		},
		uglify: {
			site: {
				options: {
					sourceMap: true
				},
				files: packagingFiles.js
			}
		},
		cssmin: {
			combine: {
				files: packagingFiles.css
			}
		},
		jscs: {
			src: ['src/lib/**/*.js', 'specs/*.js'],
			options: {
				config: '.jscsrc',
				reporter: 'inline'
			}
		},
		jshint: {
			all: ['src/lib/**/*.js', 'specs/*.js'],
			options: {
				jshintrc: true
			}
		},
		browserify: {
			external: {
				files: {
					'site/lib/external/browserified.js': ['src/browserify/*.js']
				}
			}
		},
		jasmine: {
			all: {
				src: 'src/lib/**/*.js',
				options: {
					outfile: 'SpecRunner.html',
					summary: true,
					display: 'short',
					keepRunner: true,
					specs: 'specs/*.js',
					vendor: 'site/lib/external/browserified.js',
					helpers: ['src/lib/inline/map-swift.js']
				}
			}
		}
	});
	grunt.registerTask('checkstyle', ['jshint', 'jscs']);
	grunt.registerTask('test', ['browserify:external', 'jasmine']);
	grunt.registerTask('precommit', ['checkstyle', 'test']);

	grunt.registerTask('preparesite', ['clean:site', 'copy:site', 'browserify:external']);
	grunt.registerTask('buildsite', ['preparesite', 'htmlbuild:site']);
	grunt.registerTask('packagejs', ['uglify:site', 'clean:sitelib', 'copy:inline']);
	grunt.registerTask('packagecss', ['cssmin:combine', 'clean:sitecss']);
	grunt.registerTask('package', ['preparesite', 'packagejs', 'packagecss', 'htmlbuild:site', 'clean:packagedsite']);

	grunt.registerTask('sitewatch', ['buildsite', 'connect:server', 'watch:site']);

	// Load local tasks.
	grunt.loadNpmTasks('grunt-contrib-jasmine');
	grunt.loadNpmTasks('grunt-notify');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-jscs');
	grunt.loadNpmTasks('grunt-contrib-jshint');
	grunt.loadNpmTasks('grunt-html-build');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-browserify');
	grunt.loadNpmTasks('grunt-contrib-connect');

	grunt.event.on('watch', function (action, filepath, target) {
		var options = grunt.config(['jasmine', 'all']);
		grunt.log.writeln(target + ': ' + filepath + ' has ' + action);

		if (target.indexOf('_full') > 0) {
			options.options.display = 'full';
			options.options.summary = false;
		}

		if (target.indexOf('specs') === 0) {
			options.options.specs = [filepath];
		} else {
			options.options.specs = ['specs/*.js'];
		}
		grunt.config(['jasmine', 'all'], options);

	});
};
