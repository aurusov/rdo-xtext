package ru.bmstu.rk9.rdo.compilers

import java.util.List

import org.eclipse.emf.ecore.EObject

import static extension ru.bmstu.rk9.rdo.generator.RDONaming.*
import static extension ru.bmstu.rk9.rdo.generator.RDOExpressionCompiler.*

import static extension ru.bmstu.rk9.rdo.compilers.RDOEnumCompiler.*
import static extension ru.bmstu.rk9.rdo.compilers.Util.*

import ru.bmstu.rk9.rdo.generator.LocalContext

import ru.bmstu.rk9.rdo.rdo.ResourceType
import ru.bmstu.rk9.rdo.rdo.ResourceTypeParameter
import ru.bmstu.rk9.rdo.rdo.RDORTPParameterType
import ru.bmstu.rk9.rdo.rdo.RDORTPParameterBasic
import ru.bmstu.rk9.rdo.rdo.RDORTPParameterEnum
import ru.bmstu.rk9.rdo.rdo.RDORTPParameterSuchAs
import ru.bmstu.rk9.rdo.rdo.RDORTPParameterString
import ru.bmstu.rk9.rdo.rdo.RDORTPParameterArray

import ru.bmstu.rk9.rdo.rdo.ResourceDeclaration

import ru.bmstu.rk9.rdo.rdo.RDOInteger
import ru.bmstu.rk9.rdo.rdo.RDOReal
import ru.bmstu.rk9.rdo.rdo.RDOBoolean
import ru.bmstu.rk9.rdo.rdo.RDOEnum
import ru.bmstu.rk9.rdo.rdo.RDOString
import ru.bmstu.rk9.rdo.rdo.RDOArray


class RDOResourceTypeCompiler
{
	private static var chunkstart = 0;
	private static var chunknumber = 0;

