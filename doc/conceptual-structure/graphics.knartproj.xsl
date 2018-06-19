<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:docb="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:stext="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.TextFactory" xmlns:xtext="com.nwalsh.xalan.Text" xmlns:lxslt="http://xml.apache.org/xslt"
    xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" exclude-result-prefixes="xlink stext xtext lxslt"
    extension-element-prefixes="stext xtext" version="1.0">

    <xsl:template match="mediaobject | mediaobjectco">

        <xsl:variable name="olist"
            select="
                imageobject | imageobjectco
                | videoobject | audioobject
                | textobject"/>

        <xsl:variable name="object.index">
            <xsl:call-template name="select.mediaobject.index">
                <xsl:with-param name="olist" select="$olist"/>
                <xsl:with-param name="count" select="1"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="object" select="$olist[position() = $object.index]"/>

        <xsl:variable name="align">
            <xsl:value-of select="$object/descendant::imagedata[@align][1]/@align"/>
        </xsl:variable>

        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>

        <fo:block id="{$id}">
            <xsl:if test="$align != ''">
                <xsl:attribute name="text-align">
                    <xsl:value-of select="$align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="docb:alt">
                <fox:alt-text>
                    <xsl:value-of select="docb:alt"/>
                </fox:alt-text>
            </xsl:if>
            <xsl:apply-templates select="$object"/>
            <xsl:apply-templates select="caption"/>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>
