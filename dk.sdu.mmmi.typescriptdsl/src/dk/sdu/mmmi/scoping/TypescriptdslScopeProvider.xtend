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
import java.util.Set

class TypescriptdslScopeProvider extends AbstractTypescriptdslScopeProvider {
	
	override getScope(EObject object, EReference ref) {
		switch ref {
			case ref === TypescriptdslPackage.Literals.TABLE_TYPE__TABLE || ref === TypescriptdslPackage.Literals.TABLE__SUPER_TYPE: {
				val database = EcoreUtil2.getContainerOfType(object, Database)
				val tables = newArrayList()
				if (database === null) {
					val module = EcoreUtil2.getContainerOfType(object, dk.sdu.mmmi.typescriptdsl.Module)
					if (module.generic !== null) tables.add(module.generic)
					module.getTables(tables, newHashSet)
					return Scopes.scopeFor(tables)
				} else {
					database.getTablesFromDatabase(tables)
					return Scopes.scopeFor(tables)
				}
			}
			case ref === TypescriptdslPackage.Literals.FIELD__ATTR: {
				val table = EcoreUtil2.getContainerOfType(object, Table)
				val attrs = newArrayList()
				table.getAttributes(attrs, newHashSet)
				return Scopes.scopeFor(attrs)
			}
		}
		return super.getScope(object, ref)		
	}
	
	def void getTablesFromDatabase(Database database, List<Table> tables) {
		tables.addAll(database.tables)
		database.modules.forEach[it.module.getTables(tables, newHashSet)]
	}
	
	def void getTables(dk.sdu.mmmi.typescriptdsl.Module module, List<Table> tables, Set<dk.sdu.mmmi.typescriptdsl.Module> visited) {
		if (module === null || visited.contains(module)) { return }
		visited.add(module)
		tables.addAll(module.tables)
		module.modules.forEach[it.module.getTables(tables, visited)]
	}
	
	
	def void getAttributes(Table table, List<Attribute> attrs, Set<Table> visited)  {
		if (table !== null && !visited.contains(table)) {
			visited.add(table)
			attrs.addAll(table.attributes)
			table.superType.getAttributes(attrs, visited)
		}
	}
}