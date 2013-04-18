<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:geonet="http://www.fao.org/geonetwork" 
	xmlns:exslt="http://exslt.org/common"
	xmlns:dc = "http://purl.org/dc/elements/1.1/" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gco="http://www.isotc211.org/2005/gco"
	exclude-result-prefixes="gco gmd dc exslt geonet">

	<!--
	show metadata form
	-->
	
	<xsl:include href="main.xsl"/>
	<xsl:include href="metadata.xsl"/>

    <xsl:variable name="protocol" select="/root/gui/env/server/protocol" />
	<xsl:variable name="host" select="/root/gui/env/server/host" />
	<xsl:variable name="port" select="/root/gui/env/server/port" />
	<xsl:variable name="baseURL" select="concat($protocol,'://',$host,':',$port,/root/gui/url)" />
	<xsl:variable name="serverUrl" select="concat($protocol,'://',$host,':',$port,/root/gui/locService)" />
	
	<xsl:template match="/">
		<table width="100%" height="100%">
			
			<!-- content -->
			<tr height="100%"><td>
				<xsl:call-template name="content"/>
			</td></tr>
		</table>
	</xsl:template>
		
	<!-- CSI: New Template added for CSI in order to manage 'downlaod button' and 'interactive map button' on the metedata.show section -->
	<xsl:template name="urlsButtonTemplate">
		<xsl:param name="metadata"/>
		<xsl:variable name="remote" select="/root/response/summary/@type='remote'"/>
		
		<div class="buttonsleft">			
			<!-- download data button -->
			<xsl:if test="$metadata/geonet:info/download='true'">
				&#160;
				<xsl:choose>
					<xsl:when test="count($metadata/link[@type='download'])>1">
						<xsl:choose>
							<xsl:when test="$remote=true()">
								<button class="content" onclick="window.open('{/root/gui/locService}/remote.show?id={$metadata/geonet:info[server]/id}&amp;currTab=distribution2')" title="{/root/gui/strings/download}">
									<xsl:value-of select="/root/gui/strings/download"/>
								</button>
							</xsl:when>
							<xsl:otherwise>
								<button class="content" onclick="window.open('{/root/gui/locService}/metadata.show?id={$metadata/geonet:info/id}&amp;currTab=distribution2')" title="{/root/gui/strings/download}">
									<xsl:value-of select="/root/gui/strings/download"/>
								</button>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="count($metadata/link[@type='download'])=1 and $metadata/link[@type='download'] != ''">
						<button class="content" onclick="window.open('{$metadata/link[@type='download']}')" title="{/root/gui/strings/download}">
							<xsl:value-of select="/root/gui/strings/download"/>
						</button>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			
			<!-- dynamic map button -->
			<xsl:if test="$metadata/geonet:info/dynamic='true'">
				&#160;
				<xsl:variable name="count" select="count($metadata/link[@type='arcims']) + count($metadata/link[@type='wms'])"/>
				<xsl:choose>
					<xsl:when test="$count>1">
						<xsl:choose>
							<xsl:when test="$remote=true()">
								<button class="content" onclick="load('{/root/gui/locService}/remote.show?id={$metadata/geonet:info[server]/id}&amp;currTab=distribution2')" title="{/root/gui/strings/interactiveMap}"><xsl:value-of select="/root/gui/strings/interactiveMap"/></button>
							</xsl:when>
							<xsl:otherwise>
								<button id="gn_showinterlist_{$metadata/geonet:info/id}"  class="content" onclick="window.open('{/root/gui/locService}/metadata.show?id={$metadata/geonet:info/id}&amp;currTab=distribution2')" title="{/root/gui/strings/interactiveMap}">
									<xsl:value-of select="/root/gui/strings/interactiveMap"/>
								</button>
								<button id="gn_loadinterlist_{$metadata/geonet:info/id}"  class="content" style="display:none;" title="{/root/gui/strings/interactiveMap}">
									<xsl:value-of select="/root/gui/strings/loading"/>
								</button>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$count=1">
						<button class="content" onclick="{$metadata/link[@type='arcims' or @type='wms']}" title="{/root/gui/strings/interactiveMap}">
							<xsl:value-of select="/root/gui/strings/interactiveMap"/>
						</button>
						
						<!-- View WMS in Google Earth map button -->
						<xsl:if test="$metadata/link[@type='googleearth']">
							&#160;
							<a onclick="load('{$metadata/link[@type='googleearth']}')" style="vertical-align: middle;cursor: pointer;">
								<img src="{/root/gui/url}/images/google_earth_link.gif" height="20px" width="20px" style="padding-left:3px;" alt="{/root/gui/strings/viewInGE}" title="{/root/gui/strings/viewInGE}"/>
							</a>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			
		</div>
	</xsl:template>	
	
		
	<!--
	page content
	-->
	<xsl:template name="content">
		<xsl:param name="schema">
			<xsl:apply-templates mode="schema" select="."/>
		</xsl:param>
		
		<table  width="100%" height="100%">
			<xsl:for-each select="/root/*[name(.)!='gui' and name(.)!='request']"> <!-- just one -->
				<tr height="100%">
					<td class="content" valign="top">
						
						<xsl:variable name="md">
							<xsl:apply-templates mode="brief" select="."/>
						</xsl:variable>
						<xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
						<xsl:variable name="mdURL" select="normalize-space(concat($baseURL, '?uuid=', geonet:info/uuid))"/>
						
						<!-- Add social bookmark icons here -->
						<xsl:call-template name="socialBookmarks">
							<xsl:with-param name="baseURL" select="$baseURL" /> <!-- The base URL of the local GeoNetwork site -->
							<xsl:with-param name="mdURL" select="$mdURL" /> <!-- The URL of the metadata using the UUID -->
							<xsl:with-param name="title" select="$metadata/title" />
							<xsl:with-param name="abstract" select="$metadata/abstract" />
						</xsl:call-template>
												
						<table width="100%">
							
							<xsl:if test="/root/request/control">
								<tr><td class="padded-content" height="100%" align="center" valign="top">
									<xsl:call-template name="urlsButtonTemplate">
										<xsl:with-param name="metadata" select="$metadata"/>
									</xsl:call-template>
									<xsl:call-template name="buttons">
										<xsl:with-param name="metadata" select="$metadata"/>
									</xsl:call-template>
								</td></tr>
							</xsl:if>
							
							<!-- subtemplate title button -->
							<xsl:if test="(string(geonet:info/isTemplate)='s')">
								<tr><td class="padded-content" height="100%" align="center" valign="top">
									<b><xsl:value-of select="geonet:info/title"/></b>
								</td></tr>
							</xsl:if>

							<tr>
								<td class="padded-content">
								<table class="md" width="100%">
										<xsl:choose>
											<xsl:when test="$currTab='xml'">
												<xsl:apply-templates mode="xmlDocument" select="."/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates mode="elementEP" select=".">
													<xsl:with-param name="embedded" select="true()" />
												</xsl:apply-templates>
											</xsl:otherwise>
										</xsl:choose>
								</table>
							</td></tr>
						</table>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	
</xsl:stylesheet>
