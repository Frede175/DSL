package dk.sdu.mmmi.validation

import dk.sdu.mmmi.typescriptdsl.And
import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.CompareConstraint
import dk.sdu.mmmi.typescriptdsl.Constraint
import dk.sdu.mmmi.typescriptdsl.Div
import dk.sdu.mmmi.typescriptdsl.Expression
import dk.sdu.mmmi.typescriptdsl.Field
import dk.sdu.mmmi.typescriptdsl.Minus
import dk.sdu.mmmi.typescriptdsl.Mult
import dk.sdu.mmmi.typescriptdsl.Or
import dk.sdu.mmmi.typescriptdsl.Parenthesis
import dk.sdu.mmmi.typescriptdsl.Plus
import java.util.List
import org.eclipse.xtext.validation.Check
import dk.sdu.mmmi.typescriptdsl.TypescriptdslPackage
import dk.sdu.mmmi.typescriptdsl.IntType
import dk.sdu.mmmi.typescriptdsl.GenericTable
import dk.sdu.mmmi.typescriptdsl.RealTable

class ConstraintValidator extends AbstractTypescriptdslValidator {
	
	@Check
	def validateField(Field field) {
		if (!(field.attr.type instanceof IntType)) 
			error('''Attribute «field.attr.name» is not of type int''', TypescriptdslPackage.Literals.FIELD__ATTR)		
	}
	
	@Check
	def validateConstraint(Attribute attr) {
		val List<CompareConstraint> compares = newArrayList()
		attr.constraint.extractListOfCompareConstraints(compares)
		compares.forEach[
			val list = countFields
			if (!list.exists[exists[it === attr.name]]) {
				error('''Attribute «attr.name» is not used in constraint''', TypescriptdslPackage.Literals.ATTRIBUTE__CONSTRAINT)	
			}
		]
	}
	
	@Check
	def void validatePrimary(RealTable table) {
		if (table instanceof GenericTable) return
		val primaries = table.attributes.filter[it.primary]
		
		if (!primaries.empty && table.superType !== null) {
			error('''Table «table.name» cannot have a primary key when extending another table.''', TypescriptdslPackage.Literals.TABLE__NAME)
		}
		
		if (primaries.empty && table.superType === null) {
			error('''Table «table.name» does not contain a primary key.''', TypescriptdslPackage.Literals.TABLE__NAME)
		}
		
		if (primaries.length > 1) {
			error('''Table «table.name» contains more than one primary key.''', TypescriptdslPackage.Literals.TABLE__NAME)
		}
	}
	
	
	def void extractListOfCompareConstraints(Constraint con, List<CompareConstraint> list) {
		switch con {
			Or: { con.left.extractListOfCompareConstraints(list); con.right.extractListOfCompareConstraints(list) }
			And: { con.left.extractListOfCompareConstraints(list); con.right.extractListOfCompareConstraints(list) }
			CompareConstraint: list.add(con)
		}
	}
	
	def countFields(CompareConstraint con) {
		val List<String> left = newArrayList()
		val List<String> right = newArrayList()
		con.left.extractFields(left)
		con.right.extractFields(right)
		return #[left, right]
	}
	
	def void extractFields(Expression exp, List<String> list) {
		switch exp {
			Plus: { exp.left.extractFields(list); exp.right.extractFields(list) }
			Minus: { exp.left.extractFields(list); exp.right.extractFields(list) }
			Mult: { exp.left.extractFields(list); exp.right.extractFields(list) }
			Div: { exp.left.extractFields(list); exp.right.extractFields(list) }
			Parenthesis: exp.exp.extractFields(list)
			Field: list.add(exp.attr.name)
		}
	}
}