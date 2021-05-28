package dk.sdu.mmmi.generator

import java.util.List

import static extension dk.sdu.mmmi.generator.Helpers.toCamelCase
import dk.sdu.mmmi.typescriptdsl.RealTable

class DelegateGenerator implements IntermediateGenerator {
	
	override generate(List<RealTable> tables) '''
		type ClientPromise<T, Args, Payload> = CheckSelect<Args, Promise<T | null>, Promise<Payload | null>>

		«FOR t: tables SEPARATOR '\n'»
		«t.generateDelegate»
		«ENDFOR»
		
		«generateClient(tables)»
	'''
	
	private def generateDelegate(RealTable table) '''
		interface «table.name»Delegate {
			findFirst<T extends «table.name»Args>(args: SelectSubset<T, «table.name»Args>): ClientPromise<«table.name», T, «table.name»GetPayload<T>>
			delete(where: WhereInput<«table.name»>): Promise<number>
			create(data: «table.name»CreateInput): Promise<«table.name»>
			update(args: { where: WhereInput<«table.name»>, data: Partial<«table.name»CreateInput> }): Promise<«table.name»>
		}
	'''
	
	private def generateClient(List<RealTable> tables) '''
		export interface Client {
			«FOR t: tables»
			«t.name.toCamelCase»: «t.name»Delegate
			«ENDFOR»
		}	
	'''
}