	def public static compileResourceType(ResourceType rtp, String filename, Iterable<ResourceDeclaration> instances)
	{
		'''
		package «filename»;

		import java.nio.ByteBuffer;

		import java.util.Collection;
		import java.util.LinkedList;
		import java.util.ArrayList;
		import java.util.HashMap;

		import ru.bmstu.rk9.rdo.lib.*;
		@SuppressWarnings("all")

		public class «rtp.name» implements «rtp.type.literal.withFirstUpper»Resource, ResourceComparison<«rtp.name»>
		{
			private static «rtp.type.literal.withFirstUpper
				»ResourceManager<«rtp.name»> managerCurrent;

			private String name;

			@Override
			public String getName()
			{
				return name;
			}

			@Override
			public String getTypeName()
			{
				return "«rtp.fullyQualifiedName»";
			}

			«IF rtp.type.literal == "temporary"»
			private Integer number = null;

			@Override
			public Integer getNumber()
			{
				return number;
			}

			«ENDIF»
			public void register(String name)
			{
				this.name = name;
				managerCurrent.addResource(this);
			}

			«IF rtp.type.literal == "temporary"»
			public void register()
			{
				this.number = managerCurrent.getNextNumber();
				managerCurrent.addResource(this);
			}

			«ENDIF»
			public static «rtp.name» getResource(String name)
			{
				return managerCurrent.getResource(name);
			}

			public static java.util.Collection<«rtp.name»> getAll()
			{
				return managerCurrent.getAll();
			}

			«IF rtp.type.literal == "temporary"»
			public static Collection<«rtp.name»> getTemporary()
			{
				return managerCurrent.getTemporary();
			}

			public static void eraseResource(«rtp.name» res)
			{
				managerCurrent.eraseResource(res);
			}

			«ENDIF»
			private «rtp.type.literal.withFirstUpper»ResourceManager<«rtp.name»> managerOwner = managerCurrent;

			public static void setCurrentManager(«rtp.type.literal.withFirstUpper»ResourceManager<«rtp.name»> manager)
			{
				managerCurrent = manager;
			}

			«IF rtp.eAllContents.filter(typeof(RDOEnum)).toList.size > 0»// ENUMS«ENDIF»
			«FOR e : rtp.eAllContents.toIterable.filter(typeof(RDOEnum))»
				public enum «e.getEnumParentName(false)»_enum
				{
					«e.makeEnumBody»
				}

			«ENDFOR»
			«FOR parameter : rtp.parameters»
				private «parameter.type.compileType» «parameter.name»«parameter.type.getDefault»;

				public «parameter.type.compileType» get_«parameter.name»()
				{
					return «parameter.name»;
				}

				public «parameter.type.compileType» set_«parameter.name»(«parameter.type.compileType» «parameter.name»)
				{
					if (managerOwner == managerCurrent)
						this.«parameter.name» = «parameter.name»;
					else
						this.copyForNewOwner().«parameter.name» = «parameter.name»;

					return «parameter.name»;
				}

				public «parameter.type.compileType» set_«parameter.name»_after(«parameter.type.compileType» «parameter.name»)
				{
					«parameter.type.compileTypePrimitive» copy = this.«parameter.name»;

					set_«parameter.name»(«parameter.name»);

					return copy;
				}

			«ENDFOR»
			private «rtp.name» copyForNewOwner()
			{
				«rtp.name» copy = new «rtp.name»(«rtp.parameters.compileResourceTypeParametersCopyCall»);
				if (name != null)
				{
					copy.name = name;
					managerCurrent.addResource(copy);
					return copy;
				}
				«IF rtp.type.literal == "temporary"»
				if (number != null)
				{
					copy.number = number;
					managerCurrent.addResource(copy);
					return copy;
				}
				«ENDIF»
				return null;
			}

			public «rtp.name»(«rtp.parameters.compileResourceTypeParameters»)
			{
				«FOR parameter : rtp.parameters»
					if («parameter.name» != null)
						this.«parameter.name» = «parameter.name»;
				«ENDFOR»
			}

			@Override
			public boolean checkEqual(«rtp.name» other)
			{
				«FOR parameter : rtp.parameters»
					if (this.«parameter.name» != other.«parameter.name»)
						return false;
				«ENDFOR»

				return true;
			}

			public final static ResourceStructure structure;
			static
			{
				ArrayList<ResourceStructure.Parameter> parameters =
					new ArrayList<ResourceStructure.Parameter>();
				HashMap<String, ResourceStructure.ChunkParameter> chunks =
					new HashMap<String, ResourceStructure.ChunkParameter>();
				HashMap<String, Enum<?>[]> enums =
					new HashMap<String, Enum<?>[]>();
				«rtp.parameters.compileParameterStructure»
			}

			private boolean traceState = false;

			public void setTraceState(boolean state)
			{
				this.traceState = state;
			}

			@Override
			public boolean isBeingTraced()
			{
				return traceState;
			}

			@Override
			public ByteBuffer createTracerEntry(int reserve)
			{
				int size = reserve + «chunkstart + chunknumber * basicSizes.INT»;
				«rtp.parameters.filter
				[ p |
					val type = p.type.compileType
					if(type == "String" || type.startsWith("java.util.ArrayList"))
						return true
					else
						return false
				].compileBufferCalculation»

				ByteBuffer entry = ByteBuffer.allocateDirect(size);
				entry.position(reserve);

				«rtp.parameters.compileSerialization»

				return entry;
			}
		}
		'''
	}

	def public static compileResourceTypeParametersCopyCall(List<ResourceTypeParameter> parameters)
	{
		'''«IF parameters.size > 0»«
			parameters.get(0).name»«
			FOR parameter : parameters.subList(1, parameters.size)», «
				parameter.name»«
			ENDFOR»«
		ENDIF»'''
	}

	private static class basicSizes
	{
		static val INT = 4
		static val DOUBLE = 8
		static val BOOL = 1
		static val ENUM = 2
	}

