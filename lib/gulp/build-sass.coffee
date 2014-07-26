fs      = require 'fs-extra'
path    = require 'path'
gulp    = require 'gulp'
gutil   = require 'gulp-util'
gs      = require 'glob-stream'
rename  = require 'gulp-rename'
through = require 'through2'
clone   = require 'clone'
map     = require 'map-stream'
File    = require 'vinyl'
sass    = require 'node-sass'

module.exports = (options) ->

	if options?
		opts = clone(options)
	else
		opts = {}


	through.obj (file, enc, cb) ->

		self = this

		if path.basename(file.path).indexOf('_') is 0
			return cb()

		# opts.data = file.contents.toString()
		opts.file = file.path

		if opts.sourceComments? and opts.sourceComments is 'map' and opts.dest?
			opts.sourceMap = path.basename( gutil.replaceExtension(file.path, '.css.map') )

		if not opts.rename?
			opts.rename = {}

		opts.success = (css, cssmap) ->
			# console.log 'SUCCESS'
			# console.log css

			if opts.sourceComments? and opts.sourceComments is 'map' and opts.dest?
				# console.log '===== MAP ====='
				# console.log map

				mapGlobStream = gs.create file.path,
					read : false

				formatMapStream = map( (newFile, newCb) ->

					mapFile          = new File(newFile)
					mapFile.path     = gutil.replaceExtension(newFile.path, '.css.map')
					mapFile.contents = new Buffer(cssmap)

					newCb(null, mapFile);
				)

				mapGlobStream
					.pipe( formatMapStream )
					.pipe( rename( opts.rename ) )
					.pipe( gulp.dest( opts.dest ) )


			file.path      = gutil.replaceExtension(file.path, '.css')
			file.contents  = new Buffer(css)

			self.push file
			cb()



		opts.error = (err) ->

			if opts.errorHandler?
				return opts.errorHandler(err, cb)

			if opts.errLogToConsole
				gutil.log('[gulp-sass] ' + err)
				return cb()

			return cb(new gutil.PluginError('gulp-sass', err))


		sass.render(opts)


