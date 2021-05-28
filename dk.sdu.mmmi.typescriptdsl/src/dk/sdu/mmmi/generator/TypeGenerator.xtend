package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.typescriptdsl.Database
import static extension dk.sdu.mmmi.generator.Helpers.*

class TypeGenerator implements FileGenerator {
	
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val tables = newArrayList()
		resource.allContents.filter(Database).head.getTables(tables)
		val generators = newArrayList(new UtilityTypeGenerator, new TableTypeGenerator, new DelegateGenerator, new TableDataGenerator, new ConstraintGenerator)

		fsa.generateFile('index.ts', generators.map[generate(tables)].join('\n'))
	}
}