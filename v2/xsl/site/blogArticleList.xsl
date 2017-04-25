<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml">
<xsl:include href="site-wide-commons.xsl"/>

<xsl:template match="h:ul[@id='sideMenu3']" mode="pageTemplate">
	<xsl:variable name="rootFromSiteModulePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">rootFromSiteModulePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:apply-templates select="document(concat($rootFromSiteModulePath, 'index.xml'))/h:html/h:body/h:ul[@class='blogMenu']" mode="menu">
		<xsl:with-param name="linkBaseFromPage"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template></xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="h:div[@id='sideMenu4']" mode="pageTemplate">
	<a class="twitter-timeline" href="https://twitter.com/calaverainfo">Moje tvíty</a>
        <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
</xsl:template>
</xsl:stylesheet>
