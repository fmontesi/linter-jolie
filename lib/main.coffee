helpers = require 'atom-linter'
{BufferedProcess} = require 'atom'

executablePath = "jolie"
pattern = ".+:(?<file>[^:]+):(?<line>\\d+):\\s*(?<type>error|warning)\\s*:(?<message>.+)"

module.exports =
  config: {}

  provideLinter: ->
    provider =
      grammarScopes: [ "source.jolie" ]
      scope: "file"
      lintOnFly: true
      lint: ( editor ) ->
        return helpers.exec( executablePath, [ "--check", editor.getPath() ], { stream: "both" } ).then ( data ) ->
          helpers.parse( data.stderr, pattern, { filePath: editor.getPath() } )
            .map ( issue ) ->
              [ [ lineStart, colStart ], [ lineEnd, colEnd ] ] = issue.range
              issue.range = helpers.rangeFromLineNumber editor, lineStart, colStart
              return issue
