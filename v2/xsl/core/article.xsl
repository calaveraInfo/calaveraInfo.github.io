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
<div class="addthis_toolbox addthis_default_style addthis_32x32_style" style="margin-top: 8px;">
<a class="addthis_button_preferred_1"></a>
<a class="addthis_button_preferred_2"></a>
<a class="addthis_button_preferred_3"></a>
<a class="addthis_button_preferred_4"></a>
<a class="addthis_button_compact"></a>
</div>
<script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#pubid=xa-4d66bc966b13b080"></script>
</xsl:template>
</xsl:stylesheet>