	def private static String compileParameterStructure(Iterable<ResourceTypeParameter> parameters)
	{
		var ret =
			'''

				ResourceStructure.ChunkParameter chunk;

			'''
		var offset = 0
		var chunkindex = 1;
		
		for(p : parameters)
		{
			val type = p.compileType
			
			if(type == "Integer")
			{
				ret = ret + '''

					parameters.add(new ResourceStructure.Parameter
					(
						"«p.name»",
						ResourceStructure.DataType.INTEGER,
						«offset»
					));
					'''
				offset = offset + basicSizes.INT
			}
			if(type == "Double")
			{
				ret = ret + '''

					parameters.add(new ResourceStructure.Parameter
					(
						"«p.name»",
						ResourceStructure.DataType.REAL,
						«offset»
					));
					'''
				offset = offset + basicSizes.DOUBLE
			}
			if(type == "Boolean")
			{
				ret = ret + '''

					parameters.add(new ResourceStructure.Parameter
					(
						"«p.name»",
						ResourceStructure.DataType.BOOL,
						«offset»
					));
					'''
				offset = offset + basicSizes.BOOL
			}
			if(type.endsWith("_enum"))
			{
				ret = ret + '''

					parameters.add(new ResourceStructure.Parameter
					(
						"«p.name»",
						ResourceStructure.DataType.ENUM,
						«offset»
					));

					enums.put("«p.name»", «p.name»_enum.values());
					'''
				offset = offset + basicSizes.ENUM
			}
			if(type.startsWith("java.util.ArrayList"))
			{
				ret = ret + '''

					chunk = new ResourceStructure.ChunkParameter
					(
						"«p.name»",
						«p.arrayType»,
						«chunkindex»,
						«p.arrayDepth»
					);
					parameters.add(chunk);
					chunks.put("«p.name»", chunk);
					'''
				chunkindex = chunkindex + 1
			}
			if(type == "String")
			{
				ret = ret + '''

					chunk = new ResourceStructure.ChunkParameter
					(
						"«p.name»",
						ResourceStructure.DataType.STRING,
						«chunkindex»,
						0
					);
					parameters.add(chunk);
					chunks.put("«p.name»", chunk);
					'''
				chunkindex = chunkindex + 1
			}
		}

		ret = ret +
			'''

				structure = new ResourceStructure(parameters, «offset», chunks, enums);
			'''

		chunkstart = offset
		chunknumber = chunkindex - 1

		return ret
	}

	def private static String compileBufferCalculation(Iterable<ResourceTypeParameter> parameters)
	{
		var ret = ""

		for(p : parameters)
		{
			var typename = p.compileType
			val depth = p.arrayDepth
			ret = ret + "\n"
			for(i : 0 ..< depth - 1)
			{
				typename = typename.substring("java.util.ArrayList<".length, typename.length - 1)
				ret = ret + '''
					«i.TABS»size += «basicSizes.INT» * («IF i == 0»«p.name»«ELSE»inner«i - 1»«ENDIF».size() + 1);
					«i.TABS»for(«typename» inner«i» : «IF i == 0»«p.name»«ELSE»inner«i - 1»«ENDIF»)
					«i.TABS»{
					'''
			}

			if(depth > 0)
			{
				typename = typename.substring("java.util.ArrayList<".length, typename.length - 1)
				ret = ret + '''
				«(depth - 1).TABS»size += «basicSizes.INT» + «IF typename == "Integer"
					»«basicSizes.INT» * «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF».size();«
				ENDIF»«
				IF typename == "Double"
					»«basicSizes.DOUBLE» * «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF».size();«
				ENDIF»«
				IF typename == "Boolean"
					»«basicSizes.BOOL» * «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF».size();«
				ENDIF»«
				IF typename.endsWith("_enum")
					»«basicSizes.ENUM» * «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF».size();«
				ENDIF»«
				IF typename == "String"
					»«basicSizes.INT» * «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF».size();
				«(depth - 1).TABS»for(String inner : «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF»)
				«(depth - 1).TABS»	size += «basicSizes.INT» + inner.length();«
				ENDIF»
				'''
			}
			else
			{
				ret = ret + '''
				«IF typename == "String"»size += «basicSizes.INT» + «p.name».length();
				«ENDIF»'''
			}

			for(i : 0 ..< depth - 1)
			{
				for(j : 0 ..< depth - i - 2)
					ret = ret + "\t"
				ret = ret + "}\n"
			}
		}

		return ret
	}

