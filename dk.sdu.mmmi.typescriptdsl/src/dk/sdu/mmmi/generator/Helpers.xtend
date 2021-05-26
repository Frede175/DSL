package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Table
import java.util.ArrayList
import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.ModuleRefernce
import java.util.List
import dk.sdu.mmmi.typescriptdsl.Database
import dk.sdu.mmmi.typescriptdsl.TableType

class Helpers {
	
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
		if (table.superType !== null) return table.superType.primaryKey
		val primaries = table.attributes.filter[it.primary]
		if (primaries.size == 0) throw new Exception('''No primary key for table «table.name»''')
		if (primaries.size > 1) throw new Exception('''Only one primary key can be defined for «table.name»''')
		primaries.head
	}
	
	static def void getTablesAndRewrite(Database database, List<Table> tables)	{
		tables.addAll(database.tables)
		database.modules.forEach[it.getTablesAndRewrite(tables)]
	}
	
	static def void getTablesAndRewrite(ModuleRefernce ref, List<Table> tables)	{
		if (ref.type !== null) {
			// this is a typed called to a generic, rewrite the parameter reference to use the real table
			val parameter = ref.module.generic
			/*ref.module.tables.forEach[(it as Table).attributes.forEach[{
				if (it.type instanceof TableType && (it.type as TableType).table === parameter) {
					(it.type as TableType).table = ref.type
				}
			}]] 
			*/
		}
		tables.addAll(ref.module.tables)
		ref.module.modules.forEach[it.getTablesAndRewrite(tables)]
		
	}
}

