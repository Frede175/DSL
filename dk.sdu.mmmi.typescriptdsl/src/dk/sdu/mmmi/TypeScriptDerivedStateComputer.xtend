package dk.sdu.mmmi

import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.resource.DerivedStateAwareResource
import dk.sdu.mmmi.typescriptdsl.ModuleRefernce
import dk.sdu.mmmi.typescriptdsl.GenericTable
import dk.sdu.mmmi.typescriptdsl.RealTable

class TypeScriptDerivedStateComputer implements IDerivedStateComputer {
	
	override discardDerivedState(DerivedStateAwareResource resource) {
		resource.allContents.filter(GenericTable).forEach[
			it.real = null
		]
	}
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (preLinkingPhase) { return }
		resource.allContents.filter(ModuleRefernce).filter[it.type !== null && it.module.generic !== null].forEach[
			it.module.generic.real = it.type
		]
	}
}