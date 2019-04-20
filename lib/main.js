'use babel';

import { BufferedProcess, CompositeDisposable } from 'atom'
import * as helpers from 'atom-linter'

let executablePath = atom.config.get( "linter-jolie.jolieExecutablePath" )
let messageRegex = /\s*(?<file>.+):\s*(?<line>\d+):\s*(?<type>error|warning)\s*:\s*(?<message>.+)/gm

module.exports = {
	activate() {
		require( "atom-package-deps" ).install( "linter-jolie" )
		this.subscriptions = new CompositeDisposable()
		this.subscriptions.add(
			atom.config.observe(
				"linter-jolie.jolieExecutablePath",
				( v ) => { executablePath = v.trim() }
			)
		)
	},

	deactivate() {
		this.subscriptions.dispose()
	},

	provideLinter() {
		return {
			grammarScopes: [ "source.jolie" ],
			name: "JolieLinter",
			scope: "file",
			lintsOnChange: true,
			lint: async ( editor ) => {
				const output = await helpers.exec( executablePath, [ "--check", editor.getPath() ], { stream: "both" } )
				console.log( output )
				let messages = [];
				let match = messageRegex.exec( output.stderr )
				while( match !== null ) {
					console.log( match )
					const line = Number.parseInt(match.groups.line, 10) - 1;
					messages.push( {
						severity: match.groups.type,
						location: {
							file: match.groups.file,
							position: helpers.generateRange( editor, line )
						},
						excerpt: match.groups.message
					} )
					match = messageRegex.exec( output.stderr )
				}
				return messages
			}
		}
	},
}
