package dk.sdu.mmmi.validation

import dk.sdu.mmmi.typescriptdsl.Attribute
import org.eclipse.xtext.validation.Check
import dk.sdu.mmmi.typescriptdsl.TableType
import dk.sdu.mmmi.typescriptdsl.TypescriptdslPackage.Literals
import dk.sdu.mmmi.typescriptdsl.Table
import dk.sdu.mmmi.typescriptdsl.GenericTable
import dk.sdu.mmmi.typescriptdsl.RealTable
import dk.sdu.mmmi.typescriptdsl.ModuleRefernce

class RelationValidator extends AbstractTypescriptdslValidator {
	
	@Check
	def validateManyReference(Attribute attr) {
		if (attr.many && attr.type instanceof TableType) {
			val tableType = attr.type as TableType
			
			if (tableType.table instanceof GenericTable) {
				// validateManyReferenceGeneric is used
				return
			}
			
			val table = attr.eContainer as Table
			val tableRef = tableType.table as RealTable
			val exists = tableRef.attributes.filter[it.type instanceof TableType && (it.type as TableType).table === table]
			if (exists.length == 0) {
				val refTable = tableType.table
				error('''Table «refTable.name» does not define an reference to table «table.name» that has defined a one-to-many relation ship.''', refTable, Literals.REAL_TABLE__ATTRIBUTES)
			}
		} else if (attr.many) {
			error('''Attribute can not define a one-to-many relation ship on a non table type''', Literals.ATTRIBUTE__MANY)
		}
	}
	
	
	 @Check
	 def validateManyReferenceGeneric(ModuleRefernce ref) {
	 	if (ref.type === null) { return }
	 	val module = ref.module
	 	val tables = module.tables.filter[attributes.exists[it.many && it.type instanceof TableType && (it.type as TableType).table === module.generic]]
	 	tables.forEach[
	 		error('''Table «ref.type.name» does not define an reference to table «it.name» that has defined a one-to-many relation ship.''', ref.type, Literals.REAL_TABLE__ATTRIBUTES)
	 	]
	 }
}