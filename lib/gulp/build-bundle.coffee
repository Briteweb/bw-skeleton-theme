fs         = require 'fs-extra'
path       = require 'path'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
browserify = require 'browserify'
size       = require 'gulp-size'
streamify  = require 'gulp-streamify'
_          = require 'underscore'
source     = require 'vinyl-source-stream'
Notification     = require 'node-notifier'
notifier         = new Notification()

module.exports = (args) ->

	_.defaults args,
		modules: []
		dest: 'dist/bundles'
		basedir: path.dirname module.parent.filename

	if not args.modules? or not args.modules.length? or args.modules.length is 0
		return

	basedir = args.basedir

	dest = path.join basedir, args.dest


	bundleStream = browserify()

	_.each args.modules, (item) ->
		bundleStream.require item


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
		debug: true
		insertGlobals: false
	, bundleStreamCallback )
		.pipe( source( 'external.js' ) )

		# Write to disk
		.pipe( gulp.dest( dest ) )

		# Output size of bundle
		.pipe( streamify( size(
			showFiles: true
			showTotal: false
		)))

