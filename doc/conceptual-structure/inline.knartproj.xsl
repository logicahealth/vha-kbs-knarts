<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xlink" version="1.0">
  <!-- Output Orgname -->
  <xsl:template match="honorific | firstname | surname | lineage | othername | orgname">
    <xsl:call-template name="inline.charseq"/>
  </xsl:template>
</xsl:stylesheet>
