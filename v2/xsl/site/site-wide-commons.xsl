<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml">
<xsl:include href="../core/main.xsl"/>

<xsl:template match="h:script[@src='jquery-1.4.4/jquery-1.4.4.min.js']" mode="pageTemplate" priority="1">
	<xsl:variable name="coreModuleFromPagePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">coreModuleFromPagePath</xsl:with-param></xsl:call-template></xsl:variable>
    <script type="text/javascript" src="{$coreModuleFromPagePath}jquery-1.4.4/jquery-1.4.4.min.js"></script>
</xsl:template>

<xsl:template match="h:div[contains(@class, 'asyncJs')]" mode="pageTemplate">
<script type="text/javascript"><![CDATA[
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-3393582-3']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
  })();
]]></script>
</xsl:template>

<xsl:template match="h:link[@href='feed.xml']" mode="pageTemplate">
	<link href="/v2/atom.xml" type="application/atom+xml" rel="alternate" title="This site's ATOM feed"/>
</xsl:template>

<xsl:template match="h:img[@class='headerLogoImage']" mode="pageTemplate">
	<a>
		<xsl:attribute name="href"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template>index.xml</xsl:attribute>
		<img><xsl:attribute name="src"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template>logo.jpg</xsl:attribute></img>
	</a>
</xsl:template>

<xsl:template match="h:div[@id='logoText']/text()" mode="pageTemplate">
	<a>
		<xsl:attribute name="href"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template>index.xml</xsl:attribute>
		calavera.info
	</a>
</xsl:template>

<xsl:template match="h:ul[@id='mainMenu']" mode="pageTemplate">
	<xsl:variable name="rootFromSiteModulePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">rootFromSiteModulePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:apply-templates select="document(concat($rootFromSiteModulePath, 'index.xml'))/h:html/h:body/h:ul[@class='mainMenu']" mode="menu">
		<xsl:with-param name="linkBaseFromPage"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template></xsl:with-param>
		<xsl:with-param name="selectedMenuItemId"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">mainMenuSelected</xsl:with-param></xsl:call-template></xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="h:ul[@id='sideMenu']" mode="pageTemplate">
	<xsl:variable name="rootFromSiteModulePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">rootFromSiteModulePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:apply-templates select="document(concat($rootFromSiteModulePath, 'index.xml'))/h:html/h:body/h:ul[@class='sideMenu']" mode="menu">
		<xsl:with-param name="linkBaseFromPage"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template></xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="h:ul[@id='sideMenu2']" mode="pageTemplate">
	<xsl:variable name="rootFromSiteModulePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">rootFromSiteModulePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:apply-templates select="document(concat($rootFromSiteModulePath, 'index.xml'))/h:html/h:body/h:ul[@class='sideMenu2']" mode="menu">
		<xsl:with-param name="linkBaseFromPage"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromPagePath</xsl:with-param></xsl:call-template></xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="h:div[@id='footer']/text()" mode="pageTemplate">
	© 2009 - 2012
	<a href="http://mailhide.recaptcha.net/d?k=017ubdyCuTIFY0uWuYzgB5Lg==&amp;c=tL3koSGLGVzgp1E0oW5wUo9V_v6mt7YmSrP22LLF28Q=">
		František Řezáč
	</a> | Design inspired by
    <a href="http://www.killsmedead.com/" title="Grrliz's blog">
    	Grrliz
    </a>
</xsl:template>

</xsl:stylesheet>