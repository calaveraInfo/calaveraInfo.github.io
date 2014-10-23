<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml">
	<xsl:output
		method="html"
		media-type="text/html"
		encoding="UTF-8"
		version="1.0"
		indent="yes"
		omit-xml-declaration="no"/>

<xsl:variable name="mainDocument" select="h:html"/>
<xsl:variable name="properties" select="document('properties.xml')/properties"/>

<xsl:template name="getTemplateFile">template.xml</xsl:template>
<xsl:template name="getPropertiesFiles">properties.xml</xsl:template>

<xsl:template match="/">
	<xsl:variable name="templateFile"><xsl:call-template name="getTemplateFile"/></xsl:variable>
	<!-- result of call-template template MUST be "stringified" because of the bug in IE (Error message "-2146697210") -->
	<xsl:apply-templates select="document(string($templateFile))/h:html" mode="pageTemplate"></xsl:apply-templates>
</xsl:template>

<xsl:template match="@*|node()" mode="pageTemplate">
	<xsl:if test="not(contains(@class, 'optional')) and not(contains(@title, '(optional)'))">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="pageTemplate"></xsl:apply-templates>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="h:html" mode="pageTemplate">
	<html xml:lang="{$mainDocument/@xml:lang}" lang="{$mainDocument/@xml:lang}">
		<xsl:apply-templates select="@*|node()" mode="pageTemplate"/>
	</html>
</xsl:template>

<xsl:template match="h:link[@href='style.css']" mode="pageTemplate">
	<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">coreModuleFromPagePath</xsl:with-param></xsl:call-template>style.css</xsl:attribute></link>
</xsl:template>

<xsl:template match="h:meta[@name='include' and @content='pageHeaders']" mode="pageTemplate">
	<xsl:apply-templates select="$mainDocument/h:head/*" mode="pageHeaders"></xsl:apply-templates>
</xsl:template>

<xsl:template match="h:title" mode="pageTemplate">
	<title><xsl:apply-templates select="$mainDocument" mode="title"></xsl:apply-templates></title>
</xsl:template>

<xsl:template match="h:script[@src='jquery-1.4.4/jquery-1.4.4.min.js']" mode="pageTemplate">
	<!-- Do nothing. This will allow inclusion of jQuery only to pages that needs it. -->
</xsl:template>

<xsl:template match="h:div[@class='mainDocument']" mode="pageTemplate">
	<xsl:apply-templates select="$mainDocument" mode="mainDocument"></xsl:apply-templates>
</xsl:template>

<xsl:template match="node()" mode="pageHeaders">
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="h:title" mode="pageHeaders">
	<!-- do nothing -->
</xsl:template>

<xsl:template match="h:meta[@name='include' and @content='plugins']" mode="pageTemplate">
    <xsl:apply-templates select="$mainDocument" mode="pluginsHeader"></xsl:apply-templates>
</xsl:template>

<xsl:template match="h:ul[@class='imgList']" mode="pluginsHeader">
    <xsl:variable name="coreModuleFromPagePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">coreModuleFromPagePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:if test="not(preceding::h:ul[@class='imgList'])">
        <script type="text/javascript" src="{$coreModuleFromPagePath}jquery.fancybox-1.3.4/fancybox/jquery.mousewheel-3.0.4.pack.js"></script>
        <script type="text/javascript" src="{$coreModuleFromPagePath}jquery.fancybox-1.3.4/fancybox/jquery.fancybox-1.3.4.pack.js"></script>
        <link rel="stylesheet" type="text/css" href="{$coreModuleFromPagePath}jquery.fancybox-1.3.4/fancybox/jquery.fancybox-1.3.4.css" media="screen" />
		<script type="text/javascript">
		    $(document).ready(function() {
		        $("a.gallery").fancybox({});
		    });
		</script>
    </xsl:if>
</xsl:template>

<xsl:template match="@*|node()" mode="pluginsHeader">
	<xsl:apply-templates select="@*|node()" mode="pluginsHeader"></xsl:apply-templates>
</xsl:template>