	def private static String compileSerialization(Iterable<ResourceTypeParameter> parameters)
	{
		var ret = ""
		val constsize = parameters.filter
			[ p |
				val type = p.type.compileType
				if(type == "String" || type.startsWith("java.util.ArrayList"))
					return false
				else
					return true
			]
		val chunks =  parameters.filter
			[ p |
				val type = p.type.compileType
				if(type == "String" || type.startsWith("java.util.ArrayList"))
					return true
				else
					return false
			]

		for(p : constsize)
		{
			val type = p.compileType

			if(type == "Integer")
				ret = ret + '''
					entry.putInt(«p.name»);
					'''
			if(type == "Double")
				ret = ret + '''
					entry.putDouble(«p.name»);
					'''
			if(type == "Boolean")
				ret = ret + '''
					entry.put(«p.name» ? (byte)1 : (byte)0);
					'''
			if(type.endsWith("_enum"))
				ret = ret + '''
					entry.putShort((short)«p.name».ordinal());
					'''
		}

		if(chunknumber > 0)
			ret = ret + '''
				int chunkstart = entry.position(); // «chunkstart»
				int cposition = chunkstart;
				int cnumber = 0;

				LinkedList<Integer> stack = new LinkedList<Integer>();
				stack.add(entry.position());

				entry.position(chunkstart + «basicSizes.INT * chunknumber»);
				'''

		var pnum = 0
		for(p : chunks)
		{
			var typename = p.compileType
			val depth = p.arrayDepth
			ret = ret + '''

				entry.putInt(stack.peekLast() + «basicSizes.INT * pnum», entry.position());
				{
				'''
			for(i : 0 ..< depth - 1)
			{
				typename = typename.substring("java.util.ArrayList<".length, typename.length - 1)
				ret = ret + '''
					«IF i > 0»
					«(i+1).TABS»int size«i - 1» = inner«i - 1».size();
					«(i+1).TABS»entry.putInt(size«i - 1»);
					«(i+1).TABS»stack.add(entry.position());
					«(i+1).TABS»entry.position(entry.position() + size«i - 1» * «basicSizes.INT»);
					«ENDIF»
					«(i+1).TABS»int counter«i» = 0;
					«(i+1).TABS»for(«typename» inner«i» : «IF i == 0»«p.name»«ELSE»inner«i - 1»«ENDIF»)
					«(i+1).TABS»{
					«(i+1).TABS»	entry.putInt(stack.peekLast() + (counter«i»++) * «basicSizes.INT», entry.position());
					'''
			}
			pnum = pnum + 1

			if(depth > 0)
			{
				typename = typename.substring("java.util.ArrayList<".length, typename.length - 1)
				ret = ret + '''
					«depth.TABS»int size«depth - 1» = «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF».size();
					«depth.TABS»entry.putInt(size«depth - 1»);
					«IF typename == "Integer"
						»«depth.TABS»for(Integer inner«depth - 1» : «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF»)
					«depth.TABS»	entry.putInt(inner«depth - 1»);«
					ENDIF»«
					IF typename == "Double"
						»«depth.TABS»for(Double inner«depth - 1» : «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF»)
					«depth.TABS»	entry.putDouble(inner«depth - 1»);«
					ENDIF»«
					IF typename == "Boolean"
						»«depth.TABS»for(Boolean inner«depth - 1» : «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF»)
					«depth.TABS»	entry.put(inner«depth - 1» ? (byte)1 : (byte)0);«
					ENDIF»«
					IF typename.endsWith("_enum")
						»«depth.TABS»for(«typename» inner«depth - 1» : «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF»)
					«depth.TABS»	entry.putShort((short)inner«depth - 1».ordinal());«
					ENDIF»«
					IF typename == "String"
						»«depth.TABS»stack.add(entry.position());
					«depth.TABS»entry.position(entry.position() + size«depth - 1» * «basicSizes.INT»);
					«depth.TABS»int counter = 0;
					«depth.TABS»for(String inner : «IF depth > 1»inner«depth - 2»«ELSE»«p.name»«ENDIF»)
					«depth.TABS»{
					«depth.TABS»	entry.putInt(stack.peekLast() + (counter++) * «basicSizes.INT», entry.position());
					«depth.TABS»	int size«depth» = inner.length();
					«depth.TABS»	entry.putInt(size«depth»);
					«depth.TABS»	entry.put(inner.getBytes());
					«depth.TABS»}
					«depth.TABS»stack.removeLast();«
					ENDIF»
					'''
			}
			else
			{
				ret = ret + '''
					«IF typename == "String"»	entry.putInt(«p.name».length());
						entry.put(«p.name».getBytes());
					«ENDIF»'''
			}

			for(i : 0 ..< depth - 1)
			{
				ret = ret + (depth - i - 1).TABS + "}\n" + 
					if(i < depth - 2) (depth - i - 1).TABS + "stack.removeLast();\n" else ""
			}

			ret = ret + "}\n"
		}

		return ret
	}

