{BufferedProcess} = require 'atom'

executablePath = "jolie"
errorPattern = /.+:([^:]+):(\d+):\s*error\s*:(.+)/

module.exports =
  config: {}

  provideLinter: =>
    provider =
      grammarScopes: [ "source.jolie" ]
      scope: "file"
      lintOnFly: true
      lint: ( editor ) =>
        return new Promise ( resolve, reject ) =>
          output = []
          process = new BufferedProcess
            command: executablePath
            args: [ "--check", editor.getPath() ]
            stderr: (data) ->
              match = data.match( errorPattern )
              if match
                output.push( {
                  type: "Error",
                  text: match[3],
                  filePath: editor.getPath(), # match[1] does not work properly
                  range: [ [ match[2] - 1, 0 ], [ match[2] - 1, 0 ] ]
                } )
            exit: (code) ->
              return resolve output

          process.onWillThrowError ( { error, handle } ) ->
            atom.notifications.addError "Failed to run #{executablePath}",
              detail: "#{error.message}",
              dismissable: true
            handle()
            resolve []