<xsl:template match="h:pre[contains(@class, 'brush:')]" mode="pluginsHeader">	
    <xsl:variable name="syntaxHighlighterFromPagePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">syntaxHighlighterFromPagePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:if test="not(preceding::h:pre[contains(@class, 'brush:')])">
		<script type="text/javascript" src="{$syntaxHighlighterFromPagePath}scripts/shCore.js">;</script>
	    <link type="text/css" rel="stylesheet" href="{$syntaxHighlighterFromPagePath}styles/shCore.css"/>
	    <link type="text/css" rel="stylesheet" href="{$syntaxHighlighterFromPagePath}styles/shThemeDefault.css"/>
	    <script type="text/javascript">
	        SyntaxHighlighter.config.clipboardSwf = '<xsl:value-of select="$syntaxHighlighterFromPagePath"/>scripts/clipboard.swf';
	        SyntaxHighlighter.all();
	    </script>
	</xsl:if>
	
	<xsl:variable name="brush" select="normalize-space(substring-after(@class, 'brush:'))"/>
	
	<xsl:variable name="brushFile">
		<xsl:call-template name="brushFile">
			<xsl:with-param name="brush" select="$brush"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:if test="not(preceding::h:pre[contains(@class, 'brush:') and contains(@class, $brush)])">
	    <script type="text/javascript" src="{concat($syntaxHighlighterFromPagePath, 'scripts/', $brushFile)}">;</script>
	</xsl:if>
</xsl:template>
	
<xsl:template name="brushFile">
	<xsl:param name="brush"/>
	<xsl:variable name="prefix">shBrush</xsl:variable>
	<xsl:variable name="postfix">.js</xsl:variable>
	<xsl:choose>
		<xsl:when test="$brush = 'xml'"><xsl:value-of select="concat($prefix, 'Xml', $postfix)"/></xsl:when>
		<xsl:when test="$brush = 'javascript'"><xsl:value-of select="concat($prefix, 'JScript', $postfix)"/></xsl:when>
		<xsl:when test="$brush = 'java'"><xsl:value-of select="concat($prefix, 'Java', $postfix)"/></xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="@*|node()" mode="mainDocument">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="mainDocument"></xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template match="h:html" mode="mainDocument">
	<xsl:param name="linkBase">./</xsl:param>
	<div class="contentSection">
		<xsl:apply-templates select="." mode="documentBody">
			<xsl:with-param name="linkBase" select="$linkBase"/>
		</xsl:apply-templates>
	</div>
</xsl:template>

<xsl:template match="h:html" mode="documentBody">
	<xsl:param name="linkBase">./</xsl:param>
	<xsl:apply-templates select="h:body/node()" mode="mainDocumentContent">
		<xsl:with-param name="linkBase" select="$linkBase"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="h:html" mode="title">
	<xsl:apply-templates select="h:head/h:title/text()" mode="mainDocumentContent"></xsl:apply-templates>
</xsl:template>

<xsl:template match="h:html" mode="lastUpdated">
	&#160;
</xsl:template>

<xsl:template match="h:html" mode="titleImage">
	&#160;
</xsl:template>

<xsl:template match="h:html" mode="perex">
	Page <xsl:apply-templates select="." mode="title"/>
</xsl:template>

<xsl:template match="h:html" mode="pageInfoBox">
	<xsl:param name="anchor" select="false()"/>
	<div class="articleInfoBox">
		<div class="listItemHeader">
			<div class="listItemDate">
				<xsl:apply-templates select="." mode="lastUpdated"/>
			</div>
			<div class="listItemTitle">
				<h3>
					<xsl:choose>
						<xsl:when test="$anchor">
							<a href="{$anchor}">
								<xsl:apply-templates select="." mode="title"/>&#160;
							</a>
						</xsl:when>
						<xsl:otherwise>
								<xsl:apply-templates select="." mode="title"/>
						</xsl:otherwise>
					</xsl:choose>
				</h3>
			</div>
		</div>
		<div class="listItemBody">
			<div class="listItemActions">
				<xsl:variable name="titleImage">
					<xsl:apply-templates select="." mode="titleImage">
						<xsl:with-param name="linkBase"><xsl:call-template name="getDirFromPath"><xsl:with-param name="path" select="$anchor"/></xsl:call-template></xsl:with-param>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$anchor and $titleImage">
						<a href="{$anchor}">
							<xsl:copy-of select="$titleImage" />&#160;
						</a>
					</xsl:when>
					<xsl:when test="$titleImage">
						<xsl:copy-of select="$titleImage" />
					</xsl:when>
				</xsl:choose>
