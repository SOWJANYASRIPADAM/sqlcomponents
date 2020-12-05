<#assign importStatementsList = []>

<#function getClassName str> 
	<#return str?split(".")?last>
</#function>

<#function getJDBCClassName str> 
	<#local pkAsParameterStr="${getClassName(str)}">
	<#if pkAsParameterStr == "Integer">
			<#local pkAsParameterStr="Int">
	<#elseif pkAsParameterStr == "Character">
	    <#local pkAsParameterStr="String">
	</#if>
	<#return pkAsParameterStr>
</#function>

<#function wrapSet wText property >
<#switch property.dataType>
  <#case "java.util.Date">
	 <#return "${wText}.get${property.name?cap_first}() == null ? null : new java.sql.Date(${wText}.get${property.name?cap_first}().getTime())">
  <#case "java.lang.Character">
  	 <#return "String.valueOf(${wText}.get${property.name?cap_first}())">
  <#default>
  <#return "${wText}.get${property.name?cap_first}()">
</#switch>
</#function>

<#function wrapGet wText property >
<#switch property.dataType>
  <#case "java.util.Date">
	 <#return "${wText}.get${property.name?cap_first}() == null ? null : new java.sql.Date(${wText}.get${property.name?cap_first}().getTime())">
  <#case "java.lang.Character">
  	 <#return "${wText} == null ? null : ${wText}.charAt(0)">
  <#default>
  <#return "${wText}">
</#switch>
</#function>

<#function getProperty propertyName> 
	<#list properties as property>
		<#if property.name == propertyName>
			<#return property> 
		</#if>
	</#list>
	<#return null> 
</#function>

<#function getNullablePropsAsParameterString>
	<#local pkAsParameterStr="">
	<#local index=0>
	<#list properties as property>
		<#if property.column.nullable>
			<#if index == 0>
				<#local index=1>
			<#else>
				<#local pkAsParameterStr = pkAsParameterStr + "," >
			</#if>
			<#local pkAsParameterStr = pkAsParameterStr +"Boolean isNull" +property.name?cap_first >			
		</#if>
	</#list>
	<#return pkAsParameterStr> 
</#function>

<#function getPrimaryKeysAsParameterString>
	<#local pkAsParameterStr="">
	<#local index=0>
	<#list properties as property>
		<#if property.column.primaryKeyIndex != 0>
			<#if index == 0>
				<#local index=1>
			<#else>
				<#local pkAsParameterStr = pkAsParameterStr + "," >
			</#if>

			<#local pkAsParameterStr = pkAsParameterStr + getClassName(property.dataType) + " " +property.name >
			<#local a=addImportStatement(property.dataType)>
		</#if>
	</#list>
	<#return pkAsParameterStr> 
</#function>

<#function getPrimaryKeysFromModel nameOfObject>
	<#local pkAsParameterStr="">
	<#local index=0>
	<#list properties as property>
		<#if property.column.primaryKeyIndex != 0>
			<#if index == 0>
				<#local index=1>
			<#else>
				<#local pkAsParameterStr = pkAsParameterStr + "," >
			</#if>

			<#local pkAsParameterStr = pkAsParameterStr + nameOfObject + ".get"+ property.name?cap_first + "()" >
            <#local a=addImportStatement(property.dataType)>
		</#if>
	</#list>
	<#return pkAsParameterStr>
</#function>

<#function getPrimaryKeysFromRS>
	<#local pkAsParameterStr="">
	<#local index=0>
	<#list properties as property>
		<#if property.column.primaryKeyIndex != 0>
			<#if index == 0>
				<#local index=1>
			<#else>
				<#local pkAsParameterStr = pkAsParameterStr + "," >
			</#if>

			<#local pkAsParameterStr = pkAsParameterStr + "res.get"+ getJDBCClassName(property.dataType) + "(\"" +property.column.columnName + "\")" >
            <#local a=addImportStatement(property.dataType)>
		</#if>
	</#list>
	<#return pkAsParameterStr>
</#function>


<#function getPrimaryKeysAsParameterStringExceptHighest>
	<#local pkAsParameterStr="">
	<#local index=0>
	<#list properties as property>
		<#if property.column.primaryKeyIndex != 0>
			<#if property.column.primaryKeyIndex != table.highestPKIndex>
				<#if index == 0>
					<#local index=1>
				<#else>
					<#local pkAsParameterStr = pkAsParameterStr + ",">
				</#if>
	
				<#local pkAsParameterStr = pkAsParameterStr + getClassName(property.dataType) + " " +property.name >
				<#local a=addImportStatement(property.dataType)>
			</#if>
		</#if>
	</#list>
	<#return pkAsParameterStr> 
</#function>


<#function addImportStatement importStatement>
<#if importStatement?contains(".") 
		&& !importStatement?contains("java.lang.")
		&& !importStatementsList?seq_contains(importStatement)>
<#assign importStatementsList = importStatementsList + [importStatement]>
</#if>
<#return "">
</#function>

<#macro importStatements>
<#list importStatementsList?sort as importStatement>
import ${importStatement};
</#list>
</#macro>

<#function getUniqueKeysAsParameterString uniqueConstraintGroupName>
	<#local pkAsParameterStr="">
	<#local index=0>
	<#list properties as property>		
		<#if property.uniqueConstraintGroup?? && property.uniqueConstraintGroup == uniqueConstraintGroupName>
			<#if index == 0>
				<#local index=1>
			<#else>
				<#local pkAsParameterStr = pkAsParameterStr + "," >
			</#if>
			<#local pkAsParameterStr = pkAsParameterStr + getClassName(property.dataType) + " " +property.name >
			<#local a=addImportStatement(property.dataType)>
		</#if>
	</#list>
	<#return pkAsParameterStr> 
</#function>
