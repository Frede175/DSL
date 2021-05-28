package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Table
import java.util.ArrayList
import dk.sdu.mmmi.typescriptdsl.Attribute
import java.util.List
import dk.sdu.mmmi.typescriptdsl.RealTable
import dk.sdu.mmmi.typescriptdsl.GenericTable
import dk.sdu.mmmi.typescriptdsl.Extendable

class Helpers {
	
	
	static def RealTable getRealTable(Table table) {
		if (table instanceof RealTable) return table
		return (table as GenericTable).real
	}
	
	/**
	 * Handle conversion from Pascal and Snake case
	 */
	static def toCamelCase(String input) {
		if (input === null || input.length == 0) return input
		
		if (input.contains('_')) {
			val words = input.split('_')
			return words.map[it.toFirstUpper].join.toFirstLower
		}
		return input.toFirstLower
	}
	
	/**
	 * Handle conversion from Camel and Snake case
	 */
	static def toPascalCase(String input) {
		if (input === null || input.length == 0) return input
		
		if (input.contains('_')) {
			val words = input.split('_')
			return words.map[it.toFirstUpper].join
		}
		return input.toFirstUpper
	}
	
	/**
	 * Handle conversion from Pascal and Camel case
	 */
	static def toSnakeCase(String input) {
		if (input === null || input.length == 0) return input
		val firstLower = input.toFirstLower
		
		var start = 0
		var words = new ArrayList<String>()
		
		for (var i = 0; i < firstLower.length; i++) {
			if (Character.isUpperCase(firstLower.charAt(i))) {
				words.add(firstLower.substring(start, i).toFirstLower)
				start = i
			}
		}
		words.add(firstLower.substring(start).toFirstLower)
		return words.join('_')
	}
	
	static def Attribute getPrimaryKey(Table table) {
		if (table.realTable.superType !== null) return table.realTable.superType.primaryKey
		val primaries = table.realTable.attributes.filter[it.primary]
		if (primaries.size == 0) throw new Exception('''No primary key for table «table.name»''')
		if (primaries.size > 1) throw new Exception('''Only one primary key can be defined for «table.name»''')
		primaries.head
	}
	
	static def void getTables(Extendable extendable, List<RealTable> tables)	{
		tables.addAll(extendable.tables)
		extendable.modules.forEach[it.module.getTables(tables)]
	}
}

