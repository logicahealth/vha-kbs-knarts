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
    xmlns:docb="http://docbook.org/ns/docbook" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:elm="urn:hl7-org:elm:r1"
    xmlns:dt="urn:hl7-org:cdsdt:r2" xpath-default-namespace="urn:hl7-org:knowledgeartifact:r1"
    xmlns:func="http://www.cognitivemedicine.com/xsl/functions" version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <!-- optional workingDirectory parameter -->
    <xsl:param name="workingDirectory" select="."/>
    <xsl:param name="gTesting" select="false()"/>
    <xsl:param name="gSuppressComments" select="false()"/>

    <xsl:variable name="artifactTypeName">
        <xsl:value-of select="/knowledgeDocument/metadata/artifactType/@value"/>
    </xsl:variable>

    <!-- Root matching pattern, look for /knowledgeDocument -->
    <xsl:template match="knowledgeDocument">
        <book xmlns="http://docbook.org/ns/docbook" version="5.1" xml:lang="en-US" xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xi="http://www.w3.org/2001/XInclude">
            <xsl:if test="metadata/status/@value = 'Draft'">
                <xsl:attribute name="status">draft</xsl:attribute>
            </xsl:if>

            <!-- Produce information in metadata section -->
            <xsl:apply-templates select="metadata"/>

            <xsl:call-template name="coverMatter"/>

            <!-- Stub for L3, this is a no-op in L2 -->
            <xsl:call-template name="ExternalDataChapter"/>

            <!-- Stub for L3, this is a no-op in L2 -->
            <xsl:call-template name="ExpressionsChapter"/>

            <xsl:apply-templates select="conditions" mode="Global"/>

            <!-- Root actionGroup, this will not be output to the conceptual structure, it is just a grouping item
                 for subelements below it-->

            <xsl:choose>
                <xsl:when test="metadata/artifactType[@value = 'Rule']">
                    <!-- ECA Rules will generally have one top level actionGroup only -->
                    <xsl:apply-templates select="actionGroup" mode="topLevel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="actionGroup/subElements" mode="topLevel"/>
                </xsl:otherwise>
            </xsl:choose>

            <chapter>
                <title>Tabular List</title>
                <subtitle>Terminology Service Request (TSR) Mappings</subtitle>
                <xsl:call-template name="CreateTabularList"/>
            </chapter>

            <!-- Output Legend Table for Symbols used in action Groups -->
            <xsl:call-template name="behaviorSymbols"/>

            <xsl:call-template name="appendix1"/>
        </book>
    </xsl:template>

    <!-- L3 Concept Stubs -->
    <!-- externalData is an L3 concept, not projected in L2 output -->
    <xsl:template name="ExternalDataChapter"/>
    <xsl:template match="externalData"/>

    <!-- externalData is an L3 concept, not projected in L2 output -->
    <xsl:template name="ExpressionsChapter"/>
    <xsl:template match="expressions"/>

    <!-- conditions is an L3 concept, not projected in L2 output -->
    <xsl:template match="conditions">
        <xsl:param name="indentLevel" select="0"/>
        <xsl:param name="columns" select="0"/>
    </xsl:template>

    <xsl:template match="conditions" mode="Global"/>

    <xsl:template match="conditions" mode="topLevel"/>

    <xsl:template match="initialValue">
        <xsl:param name="indentLevel" select="0"/>
        <xsl:param name="columns" select="0"/>
    </xsl:template>

    <xsl:template match="responseBinding">
        <xsl:param name="indentLevel" select="0"/>
        <xsl:param name="columns" select="0"/>
    </xsl:template>

    <xsl:template match="representedConcepts">
        <xsl:param name="indentLevel" select="0"/>
        <xsl:param name="columns" select="0"/>
    </xsl:template>

    <xsl:template name="coverMatter"/>
    <!-- End L3 Concept Stubs -->

    <!-- Deal with the basic front matter of the conceputal structure document, which will be derived primarily
         from the metadata section of the of DocBook XML -->
    <xsl:template match="metadata">
        <info>

            <title>
                <xsl:apply-templates select="title"/>
            </title>

            <subtitle>
                <xsl:call-template name="SubTitle"/>
            </subtitle>

            <xsl:if test="string-length(normalize-space(description/@value)) > 0">
                <abstract>
                    <para>
                        <xsl:value-of select="description/@value"/>
                    </para>
                </abstract>
            </xsl:if>

            <releaseinfo>
                <!-- This is the contract information for the Conceptual Structure Document, NOT the KNART itself -->
                <xsl:variable name="contract_clin_csd"
                    select="relatedResources/relatedResource/resources/resource/identifiers/identifier[@root = 'LocalDocBook' and @identifierName = 'CSD']/parent::*/identifier[@root = 'urn:va.gov:kbs:contract:VA118-16-D-1008:to:VA-118-16-F-1008-0007']/@identifierName"/>
                <xsl:choose>
                    <xsl:when
                        test="/knowledgeDocument/metadata/identifiers/identifier[@root = 'urn:va.gov:kbs:knart:artifact:r1' and starts-with(@identifierName, 'O')]">
                        <xsl:value-of select="replace($contract_clin_csd, '[A-D]$', 'A')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$contract_clin_csd"/>
                    </xsl:otherwise>
                </xsl:choose>
            </releaseinfo>

            <pubdate>
                <xsl:for-each select="eventHistory/artifactLifeCycleEvent">
                    <xsl:sort select="eventDateTime/@value" order="descending"/>
                    <xsl:if test="position() = 1">
                        <xsl:variable name="eventTS" select="string(current()/eventDateTime/@value)"/>
                        <xsl:value-of select="concat(substring($eventTS, 5, 2), '/', substring($eventTS, 7, 2), '/', substring($eventTS, 1, 4))"/>
                    </xsl:if>
                </xsl:for-each>
            </pubdate>

            <volumenum>Version: <xsl:value-of select="identifiers/identifier[@root = 'urn:va.gov:kbs:knart:artifact:r1']/@version"/>
            </volumenum>

            <xi:include href="./common/apache-copyright-b3-docbook.xml" xpointer="element(/1/1)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>

            <xi:include href="./common/apache-copyright-b3-docbook.xml" xpointer="element(/1/2)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>

            <author>
                <orgname>Department of Veterans Affairs (VA)</orgname>
            </author>

            <mediaobject>
                <alt>Department of Veteran's Affairs Logo</alt>
                <imageobject>
                    <imagedata contentwidth="2in" align="center" fileref="images/va-logo.png" format="png"/>
                </imageobject>
            </mediaobject>

            <authorgroup>
                <author>
                    <orgname>Knowledge Based Systems (KBS)</orgname>
                </author>
                <author>
                    <orgname>Office of Informatics and Information Governance (OIIG)</orgname>
                </author>
                <author>
                    <orgname>Clinical Decision Support (CDS)</orgname>
                </author>
            </authorgroup>
        </info>

        <!-- Build Preface -->
        <xsl:call-template name="preface1"/>

        <!-- Build Applicability Preface -->
        <xsl:call-template name="preface2"/>

        <!-- Build Model Reference Preface -->
        <xsl:call-template name="preface3"/>
    </xsl:template>

    <xsl:template name="SubTitle">
        <xsl:value-of select="concat($artifactTypeName, ': L2 Conceptual Structure')"/>
    </xsl:template>

    <!-- place some opening content into a preface -->
    <xsl:template name="preface1">
        <preface>
            <title>Preface</title>
            <!-- Produce a table for event history -->
            <xsl:apply-templates select="eventHistory"/>

            <!-- Produce a table of contributors -->
            <xsl:apply-templates select="contributions"/>

            <!-- Add contract information for the underlying KNART, this table is only for the contract/task order and status -->
            <xsl:variable name="contract_clin_krprt"
                select="identifiers/identifier[@root = 'urn:va.gov:kbs:contract:VA118-16-D-1008:to:VA-118-16-F-1008-0007']/@identifierName"/>
            <xsl:call-template name="ContractInformation">
                <xsl:with-param name="ContractId">
                    <xsl:choose>
                        <xsl:when
                            test="/knowledgeDocument/metadata/identifiers/identifier[@root = 'urn:va.gov:kbs:knart:artifact:r1' and starts-with(@identifierName, 'O')]">
                            <xsl:value-of select="replace($contract_clin_krprt, '[A-D]$', 'A')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$contract_clin_krprt"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="Status">
                    <xsl:value-of select="status/@value"/>
                </xsl:with-param>
            </xsl:call-template>

            <!-- Add identifier information, output remaining identifiers -->
            <xsl:apply-templates select="identifiers"/>

        </preface>
    </xsl:template>

    <!-- Produce an Event History (aka Revision History) -->
    <xsl:template match="eventHistory">
        <table frame="all">
            <title>Revision History</title>
            <tgroup cols="2" align="left" colsep="0" rowsep="0">
                <colspec colname="c1" colnum="1"/>
                <colspec colname="c2" colnum="2"/>
                <thead>
                    <row>
                        <entry>Date</entry>
                        <entry>Life Cycle Event</entry>
                    </row>
                </thead>
                <tbody>
                    <xsl:apply-templates select="artifactLifeCycleEvent">
                        <xsl:sort select="eventDateTime/@value" order="descending"/>
                    </xsl:apply-templates>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <xsl:template match="artifactLifeCycleEvent">
        <row>
            <entry>
                <xsl:variable name="dateString" select="eventDateTime/@value"/>
                <xsl:variable name="eventDate"
                    select="
                        xs:date(concat(substring($dateString, 1, 4), '-',
                        substring($dateString, 5, 2), '-',
                        substring($dateString, 7, 2)))"/>
                <xsl:value-of select="format-date($eventDate, '[MNn] [D], [Y]')"/>
            </entry>
            <entry>
                <xsl:value-of select="eventType/@value"/>
            </entry>
        </row>
    </xsl:template>

    <!-- Produce Contributors table -->
    <xsl:template match="contributions">
        <xsl:if test="count(contribution) > 0">
            <table frame="all">
                <title>Clinical White Paper Contributors</title>
                <tgroup cols="3" align="left" colsep="1" rowsep="1">
                    <colspec colname="c1" colnum="1"/>
                    <colspec colname="c2" colnum="2"/>
                    <colspec colname="c3" colnum="3" colwidth="3*"/>
                    <thead>
                        <row>
                            <entry>Name</entry>
                            <entry>Role</entry>
                            <entry>Affiliation</entry>
                        </row>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="contribution/contributor"/>
                    </tbody>
                </tgroup>
            </table>
        </xsl:if>
    </xsl:template>

    <xsl:template match="contributor">
        <row>
            <entry>
                <xsl:value-of
                    select="concat(string-join(name/dt:part[@type = 'GIV']/@value, ' '), ' ', string-join(name/dt:part[@type = 'FAM']/@value, ' '))"/>
                <xsl:if test="name/dt:part[@type = 'TITLE']">, <xsl:value-of select="name/dt:part[@type = 'TITLE']/@value"/></xsl:if>
            </entry>

            <entry>
                <xsl:value-of select="../role/@value"/>
            </entry>
            <entry>
                <xsl:value-of select="affiliation/name/@value"/>
            </entry>
        </row>

    </xsl:template>

    <xsl:template name="ContractInformation">
        <xsl:param name="ContractId"/>
        <xsl:param name="Status"/>
        <table frame="all">
            <title>Contract Information for KNART Report Artifact</title>
            <tgroup cols="2" align="left" colsep="1" rowsep="1">
                <thead>
                    <row>
                        <entry>Contract Information</entry>
                        <entry>Artifact Status</entry>
                    </row>
                </thead>
                <tbody>
                    <row>
                        <entry>
                            <xsl:value-of select="$ContractId"/>
                        </entry>
                        <entry>
                            <xsl:value-of select="$Status"/>
                        </entry>
                    </row>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <xsl:template match="identifiers">
        <table frame="all">
            <title>Artifact Identifier</title>
            <tgroup cols="3" align="left" colsep="1" rowsep="1">
                <colspec colname="c1" colnum="1" colwidth="1.5*"/>
                <colspec colname="c2" colnum="2"/>
                <colspec colname="c3" colnum="3"/>
                <thead>
                    <row>
                        <entry>Domain</entry>
                        <entry>Artifact ID</entry>
                        <entry>Name</entry>
                    </row>
                </thead>
                <tbody>
                    <xsl:apply-templates select="identifier"/>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <xsl:template
        match="identifier[not(@root = 'urn:va.gov:kbs:contract:VA118-16-D-1008:to:VA-118-16-F-1008-0007') and not(@root = 'urn:cognitivemedicine.com:lab:jira')]">
        <row>
            <entry>
                <xsl:value-of select="@root"/>
            </entry>
            <entry>
                <xsl:value-of select="@extension"/>
            </entry>
            <entry>
                <xsl:value-of select="@identifierName"/>
            </entry>
        </row>
    </xsl:template>

    <!-- Extract applicability opening content into a preface -->
    <xsl:template name="preface2">
        <preface>
            <title>Artifact Applicability</title>
            <!-- Produce a table for event history -->
            <xsl:apply-templates select="applicability"/>
        </preface>
    </xsl:template>

    <!-- Produce a table for coverage elements -->
    <xsl:template match="applicability">
        <table frame="all">
            <title>Applicability Foci, Description and Codes</title>
            <tgroup cols="6" align="left" colsep="1" rowsep="1">
                <colspec colname="c1" colnum="1" colwidth="2*"/>
                <colspec colname="c2" colnum="2" colwidth="1.5*"/>
                <colspec colname="c3" colnum="3"/>
                <colspec colname="c4" colnum="4"/>
                <colspec colname="c5" colnum="5"/>
                <colspec colname="c6" colnum="6"/>
                <thead>
                    <row>
                        <entry>Focus</entry>
                        <entry>Description</entry>
                        <entry>Code System</entry>
                        <entry>Code</entry>
                        <entry>Value Set</entry>
                        <entry>Value Set Version</entry>
                    </row>
                </thead>
                <tbody>
                    <xsl:apply-templates select="coverage"/>
                </tbody>
            </tgroup>
        </table>
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
                <xsl:value-of select="value/@valueSet"/>
            </entry>
            <entry>
                <xsl:value-of select="value/@valueSetVersion"/>
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

    <!-- List information on referenced models -->
    <xsl:template name="preface3">
        <preface>
            <title>Models</title>
            <table frame="all">
                <title>Model References</title>
                <tgroup cols="2" align="left" colsep="1" rowsep="1">
                    <colspec colname="c1" colnum="1"/>
                    <colspec colname="c2" colnum="2" colwidth="2*"/>
                    <thead>
                        <row>
                            <entry>Referenced Model</entry>
                            <entry>Description</entry>
                        </row>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="dataModels/modelReference"/>
                    </tbody>
                </tgroup>
            </table>
        </preface>
    </xsl:template>

    <xsl:template match="modelReference">
        <row>
            <entry>
                <xsl:choose>
                    <xsl:when test="referencedModel/@value">
                        <xsl:value-of select="referencedModel/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <remark>Missing Model Reference</remark>
                    </xsl:otherwise>
                </xsl:choose>
            </entry>
            <entry>
                <xsl:choose>
                    <xsl:when test="description/@value">
                        <xsl:value-of select="description/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <remark>Missing Description</remark>
                    </xsl:otherwise>
                </xsl:choose>
            </entry>
        </row>
    </xsl:template>

    <xsl:template name="appendix1">
        <appendix>
            <title>References</title>
            <para>This appendix contains the list of related resources and supporting documents used in creating this KNART.<xsl:if
                    test="not(metadata/supportingEvidence)">
                    <remark> NOTE: There are no supporting evidence references defined for this KNART.</remark>
                </xsl:if></para>
            <bibliography>
                <title>List of References</title>
                <bibliodiv>
                    <title>Related Resources</title>
                    <xsl:apply-templates select="metadata/relatedResources"/>
                </bibliodiv>
                <xsl:if test="metadata/supportingEvidence">
                    <bibliodiv>
                        <title>Supporting Evidence</title>
                        <xsl:apply-templates select="metadata/supportingEvidence"/>
                    </bibliodiv>
                </xsl:if>
            </bibliography>
        </appendix>
    </xsl:template>


    <!-- Display Symbols for Behaviors -->
    <xsl:template name="behaviorSymbols">
        <chapter>
            <title>Behavior Symbols</title>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/2)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/3)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/4)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/5)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/6)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/7)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
            <xi:include href="./common/behavior-symbol-tables-docbook.xml" xpointer="element(/1/1/8)" xmlns:xi="http://www.w3.org/2001/XInclude">
                <xi:fallback/>
            </xi:include>
        </chapter>
    </xsl:template>

    <!--  
        actionGroup/subElements/actionGroup
        Process top level actionGroups these are assigned to chapters 
    -->
    <xsl:template match="actionGroup" mode="topLevel">
        <!-- Top level action groups are assigned to chapters, and subElements are processed recursively below.  
             In order to preserve the hierarchical structure of the actionGroups, first establish a table that
             has the same number of columns as the depth.  Subsequent actionGroups will then indent using
             columns in the table
        -->
        <chapter>
            <title>
                <xsl:choose>
                    <xsl:when test="title">
                        <xsl:apply-templates select="title"/>
                    </xsl:when>
                    <xsl:otherwise>Actions</xsl:otherwise>
                </xsl:choose>
            </title>

            <xsl:apply-templates select="conditions" mode="topLevel"/>

            <xsl:if test="description/@value">
                <para>
                    <xsl:value-of select="description/@value"/>
                </para>
            </xsl:if>

            <xsl:if test="representedConcepts">
                <xsl:apply-templates select="representedConcepts" mode="topLevel"/>
            </xsl:if>

            <xsl:if test="supportingResources">
                <xsl:apply-templates select="supportingResources" mode="supportingResource">
                    <xsl:with-param name="indentLevel" select="0" as="xs:integer"/>
                    <xsl:with-param name="columns" select="0" as="xs:integer"/>
                </xsl:apply-templates>
            </xsl:if>

            <xsl:if test="supportingEvidence">
                <xsl:apply-templates select="supportingEvidence" mode="supportingEvidence">
                    <xsl:with-param name="indentLevel" select="0" as="xs:integer"/>
                    <xsl:with-param name="columns" select="0" as="xs:integer"/>
                </xsl:apply-templates>
            </xsl:if>

            <xsl:variable name="nonEmptySubElements"
                select="count(subElements/*[not(@xsi:type = 'DeclareResponseAction') or normalize-space(text()) = ' '])"/>

            <xsl:if test="$gTesting">
                <xsl:comment>DEBUG (TOPLEVEL): - - - Maximum Element Depth: <xsl:call-template name="maxSubElementDepth">
                        <xsl:with-param name="start-node" select="."/>
                    </xsl:call-template> <xsl:value-of select="$nonEmptySubElements"/> - - - </xsl:comment>
            </xsl:if>

            <xsl:if test="comment() and not($gSuppressComments)">
                <para>
                    <remark>
                        <xsl:value-of select="comment()"/>
                    </remark>
                </para>
            </xsl:if>

            <xsl:if test="$nonEmptySubElements &gt; 0">
                <informaltable frame="none">
                    <xsl:variable name="md">
                        <xsl:call-template name="maxSubElementDepth">
                            <xsl:with-param name="start-node" select="."/>
                        </xsl:call-template>
                    </xsl:variable>
                    <tgroup align="left">
                        <xsl:attribute name="cols">
                            <xsl:value-of select="$md"/>
                        </xsl:attribute>
                        <xsl:call-template name="buildColumnDef">
                            <xsl:with-param name="columns" select="$md"/>
                        </xsl:call-template>
                        <tbody>
                            <xsl:apply-templates select="subElements" mode="child">
                                <xsl:with-param name="indentLevel" select="1"/>
                                <xsl:with-param name="columns" select="$md"/>
                            </xsl:apply-templates>
                        </tbody>
                    </tgroup>
                </informaltable>
            </xsl:if>
        </chapter>
    </xsl:template>

    <!-- General descent node for diving into actionGroup elements below the top level.
         An actionGroup may contain a behavior definition, so output this in a row at the 
         current indent level, along with any title if present.  Then descend into
         subElements increasing indent level by 1...
    -->
    <xsl:template match="actionGroup" mode="child">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:param name="groupLength" as="xs:integer" select="0"/>

        <xsl:variable name="conditionsCount" select="count(conditions/condition)"/>
        <xsl:variable name="hasTitle" select="title/@value"/>
        <xsl:variable name="hasDescription" select="description/@value"/>

        <row>
            <entry rowsep="0" colsep="1" align="right" valign="top">
                <xsl:if test="$groupLength &gt; 0">
                    <xsl:attribute name="morerows" select="$groupLength"/>
                </xsl:if>
                <xsl:copy-of select="func:getGroupOrganizationSymbol(.)"/>
                <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                <xsl:copy-of select="func:getCardinalitySymbol(.)"/>
                <xsl:if test="$gTesting">
                    <xsl:comment>More Rows Cell</xsl:comment>
                </xsl:if>
            </entry>
            <entry>
                <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:choose>
                    <xsl:when test="$conditionsCount > 0">
                        <!-- The first condition will be issued on this row -->
                        <xsl:choose>
                            <xsl:when test="$hasDescription or $hasTitle or $conditionsCount &gt; 1">
                                <xsl:attribute name="rowsep" select="0"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="rowsep" select="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="conditions/condition[1]" mode="OnlyEntry"/>
                    </xsl:when>
                    <xsl:when test="$hasTitle">
                        <xsl:choose>
                            <xsl:when test="$hasDescription">
                                <xsl:attribute name="rowsep" select="0"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="rowsep" select="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="title"/>
                    </xsl:when>
                </xsl:choose>

            </entry>
        </row>

        <xsl:for-each select="conditions/condition[not(position() = 1)]">
            <row>
                <entry>
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:choose>
                        <xsl:when test="position() = last()">
                            <xsl:attribute name="rowsep" select="1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rowsep" select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:apply-templates select="current()" mode="OnlyEntry">
                        <xsl:with-param name="indentLevel" select="$indentLevel"/>
                        <xsl:with-param name="columns" select="$columns"/>
                    </xsl:apply-templates>
                </entry>
            </row>
        </xsl:for-each>

        <xsl:if test="description/@value">
            <row>
                <entry>
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:apply-templates select="description"/>
                </entry>
            </row>
        </xsl:if>

        <xsl:if test="representedConcepts/concept[@code]">
            <xsl:apply-templates select="representedConcepts">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <xsl:if test="supportingResources">
            <xsl:apply-templates select="supportingResources">
                <xsl:with-param name="indentLevel" select="$indentLevel + 1" as="xs:integer"/>
                <xsl:with-param name="columns" select="$columns" as="xs:integer"/>
            </xsl:apply-templates>
        </xsl:if>

        <xsl:if test="supportingEvidence">
            <xsl:apply-templates select="supportingEvidence">
                <xsl:with-param name="indentLevel" select="$indentLevel + 1" as="xs:integer"/>
                <xsl:with-param name="columns" select="$columns" as="xs:integer"/>
            </xsl:apply-templates>
        </xsl:if>

        <xsl:if test="comment() and not($gSuppressComments)">
            <row>
                <entry>
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <remark>
                        <xsl:value-of select="comment()"/>
                    </remark>
                </entry>
            </row>
        </xsl:if>

        <xsl:apply-templates select="subElements" mode="child">
            <xsl:with-param name="indentLevel" select="$indentLevel + 1"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Process sequences of subElements, using group-adjacent.  Using group-adjacent allows similar items (e.g. a sequence of
         simpleAction with type CreateAction) will be processed in a loop, allowing formatting constructs to be created before
         descending.  As other types of elements are added, this loop structure will need to be extended.  For now, the following
         are supported:
    
         simpleAction (grouped by xsi:type)
             CreateAction
             CollectInformation
         actionGroup
         
    -->
    <xsl:template match="subElements" mode="child">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>

        <!-- match any type within subElements, these can be simpleAction or actionGroup -->
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="name(current()) = 'actionGroup'">
                    <xsl:variable name="tempAgTree" select="func:getActionGroup(current())"/>
                    <xsl:variable name="rowLength" select="count($tempAgTree[name() = 'row']) - 1"/>


                    <xsl:if test="$gTesting">
                        <xsl:comment>DEBUG: Indent Level <xsl:value-of select="$indentLevel"/> table Length: <xsl:value-of select="$rowLength"/></xsl:comment>
                    </xsl:if>

                    <xsl:if test="$rowLength > 0">
                        <xsl:apply-templates select="current()" mode="child">
                            <xsl:with-param name="indentLevel" select="$indentLevel"/>
                            <xsl:with-param name="columns" select="$columns"/>
                            <xsl:with-param name="groupLength" select="$rowLength"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>

                <!-- The remaining node types are flat, so group them by type and process.  Cases currently are:
                         simpleAction
                            CreateAction
                            CollectInformation
                         actionRef
                         -->
                <xsl:when test="name(current()) = 'simpleAction'">
                    <!-- If the current group's name is simpleAction, these can be further differentiated by type, 
                                 requring a second for-each group (what a pain)-->
                    <xsl:apply-templates select="current()">
                        <xsl:with-param name="indentLevel" select="$indentLevel"/>
                        <xsl:with-param name="columns" select="$columns"/>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:function name="func:getActionGroup">
        <xsl:param name="agNode"/>
        <xsl:apply-templates select="$agNode" mode="child">
            <xsl:with-param name="indentLevel" select="1"/>
            <xsl:with-param name="columns" select="1"/>
        </xsl:apply-templates>
    </xsl:function>

    <!-- simpleAction with xsi:type CreateAction
         Produces a single row at the current indent level, spanning to last column
         -->
    <xsl:template match="simpleAction[@xsi:type = 'CreateAction']">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:param name="first" as="xs:boolean" select="false()"/>

        <xsl:apply-templates select="conditions">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>

        <!-- Push out text equivalent for CreateAction-->
        <row>
            <entry rowsep="0">
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                <xsl:copy-of select="func:getRequiredSymbol(.)"/>
                <xsl:copy-of select="func:getCardinalitySymbol(.)"/>
                <xsl:copy-of select="func:getPrecheckSymbol(.)"/>
                <xsl:copy-of select="func:getVisualStyleBehavior(.)"/>
                <xsl:copy-of select="func:getReadOnlySymbol(.)"/>
                <xsl:apply-templates select="textEquivalent"/>
            </entry>
        </row>

        <xsl:if test="actionSentence">
            <xsl:apply-templates select="actionSentence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingResources/resource">
            <xsl:apply-templates select="supportingResources" mode="supportingResource">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingEvidence/evidence/resources/resource">
            <xsl:apply-templates select="supportingEvidence" mode="supportingEvidence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- simpleAction with xsi:type UpdateAction
         Produces a single row at the current indent level, spanning to last column
         -->
    <xsl:template match="simpleAction[@xsi:type = 'UpdateAction']">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:param name="first" as="xs:boolean" select="false()"/>

        <xsl:apply-templates select="conditions">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>

        <!-- Push out text equivalent for UpdateAction-->
        <row>
            <entry rowsep="0">
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                <xsl:copy-of select="func:getRequiredSymbol(.)"/>
                <xsl:copy-of select="func:getCardinalitySymbol(.)"/>
                <xsl:copy-of select="func:getPrecheckSymbol(.)"/>
                <xsl:copy-of select="func:getVisualStyleBehavior(.)"/>
                <xsl:copy-of select="func:getReadOnlySymbol(.)"/>Update: <xsl:apply-templates select="textEquivalent"/>
            </entry>
        </row>

        <xsl:if test="actionSentence">
            <xsl:apply-templates select="actionSentence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingResources/resource">
            <xsl:apply-templates select="supportingResources" mode="supportingResource">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingEvidence/evidence/resources/resource">
            <xsl:apply-templates select="supportingEvidence" mode="supportingEvidence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- simpleAction with xsi:type UpdateAction
         Produces a single row at the current indent level, spanning to last column
         -->
    <xsl:template match="simpleAction[@xsi:type = 'RemoveAction']">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:param name="first" as="xs:boolean" select="false()"/>

        <xsl:apply-templates select="conditions">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>

        <!-- Push out text equivalent for RemoveAction-->
        <row>
            <entry rowsep="0">
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                <xsl:copy-of select="func:getRequiredSymbol(.)"/>
                <xsl:copy-of select="func:getCardinalitySymbol(.)"/>
                <xsl:copy-of select="func:getPrecheckSymbol(.)"/>
                <xsl:copy-of select="func:getVisualStyleBehavior(.)"/>
                <xsl:copy-of select="func:getReadOnlySymbol(.)"/>Remove: <xsl:apply-templates select="textEquivalent"/>
            </entry>
        </row>

        <xsl:if test="actionSentence">
            <xsl:apply-templates select="actionSentence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingResources/resource">
            <xsl:apply-templates select="supportingResources" mode="supportingResource">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingEvidence/resources/resource">
            <xsl:apply-templates select="supportingEvidence" mode="supportingEvidence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- simpleAction with xsi:type DeclareResponseAction
         Produces a single row at the current indent level, spanning to last column
         -->
    <xsl:template match="simpleAction[@xsi:type = 'DeclareResponseAction']">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingResources/resource">
            <xsl:apply-templates select="supportingResources" mode="supportingResource">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting evidence -->
        <xsl:if test="supportingEvidence/evidence/resources/resource">
            <xsl:apply-templates select="supportingEvidence" mode="supportingEvidence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Push out text equivalent -->
        <row>
            <entry>
                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                <xsl:copy-of select="func:getRequiredSymbol(.)"/>
                <xsl:copy-of select="func:getCardinalitySymbol(.)"/>
                <xsl:copy-of select="func:getPrecheckSymbol(.)"/>
                <xsl:copy-of select="func:getVisualStyleBehavior(.)"/>
                <xsl:apply-templates select="textEquivalent"/>
            </entry>
        </row>
    </xsl:template>

    <!-- simpleAction with xsi:type CollectionInformation 
         Produces two rows at the current indent level, the first 
         is for the request, the second for the responsee -->
    <xsl:template match="simpleAction[@xsi:type = 'CollectInformationAction']">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:param name="first" as="xs:boolean" select="false()"/>

        <!-- Deal with any supporting resources -->
        <xsl:if test="supportingResources/resource">
            <xsl:apply-templates select="supportingResources" mode="supportingResource">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- Deal with any supporting evidence -->
        <xsl:if test="supportingEvidence/evidence/resources/resource">
            <xsl:apply-templates select="supportingEvidence" mode="supportingEvidence">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <xsl:apply-templates select="conditions">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>

        <!-- CollectInformation may have a text equivalent, push this out above documentationConcept (i.e. prompt:/response:) -->
        <xsl:choose>
            <xsl:when test="textEquivalent">
                <row>
                    <entry rowsep="0">
                        <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                        <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                        <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                        <xsl:copy-of select="func:getRequiredSymbol(.)"/>
                        <xsl:copy-of select="func:getCardinalitySymbol(.)"/>
                        <xsl:copy-of select="func:getPrecheckSymbol(.)"/>
                        <xsl:copy-of select="func:getVisualStyleBehavior(.)"/>
                        <xsl:apply-templates select="textEquivalent"/>
                    </entry>
                </row>
                <!-- Dive into documentationConcept to push out prompt/response -->
                <xsl:apply-templates select="documentationConcept">
                    <xsl:with-param name="indentLevel" select="$indentLevel"/>
                    <xsl:with-param name="columns" select="$columns"/>
                    <xsl:with-param name="first" select="false()"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!-- Dive into documentationConcept to push out prompt/response -->
                <xsl:apply-templates select="documentationConcept">
                    <xsl:with-param name="indentLevel" select="$indentLevel"/>
                    <xsl:with-param name="columns" select="$columns"/>
                    <xsl:with-param name="first" select="true()"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="responseBinding">
            <xsl:if test="$gTesting">
                <xsl:comment>responseBinding</xsl:comment>
            </xsl:if>
            <xsl:apply-templates select="responseBinding">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <xsl:if test="initialValue">
            <xsl:if test="$gTesting">
                <xsl:comment>initialValue</xsl:comment>
            </xsl:if>
            <xsl:apply-templates select="initialValue">
                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- blank row for readability, when there is no following sibling of type simple action -->
        <xsl:if test="following-sibling::* and not(following-sibling::simpleAction[1]) and $indentLevel = 1">
            <row>
                <entry namest="c1">
                    <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:if test="$gTesting">
                        <xsl:comment>Blank Line</xsl:comment>
                    </xsl:if>
                </entry>
            </row>
        </xsl:if>
    </xsl:template>

    <!-- documentationConcept 
            Extract the prompt and response type as rows with "prompt:" and "response:" lables at the $indentLevel,
            and @value content at $indent + 1.
    -->
    <xsl:template match="documentationConcept">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:param name="first" as="xs:boolean" select="false()"/>

        <!-- Row for "prompt:" -->
        <row>
            <entry rowsep="0" colsep="0" align="right" valign="top">
                <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>
                <xsl:if test="$first">
                    <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
                    <xsl:copy-of select="func:getRequiredSymbol(.)"/>
                    <xsl:copy-of select="func:getCardinalitySymbol(..)"/>
                    <xsl:copy-of select="func:getPrecheckSymbol(.)"/>
                    <xsl:copy-of select="func:getVisualStyleBehavior(.)"/></xsl:if>prompt:</entry>
            <entry rowsep="0">
                <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                <xsl:value-of select="prompt/@value"/>
            </entry>
        </row>
        
        <!-- This is an L3 item -->
        <xsl:apply-templates select="itemCodes">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>

        <!-- Row for "response:" -->
        <row>
            <entry colsep="0" rowsep="0" align="right" valign="top">
                <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/><xsl:copy-of select="func:getReadOnlySymbol(.)"/>
                response:</entry>

            <entry rowsep="0">
                <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>

                <xsl:choose>
                    <xsl:when test="string-length(responseDataType/@value) = 0">
                        <emphasis>Response Data Type Needed</emphasis>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="responseDataType/@value"/>
                        <xsl:choose>
                            <xsl:when test="responseCardinality/@value"> (<xsl:value-of select="responseCardinality/@value"/>) </xsl:when>
                            <xsl:otherwise> (Single)</xsl:otherwise>
                        </xsl:choose>

                    </xsl:otherwise>
                </xsl:choose>
            </entry>
        </row>



        <!-- Handle Response Range items  -->
        <xsl:for-each select="responseRange">
            <xsl:choose>
                <xsl:when test="current()[@xsi:type = 'ValueSetConstraint']/constraintType/@value">
                    <row>
                        <entry align="right" colsep="0" rowsep="0">
                            <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>response range:</entry>

                        <entry rowsep="0">
                            <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                            <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>ValueSetConstraint (<xsl:value-of
                                select="current()[@xsi:type = 'ValueSetConstraint']/constraintType/@value"/>
                            <xsl:if test="current()[@xsi:type = 'ValueSetConstraint']/valueSet/@value">, <xsl:value-of
                                    select="current()[@xsi:type = 'ValueSetConstraint']/valueSet/@value"/></xsl:if>) </entry>
                    </row>
                </xsl:when>
                <xsl:when test="current()[@xsi:type = 'EnumerationConstraint']/constraintType/@value">
                    <row>
                        <entry align="right" rowsep="0" colsep="0">
                            <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>response range:</entry>

                        <entry rowsep="0">
                            <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                            <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>EnumerationConstraint (<xsl:value-of
                                select="current()[@xsi:type = 'EnumerationConstraint']/constraintType/@value"/>
                            <xsl:if test="current()[@xsi:type = 'EnumerationConstraint']/valueSet/@value">, <xsl:value-of
                                    select="current()[@xsi:type = 'EnumerationConstraint']/valueSet/@value"/></xsl:if>) </entry>
                    </row>
                    <xsl:if test="current()[@xsi:type = 'EnumerationConstraint']/item[1]">
                        <xsl:for-each select="current()[@xsi:type = 'EnumerationConstraint']/item">
                            <row>
                                <entry align="right" colsep="0" rowsep="0">
                                    <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/><xsl:if
                                        test="current()[@fillIn = 'true']"><link linkend="item_fillin">☞ </link></xsl:if>item:</entry>
                                <entry rowsep="0">
                                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                                    <xsl:if test="current()/displayText/@value">
                                        <xsl:apply-templates select="current()" mode="ExpandItem"/>
                                    </xsl:if>
                                </entry>
                            </row>
                            <xsl:if test="current()/additionalInstructions/@value">
                                <row>
                                    <entry align="right" colsep="0" rowsep="0">
                                        <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>
                                    </entry>
                                    <entry>
                                        <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                                        <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                                        <xsl:value-of select="current()/additionalInstructions/@value"/>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="current()/valueMeaning/@value">
                                <row>
                                    <entry align="right" colsep="0" rowsep="0">
                                        <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>valueMeaning: </entry>
                                    <entry>
                                        <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                                        <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                                        <xsl:value-of select="current()/valueMeaning/@value"/>
                                    </entry>
                                </row>
                            </xsl:if>
                        </xsl:for-each>

                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:if test="additionalInstructions/@value">
            <row>
                <entry rowsep="0" colsep="0" align="right" valign="top">
                    <xsl:attribute name="colname" select="format-number($indentLevel, 'c#')"/>
                </entry>
                <entry rowsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:value-of select="additionalInstructions/@value"/>
                </entry>
            </row>
        </xsl:if>
        <!-- DocumentationConcept Template -->
    </xsl:template>

    <!-- actionRef -->
    <xsl:template match="actionRef" mode="child">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <para>
            <xsl:copy-of select="func:getGroupSelectionSymbol(.)"/>
            <xsl:apply-templates select="textEquivalent"/>
        </para>
    </xsl:template>

    <!-- supportingResources -->
    <xsl:template match="supportingResources">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:apply-templates select="resource" mode="supportingResource">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- resource within a supportingResources element -->
    <xsl:template match="resource" mode="supportingResource">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>

        <xsl:choose>
            <xsl:when test="$indentLevel = 0">
                <para>
                    <xsl:choose>
                        <!-- in-line reference outside table structure-->
                        <xsl:when test="description/@value | title/@value | location/@value">
                            <!-- In-line reference case -->
                            <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                            <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>

                            <xsl:if test="title/@value">
                                <xsl:value-of select="title/@value"/>
                            </xsl:if>
                            <xsl:if test="description/@value">
                                <xsl:value-of select="description/@value"/>
                            </xsl:if>
                            <xsl:if test="location/@value"> ( <link>
                                    <xsl:attribute name="xlink:href" select="location/@value"/> link</link> ) </xsl:if>
                        </xsl:when>
                        <xsl:when test="identifiers/identifier[@root and @extension]">
                            <xsl:call-template name="resolveRelatedResource">
                                <xsl:with-param name="root_param" select="identifiers/identifier/@root"/>
                                <xsl:with-param name="extension_param" select="identifiers/identifier/@extension"/>
                                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                                <xsl:with-param name="columns" select="$columns"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </para>
            </xsl:when>
            <xsl:otherwise>
                <row>
                    <xsl:choose>
                        <!-- in-line reference -->
                        <xsl:when test="description/@value | title/@value | location/@value">
                            <entry>
                                <!-- In-line reference case -->
                                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>

                                <xsl:if test="title/@value">
                                    <xsl:value-of select="title/@value"/>
                                </xsl:if>
                                <xsl:if test="description/@value">
                                    <xsl:value-of select="description/@value"/>
                                </xsl:if>
                                <xsl:if test="location/@value"> ( <link>
                                        <xsl:attribute name="xlink:href" select="location/@value"/> link</link> ) </xsl:if>
                            </entry>
                        </xsl:when>
                        <xsl:when test="identifiers/identifier[@root and @extension]">
                            <xsl:call-template name="resolveRelatedResource">
                                <xsl:with-param name="root_param" select="identifiers/identifier/@root"/>
                                <xsl:with-param name="extension_param" select="identifiers/identifier/@extension"/>
                                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                                <xsl:with-param name="columns" select="$columns"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </row>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- supportingEvidence within an action/actiongGroup-->
    <xsl:template match="supportingEvidence" mode="supportingEvidence">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>
        <xsl:apply-templates select="evidence/resources/resource" mode="supportingEvidence">
            <xsl:with-param name="indentLevel" select="$indentLevel"/>
            <xsl:with-param name="columns" select="$columns"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- resource within a supportingEvidence element -->
    <xsl:template match="resource" mode="supportingEvidence">
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>

        <xsl:choose>
            <xsl:when test="$indentLevel = 0">
                <para>
                    <xsl:choose>
                        <!-- in-line reference outside table structure-->
                        <xsl:when test="description/@value | title/@value | location/@value">
                            <!-- In-line reference case -->
                            <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                            <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>

                            <xsl:if test="title/@value">
                                <xsl:value-of select="title/@value"/>
                            </xsl:if>
                            <xsl:if test="description/@value">
                                <xsl:value-of select="description/@value"/>
                            </xsl:if>
                            <xsl:if test="location/@value"> ( <link>
                                    <xsl:attribute name="xlink:href" select="location/@value"/> link </link> ) </xsl:if>
                        </xsl:when>
                        <xsl:when test="identifiers/identifier[@root and @extension]">
                            <xsl:call-template name="resolveSupportingEvidence">
                                <xsl:with-param name="root_param" select="identifiers/identifier/@root"/>
                                <xsl:with-param name="extension_param" select="identifiers/identifier/@extension"/>
                                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                                <xsl:with-param name="columns" select="$columns"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </para>
            </xsl:when>
            <xsl:otherwise>
                <row>
                    <xsl:choose>
                        <!-- in-line reference -->
                        <xsl:when test="description/@value | title/@value | location/@value">
                            <entry>
                                <!-- In-line reference case -->
                                <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                                <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>

                                <xsl:if test="title/@value">
                                    <xsl:value-of select="title/@value"/>
                                </xsl:if>
                                <xsl:if test="description/@value">
                                    <xsl:value-of select="description/@value"/>
                                </xsl:if>
                                <xsl:if test="location/@value"> ( <link>
                                        <xsl:attribute name="xlink:href" select="location/@value"/> link </link> ) </xsl:if>
                            </entry>
                        </xsl:when>
                        <xsl:when test="identifiers/identifier[@root and @extension]">
                            <xsl:call-template name="resolveSupportingEvidence">
                                <xsl:with-param name="root_param" select="identifiers/identifier/@root"/>
                                <xsl:with-param name="extension_param" select="identifiers/identifier/@extension"/>
                                <xsl:with-param name="indentLevel" select="$indentLevel"/>
                                <xsl:with-param name="columns" select="$columns"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </row>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- 
         **********************************************************************
         Bibliography related pattterns for relatedResources and supportingEvidence
         ********************************************************************** 
    -->

    <!-- Create a bibliography entry (bibliomixed) for resources under a relatedResources element.
         For both related resources and supporting evidence, leverage DocBook's cross reference
         facility by adding the attribute 'xreflabel' to entry.  This will be used later on
         to link to the resource. -->

    <xsl:template match="relatedResources">
        <xsl:for-each select="relatedResource">
            <xsl:for-each select="resources/resource">
                <bibliomixed>
                    <xsl:attribute name="xreflabel">
                        <xsl:value-of select="identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                    </xsl:attribute>
                    <abbrev>
                        <xsl:value-of select="identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                    </abbrev>
                    <citetitle>
                        <xsl:choose>
                            <xsl:when test="citation/@value">
                                <xsl:value-of select="citation/normalize-space(@value)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="title/normalize-space(@value)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </citetitle>
                    <xsl:if test="location/@value"> (<link>
                            <xsl:attribute name="xlink:href" select="location/@value"/>link</link>) </xsl:if>
                </bibliomixed>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- supportingEvidence, output a citation (or series of citations)  
         in-line citation: push out title/description
         
         otherwise:
         Build a sequence that contains:
             (<citation>@identifierName</citation> [(SoR ...), [(QoE ...)]] [, <citation>@identifierName</citation> [(SoR ...), [(QoE ...)]])
    -->
    <xsl:template match="supportingEvidence">
        <xsl:for-each select="evidence/resources/resource">
            <bibliomixed>
                <xsl:attribute name="xreflabel">
                    <xsl:value-of select="identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                </xsl:attribute>
                <abbrev>
                    <xsl:value-of select="identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                </abbrev>
                <citetitle>
                    <xsl:value-of select="citation/normalize-space(@value)"/>
                </citetitle>
                <xsl:if test="location/@value"> (<link>
                        <xsl:attribute name="xlink:href" select="location/@value"/>link</link>) </xsl:if>
            </bibliomixed>
        </xsl:for-each>
    </xsl:template>

    <!-- **********************************************************************
         Tabular List Stub 
         This is just a stub in an L2 document, will be overriden in the L3
         Transform
         **********************************************************************
    -->
    <xsl:template name="CreateTabularList">
        <para> This content is not available in an L2 conceptual structure. </para>
    </xsl:template>

    <!-- **********************************************************************
         **********************************************************************
         Simple Leaf-level patterns
         title, textEquivalent, actionRef 
         ********************************************************************** 
    -->

    <!-- Simple title extract, no enclosing tags -->
    <xsl:template match="title">
        <xsl:value-of select="@value" disable-output-escaping="no"/>
    </xsl:template>

    <!-- Simple description extract, no enclosing tags -->
    <xsl:template match="description">
        <xsl:value-of select="@value" disable-output-escaping="no"/>
    </xsl:template>

    <xsl:template match="textEquivalent">
        <xsl:value-of select="normalize-space(@value)" disable-output-escaping="no"/>
        <xsl:if test="following-sibling::comment() and not($gSuppressComments)">
            <remark>
                <xsl:value-of select="following-sibling::comment()"/>
            </remark>
        </xsl:if>
    </xsl:template>

    <xsl:template match="item" mode="ExpandItem">
        <xsl:value-of select="displayText/@value" disable-output-escaping="no"/>
    </xsl:template>

    <!-- actionSentence is an L3 concept, not projected in L2 output -->
    <xsl:template match="actionSentence"/>


    <!-- 
         **********************************************************************
         Support Functions 
         ********************************************************************** 
    -->
    <!-- Resolve relatedResources, which may appear within a simpleAction -->
    <xsl:template name="resolveRelatedResource">
        <xsl:param name="root_param"/>
        <xsl:param name="extension_param"/>
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>

        <xsl:variable name="myResource"
            select="//relatedResources/relatedResource/resources/resource/identifiers/identifier[@root = $root_param and @extension = $extension_param]/parent::identifiers/parent::resource"/>

        <xsl:choose>
            <xsl:when test="$indentLevel = 0">
                <xsl:choose>
                    <xsl:when test="$myResource">
                        <xsl:value-of select="$myResource/title/@value"/>
                        <link>
                            <xsl:attribute name="xlink:href" select="$myResource/location/@value"/> link</link>
                    </xsl:when>
                    <xsl:otherwise>⚠ Unresolved related resource reference (root='<xsl:value-of select="$root_param"/>', extension='<xsl:value-of
                            select="$extension_param"/>')</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$columns = 1">
                <entry rowsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:choose>
                        <xsl:when test="$myResource">
                            <xsl:if test="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"> (<citation>
                                    <xsl:value-of select="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                                </citation>) </xsl:if>
                            <xsl:value-of select="$myResource/title/@value"/>
                            <xsl:choose>
                                <xsl:when test="$myResource/location/@value">
                                    <link>
                                        <xsl:attribute name="xlink:href" select="$myResource/location/@value"/> link</link>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>⚠ Unresolved related resource reference (root='<xsl:value-of select="$root_param"/>', extension='<xsl:value-of
                                select="$extension_param"/>')</xsl:otherwise>
                    </xsl:choose>
                </entry>
            </xsl:when>
            <xsl:when test="$columns > 1">
                <entry rowsep="0" colsep="0">
                    <xsl:choose>
                        <xsl:when test="$myResource">
                            <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                            <xsl:if test="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"> (<citation>
                                    <xsl:value-of select="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                                </citation>)</xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </entry>
                <entry rowsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:choose>
                        <xsl:when test="$myResource">
                            <xsl:value-of select="$myResource/title/@value"/>
                            <xsl:choose>
                                <xsl:when test="$myResource/location/@value">
                                    <link>
                                        <xsl:attribute name="xlink:href" select="$myResource/location/@value"/> link</link>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>⚠ Unresolved related resource reference (root='<xsl:value-of select="$root_param"/>', extension='<xsl:value-of
                                select="$extension_param"/>')</xsl:otherwise>
                    </xsl:choose>
                </entry>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Resolve supportingEvidence, which may appear within a simpleAction -->
    <xsl:template name="resolveSupportingEvidence">
        <xsl:param name="root_param"/>
        <xsl:param name="extension_param"/>
        <xsl:param name="indentLevel" as="xs:integer"/>
        <xsl:param name="columns" as="xs:integer"/>

        <xsl:variable name="myResource"
            select="//supportingEvidence/evidence/resources/resource/identifiers/identifier[@root = $root_param and @extension = $extension_param]/parent::identifiers/parent::resource"/>

        <xsl:choose>
            <xsl:when test="$indentLevel = 0">
                <xsl:choose>
                    <xsl:when test="$myResource">
                        <xsl:if test="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"> (<citation>
                                <xsl:value-of select="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                            </citation>) </xsl:if>
                        <xsl:value-of select="$myResource/title/@value"/>
                        <link>
                            <xsl:attribute name="xlink:href" select="$myResource/location/@value"/> link </link>
                    </xsl:when>
                    <xsl:otherwise>⚠ Unresolved supporting evidence reference (root='<xsl:value-of select="$root_param"/>', extension='<xsl:value-of
                            select="$extension_param"/>')</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$columns = 1">
                <entry rowsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:choose>
                        <xsl:when test="$myResource">
                            <xsl:if test="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"> (<citation>
                                    <xsl:value-of select="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                                </citation>) </xsl:if>
                            <xsl:value-of select="$myResource/title/@value"/>
                            <link>
                                <xsl:attribute name="xlink:href" select="$myResource/location/@value"/> link</link>
                        </xsl:when>
                        <xsl:otherwise>⚠ Unresolved supporting evidence reference (root='<xsl:value-of select="$root_param"/>',
                                extension='<xsl:value-of select="$extension_param"/>')</xsl:otherwise>
                    </xsl:choose>
                </entry>
            </xsl:when>
            <xsl:when test="$columns > 1">
                <entry rowsep="0" colsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel, 'c#')"/>
                    <xsl:if test="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"> (<citation>
                            <xsl:value-of select="$myResource/identifiers/identifier[@root = 'LocalDocBook']/@identifierName"/>
                        </citation>) </xsl:if>
                </entry>
                <entry rowsep="0">
                    <xsl:attribute name="namest" select="format-number($indentLevel + 1, 'c#')"/>
                    <xsl:attribute name="nameend" select="format-number($columns, 'c#')"/>
                    <xsl:choose>
                        <xsl:when test="$myResource">
                            <xsl:value-of select="$myResource/title/@value"/>
                            <xsl:if test="$myResource/location/@value">
                                <link>
                                    <xsl:attribute name="xlink:href" select="$myResource/location/@value"/> link</link>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>⚠ Unresolved supporting evidence reference (root='<xsl:value-of select="$root_param"/>',
                                extension='<xsl:value-of select="$extension_param"/>')</xsl:otherwise>
                    </xsl:choose>
                </entry>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- isVisualGroup -->
    <xsl:function name="func:isVisualGroup" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:sequence
            select="name($node) = 'actionGroup' and $node/behaviors/behavior[@xsi:type = 'GroupOrganizationalBehavior' and @value = 'VisualGroup']"/>
    </xsl:function>


    <xsl:function name="func:getGroupOrganizationSymbol">
        <xsl:param name="n"/>

        <xsl:variable name="groupOrganizationBehavior" select="$n/behaviors/behavior[@xsi:type = 'GroupOrganizationBehavior'][last()]"/>

        <xsl:choose>
            <xsl:when test="$groupOrganizationBehavior">
                <xsl:if test="$groupOrganizationBehavior/@value = 'SentenceGroup'">Sentence <link linkend="go_s">▶</link></xsl:if>
                <xsl:if test="$groupOrganizationBehavior/@value = 'LogicalGroup'">Logical <link linkend="go_l">▷</link></xsl:if>
                <xsl:if test="$groupOrganizationBehavior/@value = 'VisualGroup'">Visual <link linkend="go_v">➤</link></xsl:if>
                <xsl:if
                    test="not($groupOrganizationBehavior/@value = 'SentenceGroup' or $groupOrganizationBehavior/@value = 'LogicalGroup' or $groupOrganizationBehavior/@value = 'VisualGroup')"
                    > &#9888; Unknown Group Type for node <xsl:value-of select="name($n)"/>: '<xsl:value-of select="$groupOrganizationBehavior/@value"
                    />' </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="func:getGroupSelectionSymbol">
        <xsl:param name="n" as="node()"/>

        <xsl:variable name="p" select="($n/ancestor::actionGroup/behaviors/behavior[@xsi:type = 'GroupSelectionBehavior'])[last()]"/>

        <xsl:choose>
            <xsl:when test="$p">
                <xsl:if test="$p/@value = 'Any'">
                    <link linkend="gs_any">☐ </link>
                </xsl:if>
                <xsl:if test="$p/@value = 'All'">
                    <link linkend="gs_all">◉ </link>
                </xsl:if>
                <xsl:if test="$p/@value = 'AllOrNone'">
                    <link linkend="gs_allnone">◎ </link>
                </xsl:if>
                <xsl:if test="$p/@value = 'ExactlyOne'">
                    <link linkend="gs_xactone">○ </link>
                </xsl:if>
                <xsl:if test="$p/@value = 'AtMostOne'">
                    <link linkend="gs_atmostone">✪ </link>
                </xsl:if>
                <xsl:if test="$p/@value = 'OneOrMore'">
                    <link linkend="gs_onemore">❂ </link>
                </xsl:if>
                <xsl:if
                    test="not($p/@value = 'Any' or $p/@value = 'All' or $p/@value = 'AllOrNone' or $p/@value = 'ExactlyOne' or $p/@value = 'AtMostOne' or $p/@value = 'OneOrMore')"
                    > &#9888; Unknown Group Type for node <xsl:value-of select="name($n)"/>: '<xsl:value-of select="$p/@value"/>' </xsl:if>
            </xsl:when>
            <!-- always return a space for kerning -->
            <xsl:otherwise>  </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Determine required behavior symbol, according to the specification, this only applies to a single action -->
    <xsl:function name="func:getRequiredSymbol">
        <xsl:param name="n" as="node()"/>

        <xsl:variable name="requiredBehavior"
            select="($n/ancestor::actionGroup/behaviors/behavior[@xsi:type = 'RequiredBehavior'], $n/../behaviors/behavior[@xsi:type = 'RequiredBehavior'], $n/behaviors/behavior[@xsi:type = 'RequiredBehavior'])[last()]"/>

        <xsl:if test="$requiredBehavior">
            <xsl:choose>
                <xsl:when test="$requiredBehavior/@value = 'Must'">
                    <link linkend="req_must">✦ </link>
                </xsl:when>
                <xsl:when test="$requiredBehavior/@value = 'Could'">
                    <link linkend="req_could">✧ </link>
                </xsl:when>
                <xsl:when test="$requiredBehavior/@value = 'MustUnlessDocumented'">
                    <link linkend="req_mustud">➢ </link>
                </xsl:when>
                <xsl:otherwise>&#9888; Unknown RequiredBehavior Value<xsl:value-of
                        select="$n/behaviors/behavior[@xsi:type = 'RequiredBehavior']/@value"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="func:getPrecheckSymbol">
        <xsl:param name="n" as="node()"/>

        <xsl:variable name="precheckBehavior"
            select="($n/../behaviors/behavior[@xsi:type = 'PrecheckBehavior'], $n/behaviors/behavior[@xsi:type = 'PrecheckBehavior'])[last()]"/>


        <xsl:if test="$precheckBehavior">
            <xsl:choose>
                <xsl:when test="$precheckBehavior/@value = 'Yes'">
                    <link linkend="preck_yes">▲ </link>
                </xsl:when>
                <xsl:when test="$precheckBehavior/@value = 'No'">
                    <link linkend="preck_yes">▽ </link>
                </xsl:when>
                <xsl:otherwise>&#9888; Unknown PrecheckBehavior Value<xsl:value-of select="$precheckBehavior/@value"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="func:getCardinalitySymbol">
        <xsl:param name="n" as="node()"/>

        <xsl:variable name="cardinalityBehavior" select="($n/behaviors/behavior[@xsi:type = 'CardinalityBehavior'])[last()]"/>

        <xsl:if test="$cardinalityBehavior">
            <xsl:choose>
                <xsl:when test="$cardinalityBehavior/@value = 'Single'">
                    <link linkend="card_single">◆ </link>
                </xsl:when>
                <xsl:when test="$cardinalityBehavior/@value = 'Multiple'">
                    <link linkend="card_single">❖ </link>
                </xsl:when>
                <xsl:otherwise>&#9888; Unknown CardinalityBehavior Value<xsl:value-of select="$cardinalityBehavior/@value"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="func:getVisualStyleBehavior">
        <xsl:param name="n" as="node()"/>

        <xsl:variable name="visualStyleBehavior"
            select="($n/ancestor::actionGroup/behaviors/behavior[@xsi:type = 'VisualStyleBehavior'], $n/../behaviors/behavior[@xsi:type = 'VisualStyleBehavior'], $n/behaviors/behavior[@xsi:type = 'VisualStyleBehavior'])[last()]"/>

        <xsl:choose>
            <xsl:when test="$visualStyleBehavior">〖 <xsl:value-of select="$visualStyleBehavior/@value"/>〗 </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="func:getReadOnlySymbol">
        <xsl:param name="n" as="node()"/>

        <xsl:variable name="readOnlyBehavior"
            select="($n/ancestor::actionGroup/behaviors/behavior[@xsi:type = 'ReadOnlyBehavior'], $n/behaviors/behavior[@xsi:type = 'ReadOnlyBehavior'])[last()]"/>

        <xsl:choose>
            <xsl:when test="$readOnlyBehavior">
                <link linkend="item_readonly">☆ </link>
            </xsl:when>
        </xsl:choose>

    </xsl:function>

    <xsl:template name="maxSubElementDepth">
        <xsl:param name="start-node" as="node()"/>
        <xsl:variable name="vDepths" as="xs:integer*">
            <xsl:apply-templates select="$start-node" mode="DepthCount">
                <xsl:with-param name="depth" select="1"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="max($vDepths)"/>
    </xsl:template>

    <xsl:template match="actionGroup" mode="DepthCount">
        <xsl:param name="depth" as="xs:integer"/>
        <xsl:variable name="current" select="$depth"/>

        <xsl:variable name="offset" as="xs:integer">
            <xsl:choose>
                <xsl:when test="subElements/simpleAction/actionSentence">2</xsl:when>
                <xsl:when test="subElements/simpleAction/conditions/condition/logic">2</xsl:when>
                <xsl:when test="subElements/simpleAction[@xsi:type = 'CollectInformationAction']">2</xsl:when>
                <xsl:when test="subElements/simpleAction/supportingResources">2</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$depth + $offset"/>
        <xsl:if test="not(empty(subElements/actionGroup))">
            <xsl:apply-templates select="subElements/actionGroup" mode="DepthCount">
                <xsl:with-param name="depth" select="$depth + $offset"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- because xslt is inherently stupid, make a recursive for loop -->
    <xsl:template name="buildColumnDef">
        <xsl:param name="columns"/>
        <xsl:param name="current" select="1"/>
        <xsl:choose>
            <xsl:when test="$current &lt;= $columns">
                <colspec align="left">
                    <xsl:attribute name="colname" select="format-number($current, 'c#')"/>
                    <xsl:attribute name="colnum" select="$current"/>
                    <xsl:if test="$current = 1">
                        <xsl:attribute name="colwidth" select="'0.25*'"/>
                    </xsl:if>
                </colspec>
                <xsl:call-template name="buildColumnDef">
                    <xsl:with-param name="current" select="$current + 1"/>
                    <xsl:with-param name="columns" select="$columns"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