<xsl:apply-templates select="$mainDocument" mode="likes"/>
			</div>
			<div class="listItemContent">
				<xsl:apply-templates select="." mode="perex"></xsl:apply-templates>
			</div>
		</div>
	</div>
</xsl:template>

<xsl:template match="*" mode="likes"><!-- do nothing --></xsl:template>

<xsl:template match="h:html[@class='borderlessPage']" mode="mainDocument">
	<xsl:param name="linkBase">./</xsl:param>
	<xsl:apply-templates select="." mode="documentBody">
		<xsl:with-param name="linkBase" select="$linkBase"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="h:html[@class='article']" mode="mainDocument">
	<div class="contentSection">
		<xsl:apply-templates select="." mode="documentBody"></xsl:apply-templates>
	</div>
</xsl:template>

<xsl:template match="h:html" mode="afterMainDocument" priority="-2">
	<!-- do nothing -->
</xsl:template>

<xsl:template match="h:html[@class='article' or @class='page' or @class='borderlessPage']" mode="title">
	<xsl:value-of select="h:body/h:h1[@class='title']/text()"/>
</xsl:template>

<xsl:template match="h:html[@class='article']" mode="titleImage">
	<xsl:param name="linkBase">./</xsl:param>
	<xsl:if test="h:body/h:div[@class='titleImage']">
		<img src="{$linkBase}{h:body/h:div[@class='titleImage']/h:img/@src}"/>
	</xsl:if>
</xsl:template>

<xsl:template match="h:html[@class='article']" mode="lastUpdated">
	<xsl:apply-templates select="h:body/h:dl[string(h:dt) = 'Last update']/h:dd/child::text()" mode="date"/>
</xsl:template>

<xsl:template match="h:html[@class='article']" mode="perex">
	<xsl:apply-templates select="h:body/h:div[contains(@class, 'perex')]/node()" mode="mainDocumentContent"></xsl:apply-templates>
</xsl:template>

<xsl:template match="h:html[@class='article' or @class='page' or @class='borderlessPage']" mode="documentBody">
	<xsl:apply-templates select="h:body/h:div[contains(@class, 'content')]/node()" mode="mainDocumentContent">
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="eraseLeadingZeros">
	<xsl:param name="number"/>
	<xsl:choose>
	      <xsl:when test="starts-with($number, '0')">
	      	<xsl:call-template name="eraseLeadingZeros">
	      		<xsl:with-param name="number" select="substring($number, 2)"></xsl:with-param>
	      	</xsl:call-template>
	      </xsl:when>
	      <xsl:otherwise>
		      <xsl:value-of select="$number"/>
	      </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" mode="date">
      	<xsl:call-template name="eraseLeadingZeros">
      		<xsl:with-param name="number" select="substring(., 7, 2)"/>
      	</xsl:call-template>.
      	<xsl:call-template name="eraseLeadingZeros">
      		<xsl:with-param name="number" select="substring(., 5, 2)"/>
      	</xsl:call-template>.
		
		<xsl:value-of select="substring(., 1, 4)"/><xsl:text> </xsl:text>
		
		<xsl:if test="substring(., 9, 4)!='0000'">
	      	<xsl:call-template name="eraseLeadingZeros">
	      		<xsl:with-param name="number" select="substring(., 9, 2)"/>
	      	</xsl:call-template>:<xsl:value-of select="substring(., 11, 2)"/>
		</xsl:if>
</xsl:template>

<xsl:template match="@*|node()" mode="mainDocumentContent">
	<xsl:param name="linkBase">./</xsl:param>
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="mainDocumentContent">
			<xsl:with-param name="linkBase" select="$linkBase"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template  match="h:ul[@class='articlesList']" mode="mainDocumentContent">
	<xsl:param name="linkBase">./</xsl:param>
	<ol class="contentItemList">
		<xsl:apply-templates mode="articleListItem">
			<xsl:with-param name="linkBase" select="$linkBase"/>
		</xsl:apply-templates>
	</ol>
