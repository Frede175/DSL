package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.And
import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.CompareConstraint
import dk.sdu.mmmi.typescriptdsl.Constraint
import dk.sdu.mmmi.typescriptdsl.Div
import dk.sdu.mmmi.typescriptdsl.Expression
import dk.sdu.mmmi.typescriptdsl.Field
import dk.sdu.mmmi.typescriptdsl.Minus
import dk.sdu.mmmi.typescriptdsl.Mult
import dk.sdu.mmmi.typescriptdsl.NumberExp
import dk.sdu.mmmi.typescriptdsl.Or
import dk.sdu.mmmi.typescriptdsl.Parenthesis
import dk.sdu.mmmi.typescriptdsl.Plus
import dk.sdu.mmmi.typescriptdsl.RegexConstraint
import java.util.HashSet
import java.util.List
import java.util.Set

import static extension dk.sdu.mmmi.generator.Helpers.*
import dk.sdu.mmmi.typescriptdsl.RealTable

class ConstraintGenerator implements IntermediateGenerator {
	
	override generate(List<RealTable> tables) '''
		type Constraints<T> = { [key in keyof T]?: (value: T) => boolean }
		
		function isNullOrUndefined(value: unknown): boolean {
			return value === undefined || value === null
		}
		
		export const constraints: { [key in keyof Client]?: Constraints<any> } = {
			«FOR t: tables.filter[attributes.exists[constraint !== null]] SEPARATOR ','»
			«t.generateConstraints»
			«ENDFOR»
		}
	'''
	
	def generateConstraints(RealTable table) '''
		«table.name.toCamelCase»: {
			«FOR a: table.attributes.filter[it.constraint !== null] SEPARATOR ','» 
			«a.generateAttributeConstraints»
			«ENDFOR»
		}
	'''
	
	def generateAttributeConstraints(Attribute attribute) {
		val fields = attribute.constraint.findFields(attribute, new HashSet<String>())
		
		'''
		«attribute.name»: value => {
			«IF !fields.empty»
			if («FOR a: fields SEPARATOR ' || '»isNullOrUndefined(value.«a»)«ENDFOR») return false«»
			«ENDIF»
			return «attribute.constraint.constraints(attribute)»
		}'''
	}
	
	def CharSequence constraints(Constraint cons, Attribute current) {
		switch cons {
			RegexConstraint: '''new RegExp(/«cons.value»/g).test(value.«current.name»)'''
			CompareConstraint: '''«cons.left.printExp» «cons.operator» «cons.right.printExp»'''
			Or: '''«cons.left.constraints(current)» || «cons.right.constraints(current)»'''
			And: '''«cons.left.constraints(current)» && «cons.right.constraints(current)»'''
			default: "unknown"
		}
	}
	
	def CharSequence printExp(Expression exp) {
		switch exp {
			Plus: '''«exp.left.printExp» + «exp.right.printExp»'''
			Minus: '''«exp.left.printExp» - «exp.right.printExp»'''
			Mult: '''«exp.left.printExp» * «exp.right.printExp»'''
			Div: '''«exp.left.printExp» / «exp.right.printExp»'''
			Parenthesis: '''(«exp.exp.printExp»)'''
			NumberExp: '''«exp.value»'''
			Field: '''value.«exp.attr.name»'''
			default: throw new Exception()
		}
	}
	
	def Set<String> findFields(Constraint con, Attribute current, Set<String> fields) {
		switch con {
			CompareConstraint: {
				con.left.extractFields(fields)
				con.right.extractFields(fields)
			}
			RegexConstraint: {
				fields.add(current.name)
			}
			Or: {
				con.left.findFields(current, fields)
				con.right.findFields(current, fields)
			},
			And: {
				con.left.findFields(current, fields)
				con.right.findFields(current, fields)
			}
		}
		fields
	}
	
	def void extractFields(Expression exp, Set<String> fields) {
		switch exp {
			Plus: { exp.left.extractFields(fields); exp.right.extractFields(fields) }
			Minus: { exp.left.extractFields(fields); exp.right.extractFields(fields) }
			Mult: { exp.left.extractFields(fields); exp.right.extractFields(fields) }
			Div: { exp.left.extractFields(fields); exp.right.extractFields(fields) }
			Parenthesis: exp.exp.extractFields(fields)
			Field: fields.add(exp.attr.name)
		}
	}
} 