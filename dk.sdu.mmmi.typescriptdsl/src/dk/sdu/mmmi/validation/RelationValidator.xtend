package dk.sdu.mmmi.validation

import dk.sdu.mmmi.typescriptdsl.Attribute
import org.eclipse.xtext.validation.Check
import dk.sdu.mmmi.typescriptdsl.TableType
import dk.sdu.mmmi.typescriptdsl.TypescriptdslPackage.Literals
import dk.sdu.mmmi.typescriptdsl.Table

class RelationValidator extends AbstractTypescriptdslValidator {
	
	@Check
	def validateManyReference(Attribute attr) {
		if (attr.many && attr.type instanceof TableType) {
			val tableType = attr.type as TableType
			val table = attr.eContainer as Table
			val exists = tableType.table.attributes.filter[it.type instanceof TableType && (it.type as TableType).table === table]
			if (exists.length == 0) {
				val refTable = tableType.table
				error('''Table «refTable.name» does not define an reference to table «table.name» that has defined a one-to-many relation ship.''', refTable, Literals.TABLE__ATTRIBUTES)
			}
		} else if (attr.many) {
			error('''Attribute can not define a one-to-many relation ship on a non table type''', Literals.ATTRIBUTE__MANY)
		}
	}
}