</xsl:template>

<xsl:template  match="h:li" mode="articleListItem">
	<xsl:param name="linkBase">./</xsl:param>
	<xsl:variable name="contextFromCoreModulePath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">contextFromCoreModulePath</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:variable name="pageDirFromContextPath"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">pageDirFromContextPath</xsl:with-param></xsl:call-template></xsl:variable>
	<li>
		<xsl:apply-templates select="document(concat($contextFromCoreModulePath, $pageDirFromContextPath, $linkBase, h:a/@href))/h:html" mode="pageInfoBox">
			<xsl:with-param name="anchor" select="concat($linkBase, h:a/@href)"/>
		</xsl:apply-templates>
	</li>
</xsl:template>

<xsl:template  match="h:ul[@class='imgList']" mode="mainDocumentContent">
    <xsl:variable name="imagesPerRow"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">galleryImagesPerRow</xsl:with-param></xsl:call-template></xsl:variable>
    <table class="galleryTable">
        <xsl:apply-templates mode="galleryRow" select="h:li[position() mod $imagesPerRow = 1]">
            <xsl:with-param name="imagesPerRow" select="$imagesPerRow"/>
        </xsl:apply-templates>
    </table>
</xsl:template>

<xsl:template match="h:li" mode="galleryRow">
    <xsl:param name="imagesPerRow"/>
	<tr>
        <xsl:apply-templates mode="galleryRowLoop" select=".">
            <xsl:with-param name="loop" select="$imagesPerRow"/>
        </xsl:apply-templates>
    </tr>
</xsl:template>

<xsl:template match="h:li" mode="galleryRowLoop">
    <xsl:param name="loop"/>
    <xsl:param name="i">0</xsl:param>
    <xsl:if test="$i &lt; $loop">
        <xsl:apply-templates mode="galleryItem" select=".">
            <xsl:with-param name="rowOrder" select="$i+1"/>
        </xsl:apply-templates>
        <xsl:apply-templates mode="galleryRowLoop" select=".">
            <xsl:with-param name="i" select="$i+1"/>
            <xsl:with-param name="loop" select="$loop"/>
        </xsl:apply-templates>
    </xsl:if>
</xsl:template>

<xsl:template match="h:li" mode="galleryItem">
    <xsl:param name="rowOrder"/>
    <xsl:variable name="listItem" select="(.|following-sibling::*)[position() = $rowOrder]"/>
	<td>
        <xsl:choose>
            <xsl:when test="$listItem">
                <a href="{$listItem/h:a/attribute::href}" rel="gallery-image" class="gallery">
                    <img src="thumbnails/{$listItem/h:a/attribute::href}" alt="Image {$listItem/h:a/attribute::href}" />
                </a>
            </xsl:when>
            <xsl:otherwise>
                &#160;
            </xsl:otherwise>
        </xsl:choose>
    </td>
</xsl:template>

<xsl:template match="h:ul" mode="menu">
	<xsl:param name="linkBaseFromPage"/>
	<xsl:param name="selectedMenuItemId"/>
	<ul>
		<xsl:apply-templates mode="menu">
			<xsl:with-param name="linkBaseFromPage" select="$linkBaseFromPage"/>
			<xsl:with-param name="selectedMenuItemId" select="$selectedMenuItemId"/>
		</xsl:apply-templates>
	</ul>
</xsl:template>

<xsl:template match="h:li" mode="menu">
	<xsl:param name="linkBaseFromPage"/>
	<xsl:param name="selectedMenuItemId"/>
	<li>
		<xsl:if test="$selectedMenuItemId=h:a/@id">
			<xsl:attribute name="class">selected</xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="starts-with(h:a/@href, 'http://')">
				<a href="{h:a/@href}"><xsl:value-of select="h:a/node()"/></a>
			</xsl:when>
			<xsl:otherwise>
				<a href="{concat($linkBaseFromPage, h:a/@href)}"><xsl:value-of select="h:a/node()"/></a>
			</xsl:otherwise>
		</xsl:choose>
	</li>
