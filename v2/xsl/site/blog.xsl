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

<div id="disqus_thread"></div>
<script>
    /**
     *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
     *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables
     */
    
    var disqus_config = function () {
        // this.page.url = '{{ page.url | replace:'index.html','' | prepend: site.baseurl | prepend: site.url }}';  // Replace PAGE_URL with your page's canonical URL variable
        //this.page.identifier = '{{ page.url | replace:'index.html','' }}'; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };
    
    (function() {  // DON'T EDIT BELOW THIS LINE
        var d = document, s = d.createElement('script');
        
        s.src = '//calaverainfo.disqus.com/embed.js';
        
        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript" rel="nofollow">comments powered by Disqus.</a></noscript>
</xsl:template>

</xsl:stylesheet>