<?xml version="1.0" encoding="UTF-8"?>
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

    <sch:p>This schema validates KNART XML documents for syle issues, beyond basic structure expressed in the KAS Standard</sch:p>
    <sch:pattern>
        <sch:title>Test Contract Identifier Validity</sch:title>

        <!-- Contract Identifer. This identifier is used to identify the contract and CLIN for the KNART Report deliverable -->
        <sch:let name="contract" value="'urn:va.gov:kbs:contract:VA118-16-D-1008:to:VA-118-16-F-1008-0007'"/>
        <sch:let name="contractIdNamePrefix" value="'Contract: VA118-16-D-1008, Task Order (TO): VA-118-16-F-1008-0007,'"/>
        <sch:let name="CLINPrefix" value="'CLIN'"/>

        <!-- Test for existence of a contract identifier -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers">
            <sch:assert test="kn:identifier[@root = $contract]">The contract identifier is missing, one identifer element for the contract is required
                    (@root=<sch:value-of select="$contract"/>)</sch:assert>
        </sch:rule>

        <!-- Test content of contract identifier -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers/kn:identifier[@root = $contract]">

            <sch:assert test="starts-with(@identifierName, $contractIdNamePrefix)">The identifierName of the contract identifier must start with
                    '<sch:value-of select="$contractIdNamePrefix"/>'.</sch:assert>

            <sch:assert test="starts-with(@extension, $CLINPrefix)">The @extension attribute must contain a CLIN number, i.e. starts with
                    '<sch:value-of select="$CLINPrefix"/>', @extension was specified as '<sch:value-of select="@extension"/>'<sch:value-of
                    select="$CLINPrefix"/>'.</sch:assert>

            <sch:assert test="ends-with(@identifierName, @extension)">The CLIN specified in the @extension must match the end of the @identifierName.
                Currently @extension = '<sch:value-of select="@extension"/>' and does not match the end of @identifierName</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="Metadata">
        <sch:title>Check for issues with metadata section</sch:title>
        <sch:rule context="kn:knowledgeDocument">
            <sch:assert test="kn:metadata">The metadata section is required (not found).</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata">
            <sch:assert test="kn:publishers">The metadata "publishers" section is required (not found).</sch:assert>
            <sch:assert test="kn:usageTerms">The metadata "usageTerms" section is required (not found).</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:usageTerms">
            <sch:assert test="kn:rightsDeclaration">The metadata "rightsDeclaration" section (in usageTerms) is required (not found).</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:usageTerms/kn:rightsDeclaration">
            <sch:assert test="kn:assertedRights[@value = 'Copyright']">The metadata "rightsDeclaration" section must include an assertedRights element
                with @value='Copyright'.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="Contributors">
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:contributions/kn:contribution/kn:contributor[@xsi:type = 'Person']/kn:affiliation">
            <sch:assert test="not(matches(lower-case(kn:name/@value), 'sme.*$'))">Roles such as "SME" or "SME, Secondary" should not be included in
                the affiliation element</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="KNART-Ids">
        <!-- KNART Identifier.  This identifier is a unique identifier that also contains a human readible 'bingo' id 
             used in the contract and discussion with the VA. -->
        <sch:let name="knart" value="'urn:va.gov:kbs:knart:artifact:r1'"/>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers">
            <sch:assert test="kn:identifier[@root = $knart]">No KNART identifier found, an element with @root='<sch:value-of select="$knart"/>' must
                be specified.</sch:assert>
        </sch:rule>

        <!-- Make sure the 'bingo' number is part of the primary identifier.  NOTE: Combined KNARTS may have multiple bingo numbers -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers/kn:identifier[@root = $knart]">
            <sch:assert test="matches(@identifierName, '^([BO]\d+)+$')">The KNART identifier must include an identifierName of the form Bn or On,
                where n is a number. @identifierName was specified as '<sch:value-of select="@identifierName"/>'.</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers/kn:identifier[@root = $knart]">
            <sch:assert test="string-length(@version) > 0">The KNART identifier must include a version number (e.g. 0.1)</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="Jira-Ids">
        <!-- Jira Identifier -->
        <sch:let name="jira" value="'urn:cognitivemedicine.com:lab:jira'"/>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers">
            <sch:assert test="kn:identifier[@root = $jira]">The Jira identifier is missing, one identifer element specifying the Jira identifier for
                this KNART is required (@root=<sch:value-of select="$jira"/>).</sch:assert>
        </sch:rule>

        <!-- Test content of the Jira identifier -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:identifiers/kn:identifier[@root = $jira]">
            <sch:assert test="ends-with(@identifierName, @extension)">The Jira identifier specified in @extension ('<sch:value-of select="@extension"
                />') does not match the end of the @identifierName'.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="OtherMetaData">
        <sch:rule context="kn:knowledgeDocument/kn:metadata">
            <sch:assert test="kn:artifactType">The KNART artifact type must be specified using the artifactType element.</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:title">
            <sch:assert test="ends-with(@value, ../kn:artifactType/@value)">The KNART artifact type (<sch:value-of select="../kn:artifactType/@value"
                />) must appear at the end of the artifact title.</sch:assert>
        </sch:rule>
    </sch:pattern>


    <sch:pattern id="RelatedResources">
        <sch:let name="csd" value="'Conceptual Structure Document'"/>
        <sch:let name="kvrpt" value="'KNART Validation Report'"/>

        <sch:rule context="kn:knowledgeDocument/kn:metadata">
            <sch:assert test="kn:relatedResources">All KNARTs must include a relatedResources section.</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:relatedResources">
            <sch:assert test="count(kn:relatedResource) &gt;= 3">All KNARTs must include at least 3 relatedResource elements.</sch:assert>
        </sch:rule>

        <!-- Check 1st relatedResource -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:relatedResources/kn:relatedResource[1]">
            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook' and @identifierName = 'CCWP']">The first
                related resource entry must be a reference to the Clinical Content White Paper, with @root='LocalDocBook' and the @identiferName must
                be set to 'CCWP'.</sch:assert>

            <sch:assert test="kn:relationship[@value = 'DerivedFrom']">The first related resource must include a relationship element with
                @value='DerivedFrom', it is currently set to '<sch:value-of select="kn:relationship/@value"/>'.</sch:assert>
            <sch:assert test="not(kn:resources/kn:resource/kn:location)">The location element should not be specified for the CCWP</sch:assert>
        </sch:rule>

        <!-- Check 2nd relatedResource -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:relatedResources/kn:relatedResource[2]">


            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook' and @identifierName = 'CSD']">The second
                related resource entry must be a reference to the Conceptual Structure Document, with @root='LocalDocBook' and the @identiferName must
                be set to 'CSD'.</sch:assert>

            <sch:assert test="kn:relationship[@value = 'AssociatedResource']">The second related resource must include a relationship element with
                @value='AssociatedResource', it is currently set to '<sch:value-of select="kn:relationship/@value"/>'.</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract]">The second related resource must have an
                identifier with @root='<sch:value-of select="$contract"/>'</sch:assert>

            <sch:assert
                test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract and starts-with(@identifierName, $contractIdNamePrefix)]"
                >The second related resource must have an @identifier with root='<sch:value-of select="$contract"/>' and @identifierName that begins
                with '<sch:value-of select="$contractIdNamePrefix"/>'</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract and starts-with(@extension, $CLINPrefix)]">The
                second related resource must have an @identifier with root='<sch:value-of select="$contract"/>' and @extension that starts
                    with'<sch:value-of select="$CLINPrefix"/>'</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract and ends-with(@identifierName, @extension)]">The
                second related resource must have an @identifier with root='<sch:value-of select="$contract"/>' and @identifierName that ends with
                    '<sch:value-of select="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract]/@extension"/>'</sch:assert>

            <sch:assert test="not(kn:resources/kn:resource/kn:description)">The description element should not be used for the CSD
                relatedResource.</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:title[ends-with(@value, $csd)]">The title of the second related resource must end with
                    <sch:value-of select="$csd"/>"/> </sch:assert>

            <sch:assert test="not(kn:resources/kn:resource/kn:location)">The location element should not be specified for the CSD</sch:assert>
        </sch:rule>

        <!-- Check 3rd relatedResource -->
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:relatedResources/kn:relatedResource[3]">
            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook' and @identifierName = 'KVRpt']">The third
                related resource entry must be a reference to the KNART Validation Report, with @root='LocalDocBook' and the @identiferName must be
                set to 'KVRpt'.</sch:assert>

            <sch:assert test="kn:relationship[@value = 'AssociatedResource']">The third related resource must include a relationship element with
                @value='AssociatedResource', it is currently set to '<sch:value-of select="kn:relationship/@value"/>'.</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract]">The third related resource must have an
                identifier with @root='<sch:value-of select="$contract"/>'</sch:assert>

            <sch:assert
                test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract and starts-with(@identifierName, $contractIdNamePrefix)]"
                >The third related resource must have an identifier with @root='<sch:value-of select="$contract"/>' and @identifierName that begins
                with '<sch:value-of select="$contractIdNamePrefix"/>'</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract and starts-with(@extension, $CLINPrefix)]">The
                third related resource must have an @identifier with @root='<sch:value-of select="$contract"/>' and @extension that starts
                    with'<sch:value-of select="$CLINPrefix"/>'</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract and ends-with(@identifierName, @extension)]">The
                third related resource must have an @identifier with @root='<sch:value-of select="$contract"/>' and @identifierName that ends with
                    '<sch:value-of select="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = $contract]/@extension"/>'</sch:assert>

            <sch:assert test="not(kn:resources/kn:resource/kn:description)">The description element should not be used for the KVRpt
                relatedResource.</sch:assert>

            <sch:assert test="kn:resources/kn:resource/kn:title[ends-with(@value, $kvrpt)]">The title of the second related resource must end with
                    <sch:value-of select="$kvrpt"/>"/> </sch:assert>

            <sch:assert test="not(kn:resources/kn:resource/kn:location)">The location element should not be specified for the KVRpt</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:relatedResources/kn:relatedResource/kn:resources/kn:resource/kn:identifiers">
            <sch:assert test="kn:identifier[@root = 'LocalDocBook']">All related resource entries must have a LocalDocBook identifier, this allows
                them to be projected into the bibliography of the Conceptual Structure Document. <sch:value-of select="kn:identifier/text()"
                /></sch:assert>
        </sch:rule>

        <sch:rule
            context="kn:knowledgeDocument/kn:metadata/kn:relatedResources/kn:relatedResource/kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook']">
            <sch:assert test="matches(@extension, '^sr\d+$')">All related resource entries must set @extension to pattern matching 'sr' followed by an
                unsigned integer, currently it is set to '<sch:value-of select="@extension"/>'.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Validation of keys for related resources and supporting evidence keys, this allows resources to be declared exactly once
         but can then be referenced multiple times -->
    <xsl:key name="ResourceKeys" match="kn:knowledgeDocument/kn:metadata//kn:identifier" use="concat(@root, @extension)"/>
    <sch:pattern>
        <sch:title>Test identifiers for uniqueness in the metadata section</sch:title>
        <sch:rule context="kn:knowledgeDocument/kn:metadata//kn:identifier">
            <sch:assert test="count(key('ResourceKeys', concat(@root, @extension))) = 1">Key (@root='<sch:value-of select="@root"/>',
                    @extension='<sch:value-of select="@root"/>') already used. All related resource and supporting evidence must have a unique key
                (root, extension).</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- All Evidence and Related Resource Patterns -->
    <xsl:key name="AllResourcesRootKeys" match="kn:knowledgeDocument/kn:metadata//kn:identifier" use="@identifierName"/>
    <sch:pattern id="AllResourcePatterns">
        <sch:rule context="kn:knowledgeDocument/kn:metadata//kn:identifier[@root = 'LocalDocBook']">
            <sch:assert test="@identifierName and string-length(@identifierName) &gt;= 3">All references must include an identifierName
                attribute--this is used as a key to link to the bibliography and is typically Author Last name Year.</sch:assert>

            <sch:assert test="count(key('AllResourcesRootKeys', @identifierName)) = 1">All resources and identifiers identifiers must have a
                identifierName. If a resource could be listed under either supporting evidence or under related resources, cite only under supporting
                evidence.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Validation of Supporting Evidence -->
    <xsl:key name="EvidenceKeys" match="kn:identifier" use="concat(@root, @extension)"/>

    <sch:pattern id="SupportingEvidence">
        <sch:rule context="kn:knowledgeDocument/kn:metadata">
            <sch:assert test="kn:supportingEvidence or kn:relatedResources">All KNARTs must include a supportingEvidence or relatedResources
                section.</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource/kn:identifiers">
            <sch:assert test="kn:identifier[@root = 'LocalDocBook']">All supporting evidence entries must have a LocalDocBook identifier, this allows
                them to be projected into the bibliography of the Conceptual Structure Document.</sch:assert>
        </sch:rule>

        <sch:rule
            context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook']">
            <sch:assert test="matches(@extension, '^e\d+$')">All LocalDocBook evidence entries must have the @extension attribute set to 'e' + a
                number, currently it is set to '<sch:value-of select="@extension"/>'.</sch:assert>
        </sch:rule>

        <sch:rule
            context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook']">
            <sch:assert test="string-length(@identifierName) &gt; 0">All LocalDocBook evidence entries must have the @identifierName attribute set,
                currently it is set to '<sch:value-of select="@identifierName"/>'.</sch:assert>
        </sch:rule>

        <sch:rule
            context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'https://doi.org']">
            <sch:assert test="@identifierName = 'DOI'">All Digital Object Identfiers (DOI) must have the @identifierName attribute set to
                'DOI'.</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource/kn:identifiers/kn:identifier">
            <sch:assert test="count(key('EvidenceKeys', concat(@root, @extension))) = 1">All evidence identifiers must have a unique key.</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource">
            <sch:assert test="contains(kn:citation/@value, kn:title/@value)">The title of a supporting evidence resource (<sch:value-of
                    select="kn:title/@value"/>) must appear in the citation</sch:assert>
        </sch:rule>

        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence/kn:resources/kn:resource">
            <sch:assert
                test="not(kn:identifiers/kn:identifier[@root = 'https://doi.org']) or (contains(kn:citation/@value, 'doi:') and contains(kn:citation/@value, kn:identifiers/kn:identifier[@root = 'https://doi.org']/@extension))"
                >If a citation contains "doi:", and a "https://doi.org" identifier (<sch:value-of
                    select="kn:identifiers/kn:identifier[@root = 'https://doi.org']/@extension"/>), the doi codes should match.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <xsl:key name="IdentifierNameKeys" match="kn:identifier" use="(concat(@root, @identifierName))"/>
    <sch:pattern>
        <sch:rule context="//*/kn:metatdata//kn:identifier">
            <sch:assert test="count(key('IdentifierNameKeys', concat(@root, @identifierName))) = 1 or not(@root = 'LocalDocBook')">All evidence and
                related resources LocalDocBook entries must have a unique @identifierName ('<sch:value-of select="@identifierName"/>' is not unique
                across identifiers with root='<sch:value-of select="@root"/>').</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="SupportingEvidence2">
        <sch:rule context="kn:knowledgeDocument/kn:metadata/kn:supportingEvidence/kn:evidence">
            <sch:assert test="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook']/@extension = concat('e', position())">All
                LocalDocBook evidence entries must have the @extension attribute set to this format en, where n is its position in the list. Currently
                @extension is set to '<sch:value-of select="kn:resources/kn:resource/kn:identifiers/kn:identifier[@root = 'LocalDocBook']/@extension"
                />,' it should be '<sch:value-of select="concat('e', position())"/>.'</sch:assert>
        </sch:rule>
    </sch:pattern>


    <!-- actionGroups and Behaviors -->
    <sch:pattern id="GroupBehaviors">
        <sch:rule context="//kn:simpleAction/kn:behaviors/kn:behavior">
            <sch:assert test="not(starts-with(@xsi:type, 'Group'))">GroupOrganizationBehavior behavior elements, such as <sch:value-of
                    select="@xsi:type"/>, are only valid inside actionGroups, not part of simpleAction elements</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Special case group behaviors with "at most one"-->
    <sch:pattern id="GroupBehaviorsAtMostOne">
        <sch:rule context="//kn:actionGroup">
            <sch:assert
                test="not(kn:behaviors/kn:behavior[@xsi:type = 'GroupSelectionBehavior' and @value = 'AtMostOne'] and count(kn:subElements/*) = 1)"
                >'Any' is preferred. GroupSelectionBehavior @value='AtMostOne' should only be used when there is more than one choice.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- actionGroup -->
    <sch:pattern id="actionGroup">
        <sch:rule context="/kn:knowledgeDocument//kn:actionGroup/kn:description">
            <sch:assert test="not(@value = '')">The description element, when present, must contain a non-empty value attribute.</sch:assert>
            <sch:assert test="preceding-sibling::kn:title[1][not(@value = '')]"><sch:value-of select="preceding-sibling::kn:*[1]/@name"/>The title
                element is required when a description is set.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- simpleAction xsi:type='CreateAction' -->
    <sch:pattern id="simpleActionChecks">
        <sch:rule context="//kn:simpleAction[@xsi:type = 'CreateAction']/kn:textEquivalent">
            <sch:assert test="not(starts-with(lower-case(@value), 'consider '))">One cannot order someone to "consider" something. Does this text
                belong in a description?</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Spaces -->
    <sch:pattern id="WhiteSpaceChecks">
        <sch:rule context="/kn:knowledgeDocument/kn:actionGroup//*">
            <sch:assert test="not(@value) or not(starts-with(@value, ' '))">@value properties must not contain leading spaces.</sch:assert>
            <sch:assert test="not(@value) or not(ends-with(@value, ' '))">@value properties must not contain trailing spaces.</sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
