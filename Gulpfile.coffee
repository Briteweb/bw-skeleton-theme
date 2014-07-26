scriptMains = [
	'./src/scripts/public/public.coffee'
]

styleMains = [
	'./src/styles/public/public.scss'
]

sassIncludePaths = [
	'.'
	'./src/styles/public'
	'./tmp'
	'./lib'
	'./bower_components'
	'./node_modules'
]


externalModules = [
	'browsernizr/test/css/rgba'
	'browsernizr/test/file/filesystem'
	'browsernizr/test/websockets'
	'browsernizr/test/storage/localstorage'
	'browsernizr/test/history'
	'browsernizr/test/css/transitions'
	'browsernizr/test/css/transforms'
	'browsernizr/test/css/transforms3d'
	'browsernizr/test/css/opacity'
	'browsernizr/test/video'
	'modernizr'
	'underscore'
	'underscore.string'
	'backbone'
	'jquery'
	'backbone.wreqr'
	'backbone.babysitter'
	'backbone.marionette'
	'backbone.paginator'
	'backbone.localstorage'
	'backbone-query-parameters'
	'backbone-query-parameters-1.1-shim'
	"backbone.routefilter"
	'json3'
	'fancybox'
]


devices = [
	"default"
	"tablet"
	"mobile"
	"iphone"
	"ios"
	"ie8"
	"ie9"
	"ie11"
	"firefox"
	"android"
	"safari"
]

imageExtensions = [
	'.png'
	'.jpg'
	'.jpeg'
	'.gif'
]

scriptsExtensions = [
	'.coffee'
	'.hbs'
	'.js'
]

stylesExtensions = [
	'.scss'
]


###
Required modules
###
gulp         = require 'gulp'
gutil        = require 'gulp-util'
fs           = require 'fs-extra'
clean        = require 'gulp-clean'
rename       = require 'gulp-rename'
lr           = require 'tiny-lr'
runSequence  = require 'run-sequence'
path         = require 'path'
watch        = require 'gulp-watch'
size         = require 'gulp-size'
livereload   = require 'gulp-livereload'
plumber      = require 'gulp-plumber'
es           = require 'event-stream'
lr           = require 'tiny-lr'
gutil.server = lr()

Notification = require 'node-notifier'
notifier     = new Notification()

# source       = require 'vinyl-source-stream'
# watchify     = require 'watchify'


###
Custom local modules
###
uglify          = require './lib/gulp/uglify.coffee'
gzip            = require './lib/gulp/gzip.coffee'
buildScripts    = require './lib/gulp/build-scripts.coffee'
buildBundle     = require './lib/gulp/build-bundle.coffee'
buildDevBundles = require './lib/gulp/build-dev-bundles.coffee'
buildSass       = require './lib/gulp/build-sass.coffee'




###
Default Task (production)
###
gulp.task 'default', ->

	runSequence 'clean-production', ['css-to-scss', 'production-env'], ['images', 'styles', 'scripts']
	# console.log "RUNNING GULP IN PRODUCTION MODE"



###
Development
###
gulp.task 'dev', ->

	runSequence 'clean-development', ['css-to-scss', 'development-env'], ['images', 'styles', 'scripts']



###
Development bundles
###
gulp.task 'bundles', ->

	gutil.buildBundles = true
	runSequence 'clean-bundles', ['css-to-scss', 'development-env'], 'scripts'



###
Build ALL
###
gulp.task 'all', ->

	gutil.buildBundles = true
	runSequence 'clean-all', ['css-to-scss', 'development-env'], ['images', 'styles', 'scripts'], 'production-env', ['images', 'styles', 'scripts']




###
Utility tasks to switch environment
###
gulp.task 'production-env', -> gutil.env.type = 'production'
gulp.task 'development-env', -> gutil.env.type = 'development'
gulp.task 'watch-env', -> gutil.env.type = 'watch'




###
Task to clean scripts, styles and images
###
gulp.task 'clean-production', ->

	gulp.src( [
		'./dist/scripts/*.min.js'
		'./dist/scripts/*.min.js.jgz'

		'./dist/styles/*.min.css'
		'./dist/styles/*.min.css.cgz'

		# './dist/images'
	], read: false )
		.pipe( clean() )



###
Task to clean scripts, styles and images
###
gulp.task 'clean-development', ->

	gulp.src( [
		'./dist/scripts/*.js'
		'!./dist/scripts/*.min.js'

		'./dist/styles/*.css'
		'!./dist/styles/*.min.css'
		'./dist/styles/*.css.map'

		# './dist/images'
	], read: false )
		.pipe( clean() )




###
Task to clean the entire dist folder folder
###
gulp.task 'clean-bundles', ->

	gulp.src( [
		'./dist/bundles'
	], read: false )
		.pipe( clean() )



