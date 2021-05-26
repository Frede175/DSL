package dk.sdu.mmmi

import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.resource.DerivedStateAwareResource
import dk.sdu.mmmi.typescriptdsl.ModuleRefernce

class TypeScriptDerivedStateComputer implements IDerivedStateComputer {
	
	override discardDerivedState(DerivedStateAwareResource resource) {
		resource.allContents.filter(ModuleRefernce).filter[it.type !== null].forEach[
			it.module.generic
		]
	}
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		println('installDerivedState')
	}
	
}