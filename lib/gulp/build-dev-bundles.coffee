fs               = require 'fs-extra'
path             = require 'path'
gulp             = require 'gulp'
gutil            = require 'gulp-util'
_                = require 'underscore'
rename           = require 'gulp-rename'
size             = require 'gulp-size'
sh               = require 'shorthash'
es               = require 'event-stream'
livereload       = require 'gulp-livereload'
browserify       = require 'browserify'
source           = require 'vinyl-source-stream'
runSequence      = require 'run-sequence'
streamify        = require 'gulp-streamify'
through          = require 'through2'
getAllFilesPaths = require './get-all-file-paths.coffee'
Notification     = require 'node-notifier'
notifier         = new Notification()

module.exports = (args) ->

	_.defaults args,
		external: []
		dest: 'dist/bundles'
		src: ''
		scriptsPath: 'src/scripts'
		basedir: path.dirname module.parent.filename
		recursive: false
		env: 'development'
		allowedExtensions: [
			'.coffee'
			'.js'
			'.hbs'
		]
		exclude: []

	if not args.recursive and ( not args.src? or args.src is '' or args.length is 0 )
		return


	basedir = args.basedir
	dest = path.join basedir, args.dest


	scriptBasename = ''
	if args.scriptsPath isnt 'src/scripts'
		scriptBasename = path.relative 'src/scripts', args.scriptsPath
		scriptBasename = scriptBasename.split('/')[0]



	allFiles = getAllFilesPaths args


	###
	Recursive mode: find all files inside provided src folder
	###
	if args.recursive? and args.recursive is true

		files = allFiles

	else

		# in case we are not in recursive mode, simply create an array of the provided src(s)
		if _.isString args.src
			args.src = [ args.src ]

		files = args.src



	scriptsPath = args.scriptsPath

	if scriptsPath[0] isnt '/'
		scriptsPath = path.join basedir, scriptsPath




	stream = gulp.src( files, read: false )

		.pipe( through.obj( (file, enc, cb) ->

			self = this

			bundleStream = browserify
				entries: []
				extensions: args.allowedExtensions

			bundleStream.require file.path

			# remove current src from 'allFiles'
			allFilesClone = allFiles.slice 0
			allFilesClone.splice allFilesClone.indexOf( file.path ), 1

			_.each allFilesClone, (item) ->
				bundleStream.external item

			_.each args.external, (item) ->
				bundleStream.external item

			if path.basename( file.path, '.coffee' ) isnt 'app'
				bundleStream.external 'app'


			bundleStream.bundle
				debug: true
				insertGlobals: false
			, (err, src) ->

				if not err
					file.contents = new Buffer src
					self.push file
				else

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


				cb()

		) )

		# rename based on a short hash
		.pipe( es.map( (file, cb) ->

			relativePath = path.relative basedir, file.path

			if args.env isnt 'watch'
				gutil.log('Bundling', relativePath )

			hash = sh.unique relativePath
			name = 'bundle-' + hash + '.js'

			file.path = path.join path.dirname( file.path ), name

			cb null, file
		))

		# output to the right path
		.pipe( gulp.dest( dest ) )

		# Output size of bundle
		.pipe( size(
			showFiles: true
			showTotal: false
		))


	if args.env is 'watch' and args.server?
		stream.pipe( livereload( args.server ) )


	stream
