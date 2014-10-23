<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml">
<xsl:include href="site-wide-commons.xsl"/>
<xsl:include href="../core/article.xsl"/>

<xsl:template match="*[@id='mainMenuSelected']" mode="property">menuItemBlog</xsl:template>

<xsl:template match="h:div[contains(@class, 'mainDocumentFooter')]" mode="pageTemplate">
	<div class="js-kit-comments"></div>
	<script src="http://js-kit.com/for/calavera.info/comments.js"></script>
</xsl:template>

</xsl:stylesheet>