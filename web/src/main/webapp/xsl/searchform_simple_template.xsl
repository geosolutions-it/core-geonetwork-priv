<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:geonet="http://www.fao.org/geonetwork"
	exclude-result-prefixes="xsl geonet">


	<xsl:template name="geofields">
		
		<xsl:variable name="municipalitySearch">
			<xsl:value-of select="/root/gui/config/municipalitySearch/enabled"/>
		</xsl:variable>
		
		<div style="border-bottom: 1px solid">
		
			<!-- What --> 
			<div class="row">  <!-- div row-->
				<h1 class="labelFieldSmall"><xsl:value-of select="/root/gui/strings/what"/></h1>
				<input name="any" id="any" class="content" size="31" value="{/root/gui/searchDefaults/any}"/>
			</div>
		
			<!-- Where --> 
			<div class="row" style="margin-top:10px">
				<h1 class="labelFieldSmall"><xsl:value-of select="/root/gui/strings/where"/></h1>
			
				<!-- Search map container -->
				<div id="ol_minimap1" style="margin-left: 60px; margin-top:5px"></div>
						
				<xsl:comment>COORDS</xsl:comment>
				<!-- Share the hidden fields in advanced search map -->
				<!--input type="hidden" class="content" id="northBL" name="northBL"  size="7"
					value="{/root/gui/searchDefaults/northBL}"/>
				<input type="hidden" class="content" id="westBL" name="westBL" size="7"
					value="{/root/gui/searchDefaults/westBL}"/>
				<input type="hidden" class="content" id="eastBL" name="eastBL" size="7"
					value="{/root/gui/searchDefaults/eastBL}"/>
				<input type="hidden" class="content" id="southBL" name="southBL" size="7"
					value="{/root/gui/searchDefaults/southBL}"/>
				<input type="hidden" class="content" id="relation" name="relation" size="7"
					value="overlaps"/-->
							
				<div style="margin-top:5px">
					<!-- Region -->
					<span class="labelField">Ambito</span>
					<select class="content" name="region_simple" id="region_simple" onchange="javascript:doRegionSearchSimple();">
						<option value="">
							<xsl:if test="/root/gui/searchDefaults/theme='_any_'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="/root/gui/strings/any"/>
						</option>
						<option value="userdefined">
							<xsl:if test="/root/gui/searchDefaults/theme='_userdefined_'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="/root/gui/strings/userDefined"/>
						</option>

						<xsl:for-each select="/root/gui/regions/record">
<!--							<xsl:sort select="label/child::*[name() = $lang]" order="ascending"/>-->
							<xsl:sort select="label" order="ascending"/>
							<option>
								<xsl:if test="id=/root/gui/searchDefaults/region">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="value">
									<xsl:value-of select="id"/>
								</xsl:attribute>
