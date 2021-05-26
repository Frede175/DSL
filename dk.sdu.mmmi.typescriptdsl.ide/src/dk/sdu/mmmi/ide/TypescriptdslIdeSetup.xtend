/*
 * generated by Xtext 2.24.0
 */
package dk.sdu.mmmi.ide

import com.google.inject.Guice
import dk.sdu.mmmi.TypescriptdslRuntimeModule
import dk.sdu.mmmi.TypescriptdslStandaloneSetup
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class TypescriptdslIdeSetup extends TypescriptdslStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new TypescriptdslRuntimeModule, new TypescriptdslIdeModule))
	}
	
}
