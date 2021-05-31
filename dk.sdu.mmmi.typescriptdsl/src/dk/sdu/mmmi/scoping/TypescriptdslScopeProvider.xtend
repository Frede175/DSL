package dk.sdu.mmmi.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.EcoreUtil2
import dk.sdu.mmmi.typescriptdsl.Table
import dk.sdu.mmmi.typescriptdsl.Attribute
import java.util.List
import java.util.Set
import dk.sdu.mmmi.typescriptdsl.RealTable
import dk.sdu.mmmi.typescriptdsl.Extendable
import dk.sdu.mmmi.typescriptdsl.TypescriptdslPackage.Literals

class TypescriptdslScopeProvider extends AbstractTypescriptdslScopeProvider {
	
	override getScope(EObject object, EReference ref) {
		switch ref {
			case ref === Literals.TABLE_TYPE__TABLE || ref === Literals.REAL_TABLE__SUPER_TYPE: {
				val extendable = EcoreUtil2.getContainerOfType(object, Extendable)
				val tables = newArrayList()
				if (extendable instanceof dk.sdu.mmmi.typescriptdsl.Module) {
					if (extendable.generic !== null) tables.add(extendable.generic)
				}
				extendable.getTables(tables, newHashSet)
				return Scopes.scopeFor(tables)
			}
			case Literals.FIELD__ATTR: {
				val table = EcoreUtil2.getContainerOfType(object, Table)
				val attrs = newArrayList()
				table.getAttributes(attrs, newHashSet)
				return Scopes.scopeFor(attrs)
			}
			
		}
		return super.getScope(object, ref)		
	}
	
	def void getTables(Extendable extendable, List<Table> tables, Set<Extendable> visited) {
		if (extendable === null || visited.contains(extendable)) { return }
		visited.add(extendable)
		tables.addAll(extendable.tables)
		extendable.modules.forEach[it.module.getTables(tables, visited)]
	}
	
	
	def void getAttributes(Table table, List<Attribute> attrs, Set<RealTable> visited)  {
		if (table !== null && table instanceof RealTable && !visited.contains(table)) {
			val real = table as RealTable
			visited.add(real)
			attrs.addAll(real.attributes)
			real.superType.getAttributes(attrs, visited)
		}
	}
}