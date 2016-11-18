helpers = require 'atom-linter'
{ BufferedProcess, CompositeDisposable } = require 'atom'

executablePath = atom.config.get( "linter-jolie.jolieExecutablePath" )
pattern = "[^:]+:\\s*(?<file>.+):\\s*(?<line>\\d+):\\s*(?<type>error|warning)\\s*:(?<message>.+)"

module.exports =
	activate: ->
		require( "atom-package-deps" ).install( "linter-jolie" )
		@subscriptions = new CompositeDisposable
		@subscriptions.add(
			atom.config.observe( "linter-jolie.jolieExecutablePath",
				( v ) ->
					executablePath = v.trim()
			)
		)

	deactivate: ->
		@subscriptions.dispose()

	provideLinter: =>
		grammarScopes: [ "source.jolie" ]
		scope: "file"
		lintOnFly: true
		lint: ( editor ) ->
			return helpers.exec( executablePath, [ "--check", editor.getPath() ], { stream: "both" } ).then ( data ) ->
				helpers.parse( data.stderr, pattern )
				.map ( issue ) ->
					[ [ lineStart, colStart ], [ lineEnd, colEnd ] ] = issue.range
					issue.range = helpers.rangeFromLineNumber editor, lineStart, colStart
					return issue
