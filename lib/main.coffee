helpers = require 'atom-linter'
{ BufferedProcess } = require 'atom'

executablePath = "jolie"
pattern = ".+:\\s*(?<file>.+):\\s*(?<line>\\d+):\\s*(?<type>error|warning)\\s*:(?<message>.+)"

module.exports =
  config: {}

  activate: ->
    require( "atom-package-deps" ).install( "linter-jolie" );

  provideLinter: ->
    provider =
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