</xsl:template>

<xsl:template match="h:h1[ancestor-or-self::*[contains(@class, 'toc')]]|h:h2[ancestor-or-self::*[contains(@class, 'toc')]]|h:h3[ancestor-or-self::*[contains(@class, 'toc')]]|h:h4[ancestor-or-self::*[contains(@class, 'toc')]]|h:h5[ancestor-or-self::*[contains(@class, 'toc')]]|h:h6[ancestor-or-self::*[contains(@class, 'toc')]]" mode="mainDocumentContent">
	<xsl:variable name="tocNumber"><xsl:apply-templates select="." mode="tocNumber"/></xsl:variable>
	<xsl:element name="{name(.)}">
		<xsl:attribute name="id"><xsl:value-of select="concat('h', $tocNumber)"/></xsl:attribute>
		<xsl:variable name="showTocNumbers"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">showTocNumbers</xsl:with-param></xsl:call-template></xsl:variable>
		<xsl:if test="$showTocNumbers = 'true'"><xsl:value-of select="$tocNumber"/>&#160;</xsl:if>
		<xsl:apply-templates mode="mainDocument"/>
	</xsl:element>
</xsl:template>

<xsl:template match="h:div[contains(@class, 'tocPlaceholder')]" mode="pageTemplate">
	<xsl:variable name="showToc"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">showToc</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:if test="$showToc = 'true'">
		<xsl:variable name="mainHeadingLevel" select="substring(name(($mainDocument//*[starts-with(local-name(), 'h') and (string(number(substring(local-name(), 2))) != 'NaN')][ancestor-or-self::*[contains(@class, 'toc')]])[1]), 2)"/>
		<div class="tocPlaceholder">
			<h4>Obsah</h4>
			<ul>
				<xsl:apply-templates select="($mainDocument//*[local-name() = concat('h', $mainHeadingLevel)][ancestor-or-self::*[contains(@class, 'toc')]])" mode="printToc">
					<xsl:with-param name="currentLevel" select="$mainHeadingLevel"/>
				</xsl:apply-templates>
			</ul>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template mode="tocNumber" match="*">
    <xsl:variable name="currentHeadingNumber" select="number(substring(local-name(), 2))"/>
    <xsl:variable name="previousLevelNumber" select="number(substring(local-name(preceding::*[number(substring(local-name(), 2)) &lt; $currentHeadingNumber][ancestor-or-self::*[contains(@class, 'toc')]][1]), 2))"/>
    <xsl:apply-templates mode="tocNumber" select="preceding::*[number(substring(local-name(), 2)) = $previousLevelNumber][1]"/>
    <xsl:value-of select="count(preceding::*[number(substring(local-name(), 2)) = $currentHeadingNumber]) - count(preceding::*[number(substring(local-name(), 2)) = $previousLevelNumber][1]/preceding::*[number(substring(local-name(), 2)) = $currentHeadingNumber]) + 1"/><xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="*" mode="printToc">
	<xsl:variable name="currentHeadingNumber" select="number(substring(local-name(), 2))"/>
	<xsl:variable name="nextHeadingNumber" select="number(substring(name(following::*[string(number(substring(local-name(), 2))) != 'NaN'][1]), 2))"/>
	<xsl:variable name="showTocNumbers"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">showTocNumbers</xsl:with-param></xsl:call-template></xsl:variable>
    <xsl:variable name="tocNumber"><xsl:apply-templates select="." mode="tocNumber"/></xsl:variable>

	<li>
    	<a href="#h{$tocNumber}">
            <xsl:if test="$showTocNumbers = 'true'"><xsl:value-of select="$tocNumber"/>&#160;</xsl:if>
        	<xsl:value-of select="."/>
        </a>
		<xsl:if test="$nextHeadingNumber &gt; $currentHeadingNumber">
			<ul>
    			<xsl:variable name="nextLevelCount" select="count(following::*[local-name() = concat('h', $currentHeadingNumber)][1]/preceding::*[local-name() = concat('h', $nextHeadingNumber)]) - count(preceding::*[local-name() = concat('h', $nextHeadingNumber)])"/>
				<xsl:apply-templates mode="printToc" select="following::*[local-name() = concat('h', $nextHeadingNumber)][(position() &lt; ($nextLevelCount + 1)) or ($nextLevelCount &lt; 1)]"/>
			</ul>
    	</xsl:if>
	</li>
