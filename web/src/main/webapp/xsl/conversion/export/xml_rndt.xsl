<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- This stylesheet converts ISO19115 and ISO19139 metadata into ISO19139 metadata in XML format -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:include href="../19115to19139/19115-to-19139.xsl"/>
	
	<xsl:template match="/root">
		<xsl:choose>
			<!-- Export ISO19115/19139 XML (just a copy)-->
			<xsl:when test="gmd:MD_Metadata">
				<xsl:apply-templates select="gmd:MD_Metadata"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@*|node()">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()[name(self::*)!='geonet:info']"/>
			</xsl:copy>
	</xsl:template>

    <xsl:template match="gmd:MD_ScopeCode[@codeList='']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ScopeCode</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:CI_RoleCode[@codeList='']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_RoleCode</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:LanguageCode[@codeList='']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#LanguageCode</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    


    <!-- remove empty MimeFileType:
        <gmd:onLine>
            <gmd:CI_OnlineResource>
                <gmd:linkage xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:srv="http://www.isotc211.org/2005/srv">
                    <gmd:URL>http://localhost:8080/geonetwork/srv/en/resources.get?id=13&amp;fname=&amp;access=private</gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                    <gco:CharacterString>WWW:DOWNLOAD-1.0-http- -download</gco:CharacterString>
                </gmd:protocol>
                <gmd:name xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:srv="http://www.isotc211.org/2005/srv">
                    <gmx:MimeFileType type=""/>
                </gmd:name>
                <gmd:description>
                    <gco:CharacterString/>
                </gmd:description>
            </gmd:CI_OnlineResource>
        </gmd:onLine>
    -->
	<xsl:template match="gmd:onLine/gmd:CI_OnlineResource[gmd:name/gmx:MimeFileType/@type='']">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()[name(self::*)!='geonet:info' and name(self::*)!='gmd:name']"/>
			</xsl:copy>
	</xsl:template>

    <xsl:template match="gmd:verticalCRS[@xlink:href='']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:attribute name="href">http://www.rndt.gov.it/ReferenceSystemCode#999</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- remove empty temporal extent

         <gmd:extent>
            <gmd:EX_Extent>
               <gmd:temporalElement>
                  <gmd:EX_TemporalExtent>
                     <gmd:extent>
                        <gml:TimePeriod gml:id="d52544e433a1050910">
                           <gml:beginPosition/>
                           <gml:endPosition/>
                        </gml:TimePeriod>
                     </gmd:extent>
                  </gmd:EX_TemporalExtent>
               </gmd:temporalElement>
            </gmd:EX_Extent>
         </gmd:extent> -->

<!--
gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition
         gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition/
         gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition/-->

    <xsl:template match="gmd:MD_DataIdentification/gmd:extent">
        <xsl:choose>
            <!-- both start and end position missing -->
            <xsl:when test="gmd:EX_Extent/gmd:temporalElement and not(string(gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition)) and not(string(gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition))">
            <!-- do nothing -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gml:beginPosition">
        <xsl:choose>
            <xsl:when test="string(.)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gml:endPosition">
        <xsl:choose>
            <xsl:when test="string(.)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>



</xsl:stylesheet>
