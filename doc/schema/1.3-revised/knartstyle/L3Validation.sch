<!-- 
    Copyright © 2017-2018 Cognitive Medical Systems Inc.
    All rights reserved. No part of this content may be reproduced, distributed, or transmitted in any form or by any means, including photocopying, 
    recording, or other electronic or mechanical methods, without the prior written permission of the publisher, except in the case of brief quotations 
    embodied in critical reviews and certain other noncommercial uses permitted by copyright law. For permission requests, write to the publisher, 
    addressed “Attention: Permissions Coordinator,” at the address below.
    9444 Waples Street, Suite 300 San Diego, CA 92121
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <sch:ns uri="urn:hl7-org:knowledgeartifact:r1" prefix="kn"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
    <sch:ns uri="urn:hl7-org:elm:r1" prefix="elm"/>
    <sch:ns uri="urn:hl7-org:cdsdt:r2" prefix="dt"/>


    <sch:p>This schema validates KNART XML for L3 compliance issues.</sch:p>
    <xsl:key name="expressionDefinitionKeys" match="//kn:def" use="@name"/>
    <sch:pattern>
        <sch:title>Check expressionRefs link to defined expressions</sch:title>

        <sch:rule context="//*[@xsi:type = 'elm:ExpressionRef']">
            <sch:assert test="count(key('expressionDefinitionKeys', @name)) = 1">ExpressionRef '<sch:value-of select="@name"/>' does not exist. All
                elm:ExpressionRef elements must reference an existing named expression.</sch:assert>
        </sch:rule>

        <sch:rule context="//kn:def">
            <sch:assert test="count(key('expressionDefinitionKeys', @name)) = 1">externalData expression names, expression names, and trigger names
                cannot overlap</sch:assert>
        </sch:rule>
    </sch:pattern>

    <xsl:key name="expressionRefKeys" match="//*[@xsi:type = 'elm:ExpressionRef']" use="@name"/>
    <sch:pattern>
        <sch:title>Check all def elements have at least one inbound link</sch:title>
        <sch:rule context="/kn:knowledgeDocument//kn:def[not(parent::kn:trigger)]">
            <sch:assert test="count(key('expressionRefKeys', @name)) >= 1">Expression '<sch:value-of select="@name"/>' is not used. All def elements
                must referenced by at least one ExpressionRef</sch:assert>
        </sch:rule>
    </sch:pattern>

    <xsl:key name="expressionPropertyPathKeys" match="//elm:*[@xsi:type = 'elm:Property']" use="@path"/>
    <sch:pattern>
        <sch:title>Check expressionPropertyPathKeys link to defined expressions</sch:title>

        <sch:rule context="//kn:responseBinding">
            <sch:assert test="count(key('expressionPropertyPathKeys', @property)) &gt;= 1">responseBinding @property reference '<sch:value-of
                    select="@property"/> (used <sch:value-of select="count(key('expressionPropertyPathKeys', @property))"/> times)' does not exist.
                All responseBinding @property references must reference an existing named property path.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <xsl:key name="responseBindingPropertyKeys" match="//kn:responseBinding" use="@property"/>
    <sch:pattern>
        <sch:title>Check responseBindingPropertyKeys link to defined expressions</sch:title>

        <sch:rule context="//elm:operand[@xsi:type = 'elm:Property' and not(ancestor-or-self::elm:where)]">
            <sch:assert test="count(key('responseBindingPropertyKeys', @path)) = 1">elm:operands[@xsi:type='elm:Property']/@path reference
                    '<sch:value-of select="@path"/>' does not exist. All elm:operands[@xsi:type='elm:Property']/@path references must be set to an
                existing named responseBinding property.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <xsl:key name="definedCodeSystemKeys" match="//kn:knowledgeDocument/kn:externalData/kn:codesystem" use="@name"/>
    <sch:pattern>
        <sch:title>Identify any uncoded value of type elm:Code, of value elements under coverage elements</sch:title>
        <sch:rule context="//kn:value[@xsi:type = 'elm:Code']">
            <sch:assert test="not(contains(@code, 'TSR'))">Incomplete Terminology Service Request (@code='<sch:value-of select="@code"
                />')</sch:assert>

            <sch:assert test="elm:system/@name">elm:system/@name is required.</sch:assert>

            <sch:assert test="string-length(elm:system/@name) &gt; 0">elm:system/@name cannot be empty.</sch:assert>

            <sch:assert test="not(contains(elm:system/@name, 'TSR'))">Incomplete Terminology Service Request (elm:system/@name='<sch:value-of
                    select="elm:system/@name"/>')</sch:assert>
        </sch:rule>
        
        <sch:rule context="//kn:coverage/kn:value">
            <sch:assert test="not(contains(@code, 'TSR'))">Incomplete Terminology Service Request (@code='<sch:value-of select="@code"
            />')</sch:assert>
            
            <sch:assert test="@codeSystem">@codeSystem is required.</sch:assert>
            
            <sch:assert test="string-length(@codeSystem) &gt; 0">@codeSystem cannot be empty.</sch:assert>
            
            <sch:assert test="not(contains(@codeSystem, 'TSR'))">Incomplete Terminology Service Request (@codeSystem='<sch:value-of
                select="elm:system/@name"/>')</sch:assert>
        </sch:rule>
        
        <sch:rule context="//kn:concept">
            <sch:assert test="not(contains(@codeSystemName, 'TSR'))">Incomplete Terminology Service Request (@codeSystemName='<sch:value-of
                    select="@codeSystemName"/>')</sch:assert>

            <sch:assert test="not(contains(@codeSystem, 'TSR'))">Incomplete Terminology Service Request (@codeSystem='<sch:value-of
                    select="@codeSystem"/>')</sch:assert>

            <sch:assert test="@codeSystem">@codeSystem is required.</sch:assert>

            <sch:assert test="(count(key('definedCodeSystemKeys', @codeSystem)) >= 1)">Please use a defined code system
                (externalData/codesystem)</sch:assert>

            <sch:assert test="string-length(@codeSystem) &gt; 0">@codeSystem cannot be empty.</sch:assert>
        </sch:rule>

        <sch:rule context="//elm:system">
            <sch:assert
                test="(ancestor-or-self::*[@classType = 'anf:TSR-NoModel'] and @name = 'TSR') or (count(key('definedCodeSystemKeys', @name)) >= 1)"
                >Unsupported code system: <sch:value-of select="@name"/>, please use a defined code system (externalData/codesystem); or use TSR and
                set classType to anf:TSR-NoModel</sch:assert>
        </sch:rule>

        <sch:rule context="//kn:code">
            <sch:assert test="@codeSystem">@codeSystem is required.</sch:assert>

            <sch:assert test="string-length(@codeSystem) &gt; 0">@codeSystem cannot be empty.</sch:assert>

            <sch:assert test="not(contains(@codeSystem, 'TSR')) or @code = 'TSR-NoCode'"><sch:value-of select="name()"/>: Incomplete Terminology
                Service Request (@codeSystem='<sch:value-of select="@codeSystem"/>')</sch:assert>

            <sch:assert test="(count(key('definedCodeSystemKeys', @codeSystem)) >= 1)">Please use a defined code system
                (externalData/codesystem)</sch:assert>
        </sch:rule>

        <sch:rule context="//kn:itemCode">
            <sch:assert test="@codeSystem">@codeSystem is required.</sch:assert>

            <sch:assert test="string-length(@codeSystem) &gt; 0">@codeSystem cannot be empty.</sch:assert>

            <sch:assert test="not(contains(@codeSystem, 'TSR')) or @code = 'TSR-NoCode'"><sch:value-of select="name()"/>: Incomplete Terminology
                Service Request (@codeSystem='<sch:value-of select="@codeSystem"/>')</sch:assert>

            <sch:assert test="(count(key('definedCodeSystemKeys', @codeSystem)) >= 1)">Please use a defined code system
                (externalData/codesystem)</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:title>Identify any elm:elements that have missing or incorrect display attributes</sch:title>

        <sch:rule context="//elm:*[@xsi:type = 'elm:Code' and @display = 'Precoordinated Expression']">
            <sch:assert test="elm:system[@name = 'SNOMED CT'] and (string-length(@code) - string-length(translate(@code, '|', '')) &lt;= 2)">@display
                should be 'Postcoordinated Expression'</sch:assert>

            <sch:assert test="@code and string-length(@code) &gt; 0">If @code is present, it must have a non-zero length.</sch:assert>
        </sch:rule>

        <sch:rule context="//elm:*[@xsi:type = 'elm:Code']">
            <sch:assert test="not(@code) or string-length(@code) &gt; 0">If @code is present, it must have a non-zero length.</sch:assert>

            <sch:assert test="not(contains(@code, 'TSR')) or @code = 'TSR-NoCode'"><sch:value-of select="name()"/>: Incomplete Terminology Service
                Request (@code='<sch:value-of select="@code"/>')</sch:assert>

            <sch:assert test="@display and string-length(@display) &gt; 0">@display is required (e.g. "Precoordinated Expression" or "Postcoordinated
                Expression" if codeSystem is SNOMED CT)</sch:assert>

            <sch:assert test="@code and string-length(@code) &gt; 0">All elements of type elm:Code must specify @code</sch:assert>
        </sch:rule>

        <sch:rule context="//kn:itemCodes">
            <sch:assert test="kn:itemCode[not(@code) or string-length(@code) &gt; 0]">If @code is present, it must have a non-zero
                length.</sch:assert>

            <sch:assert test="kn:itemCode/dt:displayName[@value and string-length(@value) > 0]">If @code is present, dt:displayName is
                required.</sch:assert>
        </sch:rule>

        <sch:rule context="//kn:itemCodes/kn:itemCode[dt:displayName/@value = 'Precoordinated Expression']">
            <sch:assert test="@codeSystem = 'SNOMED CT' and (string-length(@code) - string-length(translate(@code, '|', '')) &lt;= 2)"
                >dt:displayName/@value should be 'Postcoordinated Expression'</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:title>Identify any uncoded elm:elements</sch:title>
        <sch:rule context="//elm:operand[@xsi:type = 'elm:Literal']">
            <sch:assert test="not(contains(@value, 'TSR')) or @code = 'TSR-NoCode'"><sch:value-of select="name()"/>: Incomplete Terminology Service
                Request (@value='<sch:value-of select="@value"/>')</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:title>Identify any uncoded elm:elements</sch:title>
        <sch:rule context="//kn:concept">
            <sch:assert test="not(contains(@code, 'TSR')) or @code = 'TSR-NoCode'"><sch:value-of select="name()"/>: Incomplete Terminology Service
                Request (@code='<sch:value-of select="@code"/>')</sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>
