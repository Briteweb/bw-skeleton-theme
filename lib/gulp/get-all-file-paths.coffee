fs               = require 'fs-extra'
path             = require 'path'
gulp             = require 'gulp'
gutil            = require 'gulp-util'
_                = require 'underscore'
lsr              = require 'lsr'

module.exports = (args) ->

	_.defaults args,
		scriptsPath: 'src/scripts'
		basedir: path.dirname module.parent.filename
		allowedExtensions: [
			'.coffee'
			'.js'
			'.hbs'
		]
		exclude: []

	# check that the provided src is a string
	if not _.isString args.scriptsPath
		return []

	basedir = args.basedir

	scriptsPath = args.scriptsPath

	if scriptsPath[0] isnt '/'
		scriptsPath = path.join basedir, scriptsPath



	# list all files inside the folder provided.
	files = lsr.sync scriptsPath,

		filter: (file) ->

			# filter out dotfiles
			if file.name.length > 0 and file.name[0] is '.'
				return false

			if _.contains args.exclude, file.name
				return false

			# get the file extension
			ext = path.extname( file.name )

			# first, check that the file has an extension
			if ext? and ext isnt ''

				# validate file extension
				if not _.contains args.allowedExtensions, ext
					return false

				# don't 'main' files
				if file.name is 'public.coffee'
					return false

				# # Main files are also characterized by having a name that is the same as the
				# # folder that contains them.
				# if path.basename( path.dirname( file.fullPath ) ) is path.basename( file.name, '.coffee' )
				# 	return false

			true


	# filter out folders and other stray files with wrong extensions
	files = _.filter files, (file) ->
		_.contains args.allowedExtensions, path.extname( file.name )

	# Get an array of all the full paths
	files = _.pluck files, 'fullPath'

	# return files
	files