<!--								<xsl:value-of select="label/child::*[name() = $lang]"/>-->
                                <xsl:value-of select="label"/>
							</option>
						</xsl:for-each>
					</select>			
				</div>
				
				<xsl:if test="$municipalitySearch = 'true'">
					<div style="margin-top:5px">
						<!-- Comuni -->						
					    <span class="labelField">Sottoambito</span>
						<select class="content" style="width: 163px;" name="comune_simple" id="comune_simple" onchange="javascript:comuneSimpleSelected();">
								<option value="">
									<xsl:if test="/root/gui/searchDefaults/theme='_any_'">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="/root/gui/strings/any"/>
								</option>
							</select>				
					</div>
				</xsl:if>
			</div>
			
			<!-- Search button -->
			<div>
				<table class="advsearchfields" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr style="vertical-align: middle;">
						<td style="background: url({/root/gui/url}/images/arrow-bg.png) repeat-x;" height="20px" width="50%">
						</td>
						<td style="padding:0px; margin:0px;" width="36px">
							<img width="36px" style="padding:0px; margin:0px;"  src="{/root/gui/url}/images/arrow-right.png" alt=""/>
						</td>
						<td style="padding:0px; margin:0px; text-align:right;" width="13px">
							<!--img width="5px" style="padding:0px; margin:0px;"  src="{/root/gui/url}/images/search-left.png" alt=""/-->
						</td>
						<!--td align="center" style="background: url({/root/gui/url}/images/search.png) repeat-x; width: auto; white-space: nowrap; padding-bottom: 0px; vertical-align: middle; cursor:hand;  cursor:pointer;" onclick="runSimpleSearch();" >
							<font color="#FFFFFF"><strong><xsl:value-of select="/root/gui/strings/search"/></strong></font-->
						<td align="center"><button class="banner" style="width: auto; white-space: nowrap; padding-bottom: 0px; vertical-align: middle; cursor:hand;  cursor:pointer;" onclick="runSimpleSearch();" ><xsl:value-of select="/root/gui/strings/search"/></button>
						</td>
						<td style="padding:0px; margin:0px; text-align:left;" width="12px">
							<!--img width="5px" style="padding:0px; margin:0px;"  src="{/root/gui/url}/images/search-right.png" alt=""/-->
						</td>
					</tr>
				</table>		
			</div>
			
			<!-- Links to Reset fields, Advanced Search and Options panel --> 
			<div style="padding-left:10px;padding-top:5px;" align="right">
				<a onClick="resetSimpleSearch();" style="cursor:pointer; padding-right:10px; padding-left:10px;">
					<xsl:value-of select="/root/gui/strings/reset"/>
				</a>
				<a onClick="showAdvancedSearch()" style="cursor:pointer;">
					<xsl:value-of select="/root/gui/strings/extended"/>
				</a>
			</div>
			
			<div style="padding-left:10px;padding-top:5px;" align="right">
				<a onClick="showFields('options.img','options.div')" style="cursor:pointer; padding-left:10px;">
					<img id="options.img" src="{/root/gui/url}/images/plus.gif" alt=""/>
					<xsl:value-of select="/root/gui/strings/options"/>
				</a>		
			</div>
				
					
			<!-- Options panel in simple search -->
			<div id="options.div" style="display:none; margin-top:5px; margin-bottom:5px"> 

				<!-- sort by - - - - - - - - - - - - - - - - - - - - -->			
				<div class="row">  <!-- div row-->
					<span class="labelField"><xsl:value-of select="/root/gui/strings/sortBy"/></span>
					<select id="sortBy_simple" size="1" class="content" 
						 onChange="$('sortBy').value = this.options[this.selectedIndex].value; if (this.options[this.selectedIndex].value=='title') $('sortOrder').value = 'reverse'; else $('sortOrder').value = ''">
						<xsl:for-each select="/root/gui/strings/sortByType">
							<option value="{@id}">
								<xsl:if test="@id = /root/gui/searchDefaults/sortBy">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</option>
						</xsl:for-each>
					</select>
					<!--input type="hidden" name="sortOrder" id="sortOrder"/--> <!-- Share the hidden field in advanced form -->
				</div>
			
				<!-- hits per page - - - - - - - - - - - - - - - - - - -->
				<div class="row">  <!-- div row-->
					<span class="labelField"><xsl:value-of select="/root/gui/strings/hitsPerPage"/></span>
						<select id="hitsPerPage_simple" size="1" class="content" onchange="$('hitsPerPage').value = this.options[this.selectedIndex].value">

						<xsl:for-each select="/root/gui/strings/hitsPerPageChoice">
							<option value="{@value}">
								<xsl:if test="@value = /root/gui/searchDefaults/hitsPerPage">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</option>
						</xsl:for-each>
					</select>
				</div>
				
				<!-- output - - - - - - - - - - - - - - - - - - - - - - -->
				<div class="row">  <!-- div row-->
					<span class="labelField"><xsl:value-of select="/root/gui/strings/output"/></span>
					<select id="output_simple" size="1" class="content" onchange="$('output').value = this.options[this.selectedIndex].value">
						<xsl:for-each select="/root/gui/strings/outputType">
							<option value="{@id}">
								<xsl:if test="@id = /root/gui/searchDefaults/output">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</option>
						</xsl:for-each>
					</select>
				</div>			
			</div>
		
		</div>
					
		<script language="JavaScript" type="text/javascript">
			Event.observe('any', 		'keypress',	gn_anyKeyObserver);
		</script>
	</xsl:template>

</xsl:stylesheet>