	def static String TABS(int number)
	{
		return '''«FOR i : 0 ..< number»	«ENDFOR»'''
	}

	def static int getArrayDepth(ResourceTypeParameter parameter)
	{
		var EObject type = parameter.type
		var depth = 0;

		while(type instanceof RDORTPParameterArray || type instanceof RDOArray)
		{
			if(type instanceof RDORTPParameterArray)
				type = (type as RDORTPParameterArray).type.arraytype
			else
				type = (type as RDOArray).arraytype
			depth = depth + 1
		}

		return depth
	}

	def static String getArrayType(ResourceTypeParameter parameter)
	{
		var EObject type = parameter.type

		while(type instanceof RDORTPParameterArray || type instanceof RDOArray)
			if(type instanceof RDORTPParameterArray)
				type = (type as RDORTPParameterArray).type.arraytype
			else
				type = (type as RDOArray).arraytype

		switch(type)
		{
			RDOInteger: return "ResourceStructure.DataType.INTEGER"
			RDOReal   : return "ResourceStructure.DataType.REAL"
			RDOBoolean: return "ResourceStructure.DataType.BOOL"
			RDOEnum   : return "ResourceStructure.DataType.ENUM"
			RDOString : return "ResourceStructure.DataType.STRING"
			default: return null
		}
	}

	def static String getDefault(RDORTPParameterType parameter)
	{
		switch parameter
		{
			RDORTPParameterBasic:
				return if(parameter.^default != null) " = " + parameter.^default.compileExpression.value else ""

			RDORTPParameterEnum:
				return if(parameter.^default != null) " = " + parameter.type.compileType + "." + parameter.^default.name else ""

			RDORTPParameterSuchAs:
				if(parameter.type.compileType.endsWith("_enum"))
					return if(parameter.^default != null) " = " + parameter.^default.compileExpressionContext((new LocalContext).
						populateWithEnums(parameter.type.resolveAllSuchAs as RDOEnum)).value else ""
				else
					return if(parameter.^default != null) " = " + parameter.^default.compileExpression.value else ""

			RDORTPParameterString:
				return if (parameter.^default != null) ' = "' + parameter.^default + '"' else ""

			default:
				return ""
		}
	}

	def public static compileResourceTypeParameters(List<ResourceTypeParameter> parameters)
	{
		'''«IF parameters.size > 0»«parameters.get(0).type.compileType» «
			parameters.get(0).name»«
			FOR parameter : parameters.subList(1, parameters.size)», «
				parameter.type.compileType» «
				parameter.name»«
			ENDFOR»«
		ENDIF»'''
	}
}