</xsl:template>

<xsl:template name="getProperty">
	<xsl:param name="propertyKey"/>
	<!-- result of call-template template MUST be "stringified" because of the bug in IE (Error message "-2146697210") -->
	<xsl:param name="propertiesFilesListNode"><xsl:call-template name="getPropertiesFiles"/></xsl:param>
	<xsl:param name="propertiesFilesList" select="string($propertiesFilesListNode)"></xsl:param>
	<xsl:choose>
		<xsl:when test="contains($propertiesFilesList, ',')">
			<xsl:variable name="propertyValue">
				<xsl:call-template name="getProperty">
					<xsl:with-param name="propertyKey" select="$propertyKey"/>
					<xsl:with-param name="propertiesFilesList" select="substring-before($propertiesFilesList, ',')"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="normalize-space($propertyValue)">
					<xsl:value-of select="$propertyValue"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getProperty">
						<xsl:with-param name="propertyKey" select="$propertyKey"/>
						<xsl:with-param name="propertiesFilesList" select="substring-after($propertiesFilesList, ',')"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="document($propertiesFilesList)//*[@id=$propertyKey]" mode="property"></xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="parsePropertyString">
	<xsl:param name="propertyString"/>
	<xsl:choose>
		<xsl:when test="contains($propertyString, '{$')">
			<xsl:call-template name="parsePropertyString">
				<xsl:with-param name="propertyString">
					<xsl:value-of select="substring-before($propertyString, '{$')" />
					<xsl:call-template name="getProperty">
						<xsl:with-param name="propertyKey"
							select="substring-after(substring-before($propertyString, '}'), '{$')" />
					</xsl:call-template>
					<xsl:value-of select="substring-after($propertyString, '}')" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$propertyString" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[@id='rootFromPagePath']" mode="property">
	<xsl:variable name="rootFromPageDelimiter"><xsl:call-template name="getProperty"><xsl:with-param name="propertyKey">rootFromPageDelimiter</xsl:with-param></xsl:call-template></xsl:variable>
	<xsl:value-of select="substring-before(substring-before(substring-after($mainDocument/../processing-instruction('xml-stylesheet'), 'href=&quot;'), '&quot;'), $rootFromPageDelimiter)"/>
</xsl:template>

<xsl:template match="*[@id='pageDirFromContextPath']" mode="property">
	<xsl:value-of select="$mainDocument/h:head/h:meta[@name='pageDirFromContextPath']/@content"/>
</xsl:template>

<xsl:template match="*" mode="property">
    <xsl:variable name="propertyKey" select="@id"/>
    <xsl:choose>
        <xsl:when test="$mainDocument/h:head/h:meta[@name=$propertyKey]">
            <xsl:value-of select="$mainDocument/h:head/h:meta[@name=$propertyKey]/@content"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
        	<xsl:apply-templates mode="properties"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="node()" mode="properties">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="properties"></xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template match="text()" mode="properties">
	<xsl:call-template name="parsePropertyString">
		<xsl:with-param name="propertyString">
			<xsl:value-of select="." />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="@*" mode="properties">
	<xsl:attribute name="{name()}">
        <xsl:call-template name="parsePropertyString">
            <xsl:with-param name="propertyString">
                <xsl:value-of select="." />
            </xsl:with-param>
        </xsl:call-template>
    </xsl:attribute>
</xsl:template>

<xsl:template name="getDirFromPath">
	<xsl:param name="path"/>
	<xsl:if test="contains($path, '/')">
		<xsl:value-of select="concat(substring-before($path, '/'), '/')"/>
		<xsl:call-template name="getDirFromPath">
			<xsl:with-param name="path" select="substring-after($path, '/')"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>
</xsl:stylesheet>