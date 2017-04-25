<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml">

<xsl:template match="h:div[contains(@class, 'articleInfoBox')]" mode="pageTemplate">
	<xsl:apply-templates select="$mainDocument" mode="pageInfoBox"/>
</xsl:template>

<xsl:template match="*" mode="likes">
<!--
Add this js widget was removed
-->
</xsl:template>
</xsl:stylesheet>
