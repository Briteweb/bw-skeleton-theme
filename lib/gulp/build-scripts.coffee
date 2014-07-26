fs               = require 'fs-extra'
path             = require 'path'
gulp             = require 'gulp'
gutil            = require 'gulp-util'
browserify       = require 'browserify'
source           = require 'vinyl-source-stream'
size             = require 'gulp-size'
rename           = require 'gulp-rename'
_                = require 'underscore'
livereload       = require 'gulp-livereload'
streamify        = require 'gulp-streamify'
Notification     = require 'node-notifier'
notifier         = new Notification()

uglify           = require './uglify.coffee'
gzip             = require './gzip.coffee'
getAllFilesPaths = require './get-all-file-paths.coffee'


module.exports = (args) ->

	_.defaults args,
		env: 'development'
		external: []
		dest: 'dist/scripts'
		src: ''
		basedir: path.dirname module.parent.filename
		scriptsPath: 'src/scripts'
		allowedExtensions: [
			'.coffee'
			'.js'
			'.hbs'
		]
		exclude: []

	basedir = args.basedir
	dest = path.join basedir, args.dest
	src = path.join basedir, args.src

	uglifyStream = gutil.noop()
	gzipStream = gutil.noop()
	gzipRenameStream = gutil.noop()
	gzipOutputStream = gutil.noop()
	gzipSizeStream = gutil.noop()
	livereloadStream = gutil.noop()

	allFiles = []

	if args.env is 'production'

		# uglifyStream = uglify
		uglifyStream = streamify( uglify() )

		# gzipStream = gzip
		gzipStream = streamify( gzip() )

		gzipRenameStream = rename( (path) ->
			path.extname = '.jgz'
			path
		)
		gzipOutputStream = gulp.dest( dest )
		gzipSizeStream = streamify( size
			showFiles: true
			showTotal: false
		)

	else

		allFiles = getAllFilesPaths args


	if args.env is 'watch' and args.server?
		livereloadStream = livereload args.server




	bundleStream = browserify
		entries: [ src ]
		extensions: args.allowedExtensions

	# remove current file
	allFilesClone = allFiles.slice 0
	allFilesClone.splice allFilesClone.indexOf( src ), 1

	if args.env isnt 'production'

		_.each allFilesClone, (item) ->
			bundleStream.external item

		_.each args.external, (item) ->
			bundleStream.external item

		bundleStream.external 'app'


	bundleStreamCallback = (err, src) ->

		if err

			if err.annotated?
				messageArray = err.annotated.split "\n"

				title = 'CoffeeScript error'
				filename = messageArray[0].replace basedir + '/', ''
				errMessage = messageArray.splice(1).join("\n")

				filenameShort = filename
				filenameShortMaxLength = 40
				if filenameShort.length > filenameShortMaxLength + 3
					filenameShort = '...' + filename.slice -filenameShortMaxLength

				console.log "\n" + title + "\nFile: " + filename + "\nError: \n" + errMessage

				notifier.notify
					title: title
					subtitle: filenameShort
					message: err.message
					sound: 'Basso'

			else

				console.log err




	bundleStream.bundle(
		debug: (args.env isnt 'production')
		insertGlobals: false
	, bundleStreamCallback )

		.pipe( source( path.basename( src ) ) )

		.pipe( uglifyStream )

		.pipe( rename( (path) ->
			if args.env is 'production'
				path.extname = '.min.js'
			else
				path.extname = '.js'

			path
		))

		.pipe( streamify( size(
			showFiles: true
			showTotal: false
		)))

		.pipe( gulp.dest( dest ) )

		.pipe( livereloadStream )

		.pipe( gzipStream )
		.pipe( gzipRenameStream )
		.pipe( gzipSizeStream )
		.pipe( gzipOutputStream )



