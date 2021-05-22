package dk.sdu.mmmi.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import dk.sdu.mmmi.typescriptdsl.TypescriptdslPackage
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.EcoreUtil2
import dk.sdu.mmmi.typescriptdsl.Database
import dk.sdu.mmmi.typescriptdsl.Table
import dk.sdu.mmmi.typescriptdsl.Attribute
import java.util.List
import dk.sdu.mmmi.typescriptdsl.ITable

class TypescriptdslScopeProvider extends AbstractTypescriptdslScopeProvider {
	
	override getScope(EObject object, EReference ref) {
		
		switch ref {
			case ref === TypescriptdslPackage.Literals.TABLE_TYPE__TABLE || ref === TypescriptdslPackage.Literals.TABLE__SUPER_TYPE: {
				val database = EcoreUtil2.getContainerOfType(object, Database)
				
				val List<ITable> tables = newArrayList()
				if (database === null) {
					val module = EcoreUtil2.getContainerOfType(object, dk.sdu.mmmi.typescriptdsl.Module)
					if (module.type !== null) tables.add(module.type)
					module.getTables(tables)
				} else {
					getTablesFromDatabase(database, tables)
				}
				return Scopes.scopeFor(tables)
			}
			case ref === TypescriptdslPackage.Literals.FIELD__ATTR: {
				val table = EcoreUtil2.getContainerOfType(object, Table)
				val attrs = newArrayList()
				table.getAttributes(attrs)
				return Scopes.scopeFor(attrs)
			}
//			case ref === TypescriptdslPackage.Literals.PARAMETER_TYPE__PARAMETER: {
//				val module = EcoreUtil2.getContainerOfType(object, dk.sdu.mmmi.typescriptdsl.Module)
//				return Scopes.scopeFor(newArrayList(module.type))
//			}
		}
		return super.getScope(object, ref)		
	}
	
	def void getTablesFromDatabase(Database database, List<ITable> tables) {
		tables.addAll(database.tables)
		database.modules.forEach[it.module.getTables(tables)]
	}
	
	def void getTables(dk.sdu.mmmi.typescriptdsl.Module module, List<ITable> tables) {
		tables.addAll(module.tables)
		module.modules.forEach[it.module.getTables(tables)]
	}
	
	
	def void getAttributes(Table table, List<Attribute> attrs) {
		if (table !== null) {
			attrs.addAll(table.attributes)
			table.superType.getAttributes(attrs)
		}
	}
}