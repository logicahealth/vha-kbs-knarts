<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright © 2017, 2018 Cognitive Medical Systems Inc.
    
    All rights reserved. No part of this content may be reproduced, distributed, or transmitted in any form or by any means, including photocopying, 
    recording, or other electronic or mechanical methods, without the prior written permission of the publisher, except in the case of brief quotations 
    embodied in critical reviews and certain other noncommercial uses permitted by copyright law. 
    
    For permission requests, write to the publisher, addressed “Attention: Permissions Coordinator,” at the address below.
    9444 Waples Street, Suite 300 San Diego, CA 92121
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dt="urn:hl7-org:cdsdt:r2" xpath-default-namespace="urn:hl7-org:knowledgeartifact:r1"
    xmlns:elm="urn:hl7-org:elm:r1" xmlns:a="urn:hl7-org:cql-annotations:r1" xmlns:func="http://www.cognitivemedicine.com/xsl/functions" version="2.0"
    xmlns:t="urn:hl7-org:knowledgeartifact:temp" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:import href="knart-to-docbook-L2.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="gSuppressComments" select="true()"/>

    <!-- Prepare data sets for processing links and values -->
    <xsl:variable name="elmCodes" select="//elm:*[@xsi:type = 'elm:Code']"/>
    <xsl:variable name="otherCodes" select="//item[codes/code]"/>
    <xsl:variable name="otherItemCodes" select="//itemCodes[itemCode]"/>
    <xsl:variable name="valueCodes" select="//value[@code]"/>
    <xsl:variable name="conceptCodes" select="//representedConcepts/concept[@code]"/>
    <xsl:variable name="allCodes">
        <t:ac>
            <xsl:apply-templates select="$elmCodes" mode="normalizeElm"/>
            <xsl:apply-templates select="$otherCodes" mode="normalizeItem"/>
            <xsl:apply-templates select="$otherItemCodes" mode="normalizeItemCodes"/>
            <xsl:apply-templates select="$valueCodes" mode="normalizeValue"/>
            <xsl:apply-templates select="$conceptCodes" mode="normalizeConceptCodes"/>
        </t:ac>
    </xsl:variable>
    <xsl:variable name="allCodesIndex">
        <t:aci>
            <xsl:for-each-group select="$allCodes/t:ac/t:c" group-by="concat(@cs, '_', normalize-space(@code))">
                <xsl:sort select="@cs"/>
                <xsl:sort select="normalize-space(@code)"/>
                <xsl:element name="t:ci">
                    <xsl:attribute name="id" select="generate-id(current-group()[1])"/>
                    <xsl:attribute name="cs" select="current-group()[1]/@cs"/>
                    <xsl:attribute name="code" select="current-group()[1]/normalize-space(@code)"/>
                </xsl:element>
            </xsl:for-each-group>
        </t:aci>
    </xsl:variable>

    <xsl:variable name="allExpressions">
        <t:ae>
            <xsl:apply-templates select="/knowledgeDocument/expressions/def" mode="GatherExpressions"/>
            <xsl:apply-templates select="/knowledgeDocument/externalData/def" mode="GatherExpressions"/>
            <xsl:apply-templates select="/knowledgeDocument/externalData/trigger/def" mode="GatherExpressions"/>
        </t:ae>
    </xsl:variable>

    <xsl:template match="def" mode="GatherExpressions">
        <xsl:element name="t:e">
            <xsl:attribute name="name" select="@name"/>
            <xsl:attribute name="type" select="../name()"/>
        </xsl:element>
    </xsl:template>

    <xsl:variable name="expressionIndex">
        <t:ae>
            <xsl:for-each-group select="$allExpressions/t:ae/t:e" group-by="@name">
                <xsl:sort select="@type"/>
                <xsl:sort select="@name"/>
                <xsl:element name="t:ex">
                    <xsl:attribute name="id" select="generate-id(current-group()[1])"/>
                    <xsl:attribute name="type" select="current-group()[1]/@type"/>
                    <xsl:attribute name="name" select="current-group()[1]/@name"/>
                </xsl:element>
            </xsl:for-each-group>
        </t:ae>
    </xsl:variable>

    <!-- Suppress Contract Information for KNART Report artifact in L3 -->
    <xsl:template name="ContractInformation">
        <xsl:param name="ContractId"/>
        <xsl:param name="Status"/>
    </xsl:template>

    <xsl:template name="SubTitle">
        <xsl:value-of select="concat($artifactTypeName, ': Conceptual Structure')"/>
    </xsl:template>

    <xsl:template name="ExternalDataChapter">
        <chapter>
            <title>External Data Definitions</title>
            <xsl:choose>
                <xsl:when test="externalData/def | externalData/trigger">
                    <xsl:apply-templates select="externalData" mode="ExternalDataChapter"/>
                </xsl:when>
                <xsl:otherwise>
                    <para>No externalData expression definitions and no trigger definitions are present. </para>
                </xsl:otherwise>
            </xsl:choose>
        </chapter>
    </xsl:template>

    <!-- Emit externalData Definitions -->
    <xsl:template match="externalData" mode="ExternalDataChapter">
        <section>
            <title>Definitions</title>
            <xsl:choose>
                <xsl:when test="def">
                    <xsl:apply-templates select="def"/>
                </xsl:when>
                <xsl:otherwise>
                    <para>No externalData expression definitions are present.</para>
                </xsl:otherwise>
            </xsl:choose>
        </section>
        <section>
            <title>Triggers</title>
            <xsl:choose>
                <xsl:when test="trigger">
                    <xsl:apply-templates select="trigger"/>
                </xsl:when>
                <xsl:otherwise>
                    <para>No trigger definitions are present.</para>
                </xsl:otherwise>
            </xsl:choose>
        </section>
    </xsl:template>

    <!-- Emit expression Definitions Chapter-->
    <xsl:template name="ExpressionsChapter">
        <chapter>
            <title>Expression Definitions</title>
            <xsl:choose>
                <xsl:when test="expressions/def">
                    <xsl:apply-templates select="expressions" mode="ExpressionsChapter"/>
                </xsl:when>
                <xsl:otherwise>
                    <para>No expression definitions are present. </para>
                </xsl:otherwise>
            </xsl:choose>
        </chapter>
    </xsl:template>

    <xsl:template match="expressions" mode="ExpressionsChapter">
        <xsl:apply-templates select="def"/>
    </xsl:template>

    <!-- Emit Global Conditions (for debugging)
    <xsl:template match="conditions" mode="Global">
        <chapter>
            <title>Global Conditions</title>
            <table frame="all">
                <title>Condition Definitions</title>
                <tgroup align="left" cols="1">
                    <thead>
                        <row>
                            <entry>Conditions</entry>
                        </row>
                    </thead>
                    <tbody>
                        <xsl:for-each select="condition">
                            <xsl:if test="logic/elm:annotation/a:s">
                                <row>
                                    <entry>
                                        Annotation: <xsl:value-of select="logic/elm:annotation/a:s"/>
                                    </entry>
                                </row>
                            </xsl:if>
                            <row>
                                <entry>
                                    <xsl:apply-templates select="current()" mode="OnlyEntry"/>
                                </entry>
                            </row>
                        </xsl:for-each>
                    </tbody>
                </tgroup>
            </table>
        </chapter>
    </xsl:template>
    -->

    <xsl:template match="trigger">
        <xsl:apply-templates select="def">
            <xsl:with-param name="type" select="@xsi:type"/>
            <xsl:with-param name="triggerType" select="@triggerType"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Definitions of externalData and expressions-->
    <xsl:template match="def">
        <xsl:param name="type" required="no"/>
        <xsl:param name="triggerType" required="no"/>
        <table frame="all">
            <title>
                <xsl:attribute name="xml:id" select="func:computeExpressionId(@name)"/>
                <xsl:value-of select="@name"/>
            </title>
            <tgroup cols="4" align="left" colsep="0" rowsep="0">
                <colspec colname="c1" colnum="1"/>
                <colspec colname="c2" colnum="2"/>
                <colspec colname="c3" colnum="3"/>
                <colspec colname="c4" colnum="4"/>
                <tbody>
                    <xsl:if test="$type">
                        <row>
                            <entry namest="c1" nameend="c4">Trigger: type=<xsl:value-of select="$type"/>, <xsl:value-of select="$triggerType"
                                /></entry>
                        </row>
                    </xsl:if>
                    <row>
                        <entry namest="c1" nameend="c4">Expression: type=<xsl:value-of select="elm:*/@xsi:type"/><xsl:if test="elm:*/@dataType"> ,
                                    dataType=<xsl:value-of select="elm:*/@dataType"/></xsl:if><xsl:if test="elm:*/@codeProperty">,
                                    codeProperty=<xsl:value-of select="elm:*/@codeProperty"/></xsl:if><xsl:if test="elm:expression/@dateProperty">,
                                    dateProperty=<xsl:value-of select="elm:expression/@dateProperty"/></xsl:if></entry>
                    </row>
                    <row>
                        <entry namest="c1" nameend="c4">Annotation: <xsl:value-of select="elm:expression/elm:annotation/a:s"/>
                        </entry>
                    </row>
                    <row>
                        <entry namest="c1" nameend="c4">Codes: <xsl:apply-templates select="elm:*" mode="GetCodes"/>
                        </entry>
                    </row>
                    <xsl:apply-templates select="elm:expression/elm:dateRange" mode="def"/>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <!-- Emit Codes in expressions/triggers -->
    <xsl:template match="elm:*" mode="GetCodes">
        <xsl:if test="@code">
            <xsl:value-of select="name()"/>[<xsl:value-of select="@xsi:type"/>]: <link><xsl:attribute name="linkend" select="func:computeElmCodeId(.)"
                /> [<xsl:value-of select="normalize-space(@code)"/>]</link>
        </xsl:if>
        <xsl:apply-templates select="elm:*" mode="GetCodes"/>
    </xsl:template>



    <xsl:template match="elm:element" mode="def">
        <row>
            <entry/>
            <entry namest="c2" nameend="c4">element[<xsl:value-of select="@xsi:type"/>]: <xsl:value-of select="@display"/><xsl:if test="@code">
                    <xsl:text> </xsl:text>
                    <link><xsl:attribute name="linkend" select="func:computeElmCodeId(.)"/>
                        <xsl:value-of select="normalize-space(@code)"/></link></xsl:if></entry>
        </row>
    </xsl:template>

    <xsl:template match="elm:dateRange" mode="def">
        <row>
            <entry>dateRange[<xsl:value-of select="@xsi:type"/>]</entry>
            <entry namest="c2" nameend="c4">low: <xsl:value-of select="elm:low/@xsi:type"/>(<xsl:apply-templates select="elm:low/elm:*"/>)</entry>
        </row>
        <row>
            <entry/>
            <entry namest="c2" nameend="c4">high: <xsl:value-of select="elm:high/@xsi:type"
                />(<xsl:apply-templates select="elm:high/elm:*" xml:space="preserve"/>)</entry>
        </row>
    </xsl:template>

    <xsl:template match="conditions">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:apply-templates select="condition">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="condition">
        <!-- Build a representation of each condition on a separate row-->
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <row rowsep="0">
            <entry>
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:apply-templates select="." mode="OnlyEntry"/>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="conditions" mode="topLevel">
        <xsl:if test="condition">
            <informaltable frame="all">
                <tgroup align="left" cols="1">
                    <thead>
                        <row>
                            <entry>Conditions</entry>
                        </row>
                    </thead>
                    <tbody>
                        <xsl:for-each select="condition">
                            <row>
                                <entry>
                                    <xsl:apply-templates select="current()" mode="OnlyEntry"/>
                                </entry>
                            </row>
                        </xsl:for-each>
                    </tbody>
                </tgroup>
            </informaltable>
        </xsl:if>
    </xsl:template>

    <xsl:template match="condition" mode="OnlyEntry">
        <xsl:apply-templates select="logic"/>
    </xsl:template>

    <xsl:template match="initialValue">
        <!-- Build a representation of each condition on a separate row-->
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <row rowsep="0">
            <entry>
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <emphasis role="bold">initalValue: </emphasis>
                <xsl:choose>
                    <xsl:when test="@xsi:type = 'elm:ExpressionRef' and @name">
                        <link>
                            <xsl:attribute name="linkend" select="func:computeExpressionId(@name)"/>
                            <xsl:value-of select="@name"/>
                        </link>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="valueType">
                            <xsl:if test="@valueType">
                                <xsl:value-of select="concat(' (', @valueType, ')')"/>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(concat(@xsi:type, $valueType, ' ', @name, ' ', @value))"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@orderBy"> (order by: <xsl:value-of select="@orderBy"/>) </xsl:if>
                <xsl:apply-templates select="elm:*"/>
            </entry>
        </row>
    </xsl:template>


    <xsl:template match="responseBinding">
        <!-- Build a representation of each condition on a separate row-->
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <row rowsep="0">
            <entry>
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <emphasis role="bold">responseBinding: </emphasis> Property ("<xsl:value-of select="@property"/>")</entry>
        </row>
    </xsl:template>

    <xsl:template match="representedConcepts">
        <xsl:param name="indentLevel" select="0"/>
        <xsl:param name="columns" select="0"/>

        <row>
            <entry>
                <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>Represented Concepts: <xsl:for-each select="concept">
                    <xsl:if test="not(position() = 1)">, </xsl:if>
                    <link>
                        <xsl:attribute name="linkend" select="func:computeId(@codeSystem, @code)"/>
                        <xsl:value-of select="normalize-space(@code)"/>
                    </link></xsl:for-each>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="representedConcepts" mode="topLevel">
        <para>Represented Concepts: <xsl:for-each select="concept">
                <xsl:if test="not(position() = 1)">, </xsl:if>
                <link>
                    <xsl:attribute name="linkend" select="func:computeId(@codeSystem, @code)"/>
                    <xsl:value-of select="normalize-space(@code)"/></link>
            </xsl:for-each>
        </para>
    </xsl:template>

    <xsl:template match="itemCodes">
        <xsl:param name="indentLevel" select="0"/>
        <xsl:param name="columns" select="0"/>
        <xsl:for-each select="itemCode">
            <row>
                <entry align="right" colsep="0" rowsep="0">
                    <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>itemCode: </entry>
                <entry rowsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <link>
                        <xsl:attribute name="linkend" select="func:computeId(@codeSystem, @code)"/>
                        <xsl:value-of select="normalize-space(@code)"/>
                    </link>
                </entry>
            </row>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="logic"><emphasis role="bold">Condition:</emphasis>
        <xsl:value-of select="@xsi:type"/> ( <xsl:apply-templates select="elm:operand"/> ) </xsl:template>

    <xsl:template match="elm:source">
        <xsl:value-of select="@name"/>
    </xsl:template>

    <xsl:template match="elm:where">
        <xsl:value-of select="@xsi:type"/>(<xsl:apply-templates select="elm:operand"/>)</xsl:template>

    <xsl:template match="elm:operand[elm:operand]">
        <xsl:value-of select="@xsi:type"/>(<xsl:apply-templates select="elm:operand"/>)</xsl:template>

    <xsl:template
        match="elm:operand[not(elm:operand) and not(@xsi:type = 'elm:Quantity') and not(@xsi:type = 'elm:Property') and not(@xsi:type = 'elm:ExpressionRef')]">
        <xsl:value-of select="@xsi:type"/>(<xsl:value-of select="@name" exclude-result-prefixes="#all"/>) </xsl:template>

    <xsl:template match="elm:operand[not(elm:operand) and @xsi:type = 'elm:Quantity']">
        <xsl:value-of select="@xsi:type"/>(<xsl:value-of select="concat(@value, ' ', @unit)" exclude-result-prefixes="#all"/>) </xsl:template>

    <xsl:template match="elm:operand[not(elm:operand) and @xsi:type = 'elm:Property']">
        <xsl:value-of select="@xsi:type"/>("<xsl:value-of select="@path" exclude-result-prefixes="#all"/>"<xsl:if test="elm:source"> from:
                <xsl:value-of select="elm:source/@xsi:type"/> (<xsl:value-of select="elm:source/@name"/>)</xsl:if> ) </xsl:template>

    <xsl:template match="elm:operand[not(elm:operand) and @xsi:type = 'elm:ExpressionRef']">
        <xsl:text> </xsl:text>
        <link>
            <xsl:attribute name="linkend" select="func:computeExpressionId(@name)"/>
            <xsl:value-of select="@name"/>
        </link>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="actionSentence">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:variable name="asType">
            <xsl:value-of select="@xsi:type"/>
        </xsl:variable>
        <xsl:variable name="asClassType">
            <xsl:value-of select="@classType"/>
        </xsl:variable>

        <xsl:variable name="elValueDisplay">
            <xsl:for-each select="elm:element">
                <xsl:apply-templates select="current()"/>
                <xsl:choose>
                    <xsl:when test="not(position() = 1) and not(position() = last())">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>

        </xsl:variable>

        <xsl:variable name="elValues" select="elm:element/elm:value[@xsi:type = 'elm:Code']"/>

        <xsl:variable name="localCodes">
            <xsl:apply-templates select="$elValues" mode="normalizeElm"/>
        </xsl:variable>
        <row>
            <entry rowsep="0" colsep="0">
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:value-of select="concat('actionSentence[type=', $asType, ', classType=', $asClassType, ']')"/>
            </entry>
        </row>
        <xsl:if test="@xsi:type = 'elm:ExpressionRef'">
            <row>
                <entry rowsep="0" colsep="0"> </entry>
                <entry rowsep="0" colsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <!-- value as: element[TSR,  -->
                    <link>
                        <xsl:attribute name="linkend" select="func:computeExpressionId(@name)"/>
                        <xsl:value-of select="@name"/>
                    </link>
                </entry>
            </row>
        </xsl:if>
        <xsl:if test="string-length($elValueDisplay) > 0">
            <row>
                <entry rowsep="0" colsep="0"> </entry>
                <entry rowsep="0" colsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <!-- value as: element[TSR,  -->
                    <xsl:value-of select="concat('&quot;', normalize-space($elValueDisplay), '&quot;')"/>
                </entry>
            </row>
        </xsl:if>
        <xsl:if test="count($localCodes/t:c) > 0">
            <row>
                <entry rowsep="0" colsep="0"/>
                <entry>
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/> (Codes: <xsl:for-each select="$localCodes/t:c">
                        <link><xsl:attribute name="linkend" select="func:computeCodeId(current())"/>
                            <xsl:value-of select="current()/normalize-space(@code)"/></link>
                    </xsl:for-each>) </entry>
            </row>
        </xsl:if>

    </xsl:template>

    <xsl:template match="elm:element">
        <xsl:value-of select="concat(@name, ':', elm:value/@display, ' ')"/>
        <xsl:choose>
            <xsl:when test="elm:value[@xsi:type = 'elm:Literal']">
                <xsl:value-of select="concat(elm:value/@value, ' ')"/>
            </xsl:when>
            <xsl:when test="elm:value[@xsi:type = 'elm:Property']">
                <xsl:value-of select="concat(elm:value/@path, ' ')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="coverage">
        <row>
            <entry>
                <xsl:value-of select="focus/@value"/>
            </entry>
            <entry>
                <xsl:value-of select="description/@value"/>
            </entry>
            <entry>
                <xsl:value-of select="value/@codeSystem"/>
            </entry>
            <entry>
                <xsl:value-of select="value/@code"/>
            </entry>
            <entry>
                <xsl:choose>
                    <xsl:when test="value/@valueSet">
                        <xsl:value-of select="value/@valueSet"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>

            </entry>
            <entry>
                <xsl:choose>
                    <xsl:when test="value/@valueSetVersion">
                        <xsl:value-of select="value/@valueSetVersion"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>

            </entry>
        </row>
        <xsl:if test="comment() and not($gSuppressComments)">
            <row>
                <entry namest="c1" nameend="c8">
                    <remark>
                        <xsl:value-of select="comment()"/>
                    </remark>
                </entry>
            </row>
        </xsl:if>
    </xsl:template>

    <!-- This creates tabular list content, should be used inside a chapter or appendix. -->
    <xsl:template name="CreateTabularList">
        <xsl:if test="/knowledgeDocument/externalData/codesystem">
            <table>
                <title>Terminology Versions</title>
                <tgroup cols="3" align="left" colsep="1" rowsep="1">
                    <colspec colname="c1" colnum="1"/>
                    <colspec colname="c2" colnum="2"/>
                    <colspec colname="c3" colnum="3"/>
                    <thead>
                        <row>
                            <entry>Name</entry>
                            <entry>Identifer</entry>
                            <entry>Version</entry>
                        </row>
                    </thead>
                    <tbody>
                        <xsl:for-each select="/knowledgeDocument/externalData/codesystem">
                            <row>
                                <entry>
                                    <xsl:value-of select="current()/@name"/>
                                </entry>
                                <entry>
                                    <xsl:value-of select="current()/@id"/>
                                </entry>
                                <entry>
                                    <xsl:value-of select="current()/@version"/>
                                </entry>
                            </row>
                        </xsl:for-each>
                    </tbody>
                </tgroup>
            </table>
        </xsl:if>
        <xsl:if test="$allCodes">
            <table>
                <title>Terminology References</title>
                <tgroup cols="4" align="left" colsep="1" rowsep="1">
                    <colspec colname="c1" colnum="1"/>
                    <colspec colname="c2" colnum="2" colwidth="1.5*"/>
                    <colspec colname="c3" colnum="3" colwidth="2*"/>
                    <colspec colname="c4" colnum="4"/>
                    <thead>
                        <row>
                            <entry>System</entry>
                            <entry>Code</entry>
                            <entry>Display Text</entry>
                            <entry>References</entry>
                        </row>
                    </thead>
                    <tbody>
                        <xsl:choose>
                            <xsl:when test="$allCodes/t:ac/t:c">
                                <xsl:for-each-group select="$allCodes/t:ac/t:c" group-by="concat(@cs, '_', @code)">
                                    <xsl:sort select="@cs"/>
                                    <xsl:sort select="normalize-space(@code)"/>
                                    <row>
                                        <entry>
                                            <xsl:attribute name="xml:id" select="func:computeCodeId(current-group()[1])"/>
                                            <xsl:value-of select="@cs"/>
                                        </entry>
                                        <entry>
                                            <xsl:value-of select="normalize-space(@code)"/>
                                        </entry>
                                        <entry>
                                            <xsl:value-of select="@display"/>
                                        </entry>
                                        <entry>
                                            <xsl:value-of select="count(current-group())"/>
                                        </entry>
                                    </row>
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <row>
                                    <entry namest="c1" nameend="c4">⚠ No terminology entries found.</entry>
                                </row>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tbody>
                </tgroup>
            </table>
        </xsl:if>
    </xsl:template>



    <xsl:template match="*" mode="normalizeElm">
        <xsl:element name="t:c">
            <xsl:attribute name="code" select="normalize-space(@code)"/>
            <xsl:attribute name="cs" select="elm:system/@name"/>
            <xsl:attribute name="display" select="@display"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*" mode="normalizeItem">
        <xsl:variable name="display" select="displayText/@value"/>
        <xsl:for-each select="codes/code">
            <xsl:element name="t:c">
                <xsl:attribute name="code" select="normalize-space(@code)"/>
                <xsl:attribute name="cs" select="@codeSystem"/>
                <xsl:if test="$display">
                    <xsl:attribute name="display" select="$display"/>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="normalizeItemCodes">
        <xsl:for-each select="itemCode">
            <xsl:variable name="display" select="current()/dt:displayName/@value"/>
            <xsl:element name="t:c">
                <xsl:attribute name="code" select="normalize-space(@code)"/>
                <xsl:attribute name="cs" select="@codeSystem"/>
                <xsl:if test="$display">
                    <xsl:attribute name="display" select="$display"/>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="normalizeValue">
        <xsl:for-each select=".">
            <xsl:variable name="display" select="../description/@value"/>
            <xsl:element name="t:c">
                <xsl:attribute name="code" select="normalize-space(@code)"/>
                <xsl:attribute name="cs" select="@codeSystem"/>
                <xsl:if test="$display">
                    <xsl:attribute name="display" select="$display"/>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="normalizeConceptCodes">
        <xsl:for-each select=".">
            <xsl:variable name="display" select="current()/dt:displayName/@value"/>
            <xsl:element name="t:c">
                <xsl:attribute name="code" select="normalize-space(@code)"/>
                <xsl:choose>
                    <xsl:when test="@code = 'TSR-NoCode'">
                        <xsl:attribute name="cs" select="N/A"/>
                        <xsl:choose>
                            <xsl:when test="string-length($display) > 0">
                                <xsl:attribute name="display" select="$display"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="display" select="N/A"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="cs" select="@codeSystem"/>
                        <!-- Concept codes will never have a display value, but if the codeSystem is SNOMED CT we can add one -->
                        <xsl:if test="@codeSystem = 'SNOMED CT'">
                            <xsl:choose>
                                <xsl:when test="string-length(@code) - string-length(translate(@code, '|', '')) = 2">
                                    <xsl:attribute name="display" select="'Precoordinated Expression'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="display" select="'Postcoordinated Expression'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:function name="func:computeCodeId">
        <xsl:param name="code" as="element()"/>
        <xsl:value-of select="$allCodesIndex/t:aci/t:ci[@code = $code/normalize-space(@code) and @cs = $code/@cs]/@id"/>
    </xsl:function>

    <xsl:function name="func:computeElmCodeId">
        <xsl:param name="code" as="element()"/>
        <xsl:value-of select="$allCodesIndex/t:aci/t:ci[@cs = $code/elm:system/@name and @code = $code/normalize-space(@code)]/@id"/>
    </xsl:function>

    <xsl:function name="func:computeId">
        <xsl:param name="codeSystem"/>
        <xsl:param name="code"/>
        <xsl:value-of select="$allCodesIndex/t:aci/t:ci[@code = normalize-space($code) and @cs = $codeSystem]/@id"/>
    </xsl:function>

    <xsl:function name="func:computeExpressionId">
        <xsl:param name="name"/>
        <xsl:value-of select="$expressionIndex/t:ae/t:ex[@name = $name]/@id"/>
    </xsl:function>

    <xsl:template match="item" mode="ExpandItem">
        <xsl:variable name="codes">
            <xsl:apply-templates select="." mode="normalizeItem"/>
        </xsl:variable>
        <xsl:value-of select="displayText/@value"/>
        <xsl:if test="$codes/t:c">(<xsl:for-each select="$codes/t:c"><link><xsl:attribute name="linkend" select="func:computeCodeId(current())"
                        /><xsl:value-of select="current()/normalize-space(@code)"/></link>
            </xsl:for-each>)</xsl:if>
    </xsl:template>
</xsl:stylesheet>
