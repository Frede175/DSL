package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.DateType
import dk.sdu.mmmi.typescriptdsl.IntType
import dk.sdu.mmmi.typescriptdsl.StringType
import dk.sdu.mmmi.typescriptdsl.TableType
import dk.sdu.mmmi.typescriptdsl.AttributeType
import java.util.List

import static extension dk.sdu.mmmi.generator.Helpers.*
import dk.sdu.mmmi.typescriptdsl.RealTable

class TableTypeGenerator implements IntermediateGenerator {
	override generate(List<RealTable> tables) {
		tables.map[generateTypes].join("\n")
	}
	
	private def CharSequence generateTypes(RealTable table) {
		newArrayList(
			table.generateTable,
			table.generateFindArgs,
			table.generateSelect,
			table.generateInclude,
			table.generateGetPayload,
			table.generateCreateInputType
		).join('\n')
	}
	
	private def hasRelations(RealTable table) {
		table.attributes.exists[it | it.type instanceof TableType]
	}
	
	private def generateTable(RealTable table) '''
		export type «table.name» = «IF table.superType !== null»«table.superType.name» & «ENDIF»{
			«FOR a: table.attributes»
			«a.generateAttribute»
			«ENDFOR»
		}
	'''
	
	private def generateFindArgs(RealTable table) '''
		export type «table.name»Args = {
			where?: WhereInput<«table.name»>
			select?: «table.name»Select | null
			«IF table.hasRelations»include?: «table.realTable.name»Include | null«ENDIF»
		}
	'''
	
	private def generateInclude(RealTable table) {
		if (!table.hasRelations) return ''
		'''
		export type «table.name»Include = {
			«FOR a: table.attributes.filter[it | it.type instanceof TableType]»
			«a.name»?: boolean | «(a.type as TableType).table.realTable.name + "Args"»
			«ENDFOR»
		}
		'''
	}
	
	private def generateSelect(RealTable table) '''
		export type «table.name»Select = {
			«FOR a: table.attributes.filter[!(type instanceof TableType)]»
			«a.name»?: boolean
			«ENDFOR»
		}
	'''
	
	private def getAttributeTypeAsString(AttributeType type) {
		switch type {
			IntType: 'number'
			StringType: 'string'
			DateType: 'Date'
			default: 'unknown'
		}
	}

	
	private def generateAttribute(Attribute attribute) {
		if (attribute.type instanceof TableType) return ""
		
		val typeName = attribute.type.attributeTypeAsString
		
		'''«attribute.name»: «typeName»«attribute.many ? '[]'»«attribute.optional ? ' | null'»'''
	}
	
	private def generateGetPayload(RealTable table) {
		val hasRelations = table.hasRelations
		'''
		export type «table.name»GetPayload<
			S extends boolean | null | undefined | «table.name»Args,
			U = keyof S
		> = S extends true
			? «table.name» : S extends undefined
				? never : S extends «table.name»Args
					? «hasRelations ? table.generatePayloadInclude : table.generatePayloadSelect»
					«hasRelations ? ': ' + table.generatePayloadSelect»
			: «table.name»
		'''
	}
	
	private def generatePayloadInclude(RealTable table) {
		if (!table.hasRelations) return ''
		'''
		'include' extends U
			? «table.name» & {
				[P in TrueKeys<S['include']>] :
				«FOR a: table.attributes.filter[it.type instanceof TableType]»
				P extends '«a.name»' ? «a.many ? 'Array<'»«(a.type as TableType).table.realTable.name.toPascalCase»GetPayload<S['include'][P]>«a.many ? '>'» «a.optional ? '| null'» :
				«ENDFOR»
				never
			}
		'''
	}
	
	private def generatePayloadSelect(RealTable table) '''
		'select' extends U
		? {
			[P in TrueKeys<S['select']>]: P extends keyof «table.name» ? «table.name»[P] :
			«FOR a: table.attributes.filter[it.type instanceof TableType]»
				P extends '«a.name»' ? «(a.type as TableType).table.realTable.name.toPascalCase»GetPayload<S['select'][P]> «a.optional ? '| null'» :
			«ENDFOR»
			never
		} : «table.name»
	'''
	
	private def generateCreateInputType(RealTable table) '''
		export type «table.name»CreateInput = {
			«FOR a: table.attributes.filter[!it.many]»
			«a.generateAttributeInput»
			«ENDFOR»
		}
	'''
	
	private def generateAttributeInput(Attribute attr) {
		var name = attr.name
		var type = attr.type
		if (attr.type instanceof TableType) {
			val table = (attr.type as TableType).table
			val primary = table.primaryKey
			name = '''«table.name.toCamelCase»«primary.name.toPascalCase»'''
			type = primary.type
		}
		
		val optional = attr.optional || attr.primary && attr.type instanceof IntType
		
		'''«name»«IF optional»?«ENDIF»: «type.attributeTypeAsString»«IF attr.optional» | null«ENDIF»'''
	}
}