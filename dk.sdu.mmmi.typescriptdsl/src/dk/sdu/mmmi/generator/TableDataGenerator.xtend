package dk.sdu.mmmi.generator


import java.util.List

import static extension dk.sdu.mmmi.generator.Helpers.*
import dk.sdu.mmmi.typescriptdsl.RealTable

class TableDataGenerator implements IntermediateGenerator {
	
	override generate(List<RealTable> tables) {		
		tables.generateTablesTypes
	}
	
	private def generateTablesTypes(List<RealTable> tables) '''
		export interface TableData {
			typeName: string
			tableName: string
			primaryKey: string
		}
		
		export const tableData: Record<keyof Client, TableData> = {
			«FOR t: tables SEPARATOR ','»
			«t.generateTable»
			«ENDFOR»
		}
	'''
	
	private def generateTable(RealTable table) '''
		«table.name.toCamelCase»: {
			typeName: '«table.name.toCamelCase»',
			tableName: '«table.name.toSnakeCase»',
			primaryKey: '«table.primaryKey.name.toSnakeCase»'
		}
	'''
}