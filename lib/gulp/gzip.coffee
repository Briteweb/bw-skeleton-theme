zlib    = require 'zlib'
through = require 'through2'

module.exports = ->

	stream = (file, enc, cb) ->

		self = this

		zlib.gzip file.contents, (err, res) ->

			file.contents = new Buffer res
			self.push file

			cb()

	through.obj stream