###
Task to clean the entire dist folder folder
###
gulp.task 'clean-all', ->

	gulp.src( './dist', read: false )
		.pipe( clean() )




###
Task to create SCSS files for all CSS dependencies.
This will speed up SASS compilation
###
gulp.task 'css-to-scss', ->

	gulp.src( [
		'./bower_components/**/*.css'
		'./lib/**/*.css'
	])
		# rename files to SCSS and add an underscore to the beginning of the filename
		.pipe( rename( (path) ->
			path.extname = '.scss'
			path.basename = '_' + path.basename
			path
		))

		# output in the tmp folder
		.pipe( gulp.dest('./tmp') )




###
Task to optimize images and watch for changes
###
gulp.task 'images', ->

	# glob = []

	# imageExtensions.forEach (ext)
	# 	glob.push './src/images/**/*' + ext

	# # gulp.src( glob )





###
Task to build the bundle with all the external modules required by the app
###
gulp.task 'scripts-external-bundle', ->

	# we do this task only if we are in production mode
	if not gutil.env? or not gutil.env.type? or gutil.env.type isnt 'development'
		return

	# we do this task only if we are in development mode
	if not gutil.buildBundles? or gutil.buildBundles isnt true
		return

	# build bundle based on the specified external modules
	buildBundle
		modules: externalModules





lastScriptTask = 'scripts-external-bundle'


scriptMains.forEach (src) ->

	basename = path.basename src, '.js'
	basename = path.basename basename, '.coffee'
	currentTaskBase = 'scripts-' + basename


	###
	Build bundles tasks
	###
	lastScriptTaskArray = []

	if lastScriptTask isnt ''
		lastScriptTaskArray.push lastScriptTask

	gulp.task currentTaskBase + '-bundles', lastScriptTaskArray, ->

		# we do this task only if we are in development mode
		if not gutil.env? or not gutil.env.type? or gutil.env.type isnt 'development'
			return

		# we do this task only if we are in development mode
		if not gutil.buildBundles? or gutil.buildBundles isnt true
			return

		# build all bundles individually
		buildDevBundles
			scriptsPath: path.join 'src/scripts', basename
			dest: path.join 'dist/bundles' , basename
			recursive: true
			external: externalModules
			allowedExtensions: scriptsExtensions
			exclude: [ path.join( 'src/scripts', basename, basename + '.coffee' ) ]


	lastScriptTask = currentTaskBase + '-bundles'



scriptMains.forEach (src) ->

	basename = path.basename src, '.js'
	basename = path.basename basename, '.coffee'
	currentTaskBase = 'scripts-' + basename



	###
	Build script tasks
	###
	lastScriptTaskArray = []

	if lastScriptTask isnt ''
		lastScriptTaskArray.push lastScriptTask

	gulp.task currentTaskBase, lastScriptTaskArray, ->

		buildScripts
			env: gutil.env.type
			src: src
			external: externalModules
			scriptsPath: path.join 'src/scripts', basename
			allowedExtensions: scriptsExtensions
			exclude: [ path.join( 'src/scripts', basename, basename + '.coffee' ) ]

	lastScriptTask = currentTaskBase



gulp.task 'scripts', [ lastScriptTask ]



# gulp.task 'scripts-watchify', ->

# 	bundler = watchify
# 		entries: [ './src/scripts//public/public.coffee' ]
# 		extensions: scriptsExtensions
# 		transform: [
# 			'caching-coffeeify'
# 			'hbsfy'
# 		]

# 	rebundle = ->

# 		bundler.bundle()
# 			.pipe( source('public.js') )
# 			.pipe( gulp.dest('./dist/scripts') )


# 	bundler.on 'update', rebundle

# 	rebundle()




