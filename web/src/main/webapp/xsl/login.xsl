<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exslt="http://exslt.org/common" xmlns:geonet="http://www.fao.org/geonetwork"
	exclude-result-prefixes="xsl exslt geonet">

	<xsl:include href="main.xsl"/>
	
	<xsl:template mode="css" match="/">
		<xsl:call-template name="geoCssHeader"/>
		<xsl:call-template name="ext-ux-css"/>
<!--        <link rel="stylesheet" type="text/css" href="{/root/gui/url}/geonetwork_map.css" /> -->
	</xsl:template>
	
	<!--
	additional scripts
	-->
	<xsl:template mode="script" match="/">
		<link rel="stylesheet" type="text/css" href="{/root/gui/url}/scripts/ext/resources/css/xtheme-gray.css"/>	
	</xsl:template>


	<xsl:variable name="lang" select="/root/gui/language"/>

	<xsl:template name="content">
		<!-- content -->
		<div id="content" >
			<xsl:call-template name="pageContent"/>
		</div>
		
	</xsl:template>
	
	
	<!--
	page content
	-->
	<xsl:template name="pageContent">

        <xsl:if test="/root/gui/error/heading">
            <font class="warning">
            <h1><xsl:copy-of select="/root/gui/strings/error"/></h1>
            <p><xsl:copy-of select="/root/gui/error/heading"/></p>
            </font>
        </xsl:if>

		<h1>Login</h1>

            <form name="login" action="{/root/gui/locService}/user.login" method="post">
                <input type="submit" style="display: none;" />
                <xsl:value-of select="/root/gui/strings/username"/>
                <input class="banner" type="text" id="username" name="username" size="10" onkeypress="return entSub('login')"/>
                <xsl:value-of select="/root/gui/strings/password"/>
                <input class="banner" type="password" id="password" name="password" size="10" onkeypress="return entSub('login')"/>
                <button class="banner" onclick="document.forms['login'].onsubmit();"><xsl:value-of select="/root/gui/strings/login"/></button>
            </form>

	</xsl:template>

</xsl:stylesheet>
