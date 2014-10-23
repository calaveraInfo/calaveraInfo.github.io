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
	<script charset="utf-8" src="http://widgets.twimg.com/j/2/widget.js"></script>
	<script type="text/javascript"><![CDATA[
	new TWTR.Widget({
	  version: 2,
	  type: 'profile',
	  rpp: 5,
	  interval: 30000,
	  width: 'auto',
	  height: 500,
	  theme: {
	    shell: {
	      background: '#ffffff',
	      color: '#555555'
	    },
	    tweets: {
	      background: '#ffffff',
	      color: '#555555',
	      links: '#000000'
	    }
	  },
	  features: {
	    scrollbar: false,
	    loop: false,
	    live: false,
	    behavior: 'all'
	  }
	}).render().setUser('calaverainfo').start();
	]]></script>
</xsl:template>
</xsl:stylesheet>