UglifyJS2 = require 'uglify-js2'
through   = require 'through2'

module.exports = ->

	stream = (file, enc, cb) ->

		self = this

		uglyfiedFileContent = UglifyJS2.minify file.contents.toString(),
			fromString: true

		file.contents = new Buffer uglyfiedFileContent.code
		self.push file

		cb()

	through.obj stream
