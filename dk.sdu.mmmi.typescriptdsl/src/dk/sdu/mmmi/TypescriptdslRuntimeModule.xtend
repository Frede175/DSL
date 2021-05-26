package dk.sdu.mmmi

import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.DerivedStateAwareResourceDescriptionManager

class TypescriptdslRuntimeModule extends AbstractTypescriptdslRuntimeModule  {
	
	override bindXtextResource() {
		DerivedStateAwareResource
	}
	def Class<? extends IDerivedStateComputer> bindIDerivedStateComputer() {
		TypeScriptDerivedStateComputer
	}
	
	def Class<? extends IResourceDescription.Manager> bindIResourceDescriptionManager() {
		DerivedStateAwareResourceDescriptionManager
	}
	
}