sassDevice = (src, device) ->

	# write device sass variable to file
	fs.outputFileSync './tmp/_device.scss', '$device: "' + device + '";' + '\n'

	stylesDest = './dist/styles'
	imagesPath = '../../src'

	# create suffix for build files
	if device is 'default'
		suffix = ''
	else
		suffix = '-' + device

	sourceComments  = 'map'
	outputStyle     = 'nested'

	livereloadStream = gutil.noop()
	gzipStream = gutil.noop()
	gzipRenameStream = gutil.noop()
	gzipOutputStream = gutil.noop()
	gzipSizeStream = gutil.noop()

	if gutil.env.type is 'production'
		sourceComments  = 'none'
		outputStyle     = 'compressed'

		gzipStream = gzip()
		gzipRenameStream = rename( (path) ->
			path.extname = '.cgz'
			path
		)
		gzipOutputStream = gulp.dest( stylesDest )
		gzipSizeStream = size
			showFiles: true
			showTotal: false


	stream = gulp.src( src, read : false )


	errorHandler = false
	errLogToConsole = false

	if gutil.env.type is 'watch'

		errLogToConsole = true
		livereloadStream = livereload(gutil.server)

		if gutil.watchError? and gutil.watchError[src]? and gutil.watchError[src]
			return

		errorHandler = (err, cb) ->

			messageArray = err.split ': error: '

			title = 'Sass error'
			filename = messageArray[0].replace __dirname + '/', ''
			errMessage = messageArray[1]

			filenameShort = filename
			filenameShortMaxLength = 40
			if filenameShort.length > filenameShortMaxLength + 3
				filenameShort = '...' + filename.slice -filenameShortMaxLength

			console.log "\n" + title + "\nFile: " + filename + "\nError: " + errMessage

			notifier.notify
				title: title
				subtitle: filenameShort
				message: errMessage
				sound: 'Basso'

			stream.emit('end')

			if not gutil.watchError?
				gutil.watchError = {}

			gutil.watchError[src] = true

			return cb()


	stream

		.pipe( buildSass(
			includePaths: sassIncludePaths
			errorHandler: errorHandler
			errLogToConsole: errLogToConsole
			sourceComments: sourceComments
			outputStyle: outputStyle
			imagePath: imagesPath
			dest: stylesDest
			rename : (path) ->
				path.basename += suffix
				path
		))

		.pipe( rename( (path) ->

			path.basename += suffix

			if gutil.env.type is 'production'
				path.basename += '.min'

			path
		))

		.pipe( size(
			showFiles: true
			showTotal: false
		) )
		.pipe( gulp.dest(stylesDest) )

		.pipe( livereloadStream )


		.pipe( gzipStream )
		.pipe( gzipRenameStream )
		.pipe( gzipSizeStream )
		.pipe( gzipOutputStream )




# build dinamic tasks
styleTask = []

# loop through all sources
styleMains.forEach (src) ->

	dirname = path.dirname src
	basename = path.basename dirname

	currentSrcTask = 'styles-' + basename

	styleTask.push currentSrcTask

	lastDeviceStyleTask = ''

	# loop through all devices
	devices.forEach (device) ->

		currentDeviceTask = currentSrcTask + '-' + device

		lastDeviceStyleTaskArray = []

		if lastDeviceStyleTask isnt ''
			lastDeviceStyleTaskArray.push lastDeviceStyleTask

		gulp.task currentDeviceTask, lastDeviceStyleTaskArray, ->
			sassDevice src, device


		lastDeviceStyleTask = currentDeviceTask



	gulp.task currentSrcTask, ->
		runSequence lastDeviceStyleTask



gulp.task 'styles', ->

	runSequence.apply @, styleTask









gulp.task 'watch-scripts', ->

	opening = {}

	scriptMains.forEach (src) ->

		dirname = path.dirname(src).replace('./', '')
		basename = path.basename dirname

		glob = []

		scriptsExtensions.forEach (ext) ->

			glob.push dirname + '/**/*' + ext

		opening[ basename ] = true

		watch
			glob: glob
			emit: 'one'
		, (files) ->

			if opening[ basename ]
				opening[ basename ] = false
				return

			files
				.pipe( plumber() )
				.pipe( es.map( (file, cb) ->

					relative = path.relative __dirname, file.path

					if file.path is path.resolve( src )

						buildScripts
							src: relative
							scriptsPath: path.join 'src/scripts', basename
							external: externalModules
							server: gutil.server
							env: gutil.env.type
							allowedExtensions: scriptsExtensions
							exclude: [ path.join( 'src/scripts', basename, basename + '.coffee' ) ]


					else

						# build all bundles individually
						buildDevBundles
							src: relative
							scriptsPath: path.join 'src/scripts', basename
							dest: path.join 'dist/bundles' , basename
							external: externalModules
							server: gutil.server
							env: gutil.env.type
							allowedExtensions: scriptsExtensions
							exclude: [ path.join( 'src/scripts', basename, basename + '.coffee' ) ]


					cb null, file
				) )





gulp.task 'watch-styles', ->

	loading = {}

	styleMains.forEach (src) ->

		dirname = path.dirname(src).replace('./', '')
		basename = path.basename dirname

		loading[src] = true

		watch
			glob: dirname + '/**/*.scss'
			emit: 'one'
		, (files) ->

			if loading[src]
				loading[src] = false
				return

			if not gutil.watchError?
				gutil.watchError = {}

			gutil.watchError[src] = false

			gulp.src( src, read: false )
				.pipe( es.map( (file, cb) ->

					runSequence 'styles-' + basename

					cb null, file

				) )





gulp.task 'watch-images', ->

	# watch(
	# 	glob: [
	# 		'./src/images/**/*'
	# 	]
	# 	emitOnGlob: false
	# 	emit: 'one'
	# )



gulp.task 'watch', ['css-to-scss', 'watch-env'], ->

	gutil.server.listen 1337, (err) ->
		return console.log(err) if err

		runSequence ['watch-scripts', 'watch-styles', 'watch-images']



