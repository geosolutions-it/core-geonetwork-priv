<?xml version="1.0" encoding="UTF-8"?>
<!--  
Extract info for OpenCms integration
-->
<xsl:stylesheet version="2.0"
        xmlns:gmd="http://www.isotc211.org/2005/gmd"
        xmlns:gco="http://www.isotc211.org/2005/gco"
        xmlns:gts="http://www.isotc211.org/2005/gts"
        xmlns:gml="http://www.opengis.net/gml"
        xmlns:srv="http://www.isotc211.org/2005/srv"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:exslt="http://exslt.org/common"

        exclude-result-prefixes="gmd gco gts gml srv date xlink xsi exslt">

<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
<xsl:strip-space elements="*"/>
	
	<!-- ============================================================================= -->

    <!-- Recurse on every node -->
    <xsl:template match="@*|node()">
       <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

    <!-- Root element -->
	<xsl:template match="gmd:MD_Metadata">
        <metadata>
            <xsl:apply-templates select="@*|node()"/>

            <keywords>
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString">
                    <xsl:value-of select="normalize-space(.)"/><xsl:if test="not(position() = last())"> , </xsl:if>
                </xsl:for-each>
            </keywords>

            <xsl:call-template name="onlineResources"/>

        </metadata>

    </xsl:template>


	<xsl:template match="gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString">
        <uuid><xsl:value-of select="."/></uuid>
    </xsl:template>

	<xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString">
        <titolo><xsl:value-of select="normalize-space(.)"/></titolo>
    </xsl:template>


	<xsl:template match="gmd:MD_Metadata/gmd:dateStamp/gco:DateTime">
        <dataCreazioneMetadato>
            <xsl:value-of select="."/>
        </dataCreazioneMetadato>
    </xsl:template>

	<xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString">
        <descrizione>
            <xsl:value-of select="normalize-space(.)"/>
        </descrizione>
    </xsl:template>

	<xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date">
        <xsl:if test='gmd:dateType/gmd:CI_DateTypeCode[@codeListValue="creation"]'>
            <dataCreazioneDati>
                <xsl:value-of select="gmd:date/gco:DateTime"/>
            </dataCreazioneDati>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date">
        <xsl:if test='gmd:dateType/gmd:CI_DateTypeCode[@codeListValue="revision"]'>
            <dataUltimoAggiornamentoDati>
                <xsl:value-of select="gmd:date/gco:DateTime"/>
            </dataUltimoAggiornamentoDati>
        </xsl:if>
    </xsl:template>

	<xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
        <tipoSpaziale>
            <xsl:choose>
                <xsl:when test='@codeListValue="vector"'>Vettoriale</xsl:when>
                <xsl:when test='@codeListValue="grid"'>Raster</xsl:when>
                <xsl:otherwise><xsl:value-of select="normalize-space(@codeListValue)"/></xsl:otherwise>
            </xsl:choose>
        </tipoSpaziale>
    </xsl:template>

    <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode">
        <frequenzaAggiornamento>
            <xsl:choose>
                <xsl:when test='@codeListValue="continual"'>Continuo</xsl:when>
                <xsl:when test='@codeListValue="daily"'>Quotidiano</xsl:when>
                <xsl:when test='@codeListValue="weekly"'>Settimanale</xsl:when>
                <xsl:when test='@codeListValue="fortnightly"'>Ogni due settimane</xsl:when>
                <xsl:when test='@codeListValue="monthly"'>Mensile</xsl:when>
                <xsl:when test='@codeListValue="quarterly"'>Ogni tre mesi</xsl:when>
                <xsl:when test='@codeListValue="biannually"'>Due volte all'anno</xsl:when>
                <xsl:when test='@codeListValue="annually"'>Annuale</xsl:when>
                <xsl:when test='@codeListValue="asNeeded"'>Quando necessario</xsl:when>
                <xsl:when test='@codeListValue="irregular"'>Irregolare</xsl:when>
                <xsl:when test='@codeListValue="notPlanned"'>Non previsto</xsl:when>
                <xsl:when test='@codeListValue="unknown"'>Sconosciuto</xsl:when>
                <xsl:otherwise><xsl:value-of select="normalize-space(@codeListValue)"/></xsl:otherwise>
            </xsl:choose>
        </frequenzaAggiornamento>
    </xsl:template>


    <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
        <argomento>
            <xsl:choose>
                <xsl:when test='string()="farming"'>Agricoltura</xsl:when>
                <xsl:when test='string()="biota"'>Biota</xsl:when>
                <xsl:when test='string()="boundaries"'>Confini</xsl:when>
                <xsl:when test='string()="climatologyMeteorologyAtmosphere"'>Climatologia - Meteorologia - Atmosfera</xsl:when>
                <xsl:when test='string()="economy"'>Economia</xsl:when>
                <xsl:when test='string()="elevation"'>Elevazione</xsl:when>
                <xsl:when test='string()="environment"'>Ambiente</xsl:when>
                <xsl:when test='string()="geoscientificInformation"'>Informazioni geoscientifiche</xsl:when>
                <xsl:when test='string()="health"'>Salute</xsl:when>
                <xsl:when test='string()="imageryBaseMapsEarthCover"'>Mappe di base - Immagini - Copertura terrestre</xsl:when>
                <xsl:when test='string()="intelligenceMilitary"'>Intelligence - Settore militare</xsl:when>
                <xsl:when test='string()="inlandWaters"'>Acque interne</xsl:when>
                <xsl:when test='string()="location"'>Localizzazione</xsl:when>
                <xsl:when test='string()="oceans"'>Acque marine - Oceani</xsl:when>
                <xsl:when test='string()="planningCadastre"'>Pianificazione - Catasto</xsl:when>
                <xsl:when test='string()="society"'>Società</xsl:when>
                <xsl:when test='string()="structure"'>Strutture</xsl:when>
                <xsl:when test='string()="transportation"'>Trasporti</xsl:when>
                <xsl:when test='string()="utilitiesCommunication"'>Servizi di pubblica utilità - Comunicazione</xsl:when>
                <xsl:otherwise><xsl:value-of select="normalize-space(@codeListValue)"/></xsl:otherwise>
            </xsl:choose>
        </argomento>
    </xsl:template>

<!--        <gmd:contact>
                <gmd:CI_ResponsibleParty>
                        <gmd:individualName gco:nilReason="missing">
                                <gco:CharacterString/>
                        </gmd:individualName>
                        <gmd:organisationName>
                                <gco:CharacterString>Comune di Firenze</gco:CharacterString>
                        </gmd:organisationName>
                        <gmd:positionName>
                                <gco:CharacterString>Direzione Sistemi Informativi - P.O. Gestione Risorsa Dati</gco:CharacterString>-->
<!--gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName
gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString
gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:positionName
gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString-->

    <xsl:template match="gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty">
        <xsl:if test='gmd:organisationName/gco:CharacterString'>
<ente><xsl:value-of select="gmd:organisationName/gco:CharacterString"/><xsl:if test='gmd:positionName/gco:CharacterString'> (<xsl:value-of select="gmd:positionName/gco:CharacterString"/>)</xsl:if></ente>
        </xsl:if>
    </xsl:template>


    <!-- Online resources -->

    <xsl:template name="onlineResources">
        <xsl:for-each select="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
            <!-- $linkLast contiene gli ultimi 3 char dell'URL -->
            <xsl:variable name="linkLast" select="substring(gmd:linkage/gmd:URL, string-length(gmd:linkage/gmd:URL) - 3 +1)"/>
            <!-- un po' di euristica... -->
            <xsl:choose>
                <!--<xsl:when test='ends-with(gmd:linkage/gmd:URL,"kmz")'>-->
                <xsl:when test='$linkLast = "kmz" or $linkLast = "kml"'>
                    <kml>
                        <url><xsl:value-of select="gmd:linkage/gmd:URL"/></url>
                         <xsl:if test='gmd:name/gco:CharacterString'>
                             <name><xsl:value-of select="gmd:name/gco:CharacterString"/></name>
                         </xsl:if>
                    </kml>
                </xsl:when>
                <xsl:when test='contains(gmd:name/gco:CharacterString, "shape") or contains(gmd:linkage/gmd:URL, "shape") or contains(gmd:linkage/gmd:URL, "shp")'>
                    <shp>
                        <url><xsl:value-of select="gmd:linkage/gmd:URL"/></url>
                         <xsl:if test='gmd:name/gco:CharacterString'>
                             <name><xsl:value-of select="gmd:name/gco:CharacterString"/></name>
                         </xsl:if>
                    </shp>
                </xsl:when>
<!--<protocolChoice show="-" value="OGC:WMS">OGC-WMS Web Map Service</protocolChoice>
    <protocolChoice show="-" value="OGC:WMS-1.1.1-http-get-capabilities">OGC-WMS Capabilities service (ver 1.1.1)</protocolChoice>
    <protocolChoice show="-" value="OGC:WMS-1.3.0-http-get-capabilities">OGC-WMS Capabilities service (ver 1.3.0)</protocolChoice>
    <protocolChoice show="-" value="OGC:WMS-1.1.1-http-get-map">OGC Web Map Service (ver 1.1.1)</protocolChoice>
    <protocolChoice show="-" value="OGC:WMS-1.3.0-http-get-map">OGC Web Map Service (ver 1.3.0)</protocolChoice>         -->
<!--                                                <gmd:CI_OnlineResource>
                                                        <gmd:linkage>
                                                                <gmd:URL>http://tms.comune.fi.it/tiles/service/wms</gmd:URL>
                                                        </gmd:linkage>
                                                        <gmd:protocol>
                                                                <gco:CharacterString>OGC:WMS</gco:CharacterString>-->
                <xsl:when test='gmd:protocol/gco:CharacterString="OGC:WMS" or contains(gmd:protocol/gco:CharacterString, "http-get-map")'>
                    <wms>
                        <url><xsl:value-of select="gmd:linkage/gmd:URL"/></url>
                        <name><xsl:value-of select="gmd:name/gco:CharacterString"/></name>
                    </wms>
                </xsl:when>

<!--<protocolChoice show="-" value="OGC:WFS">OGC-WFS Web Feature Service</protocolChoice>
    <protocolChoice show="y" value="OGC:WFS-1.0.0-http-get-capabilities">OGC-WFS Web Feature Service (ver 1.0.0)</protocolChoice>
    <protocolChoice show="-" value="OGC:WFS-G">OGC-WFS-G Gazetteer Service</protocolChoice>                -->

                <xsl:when test='gmd:protocol/gco:CharacterString="OGC:WFS" or contains(gmd:protocol/gco:CharacterString, "OGC:WFS-1.0.0")'>
                    <wfs>
                        <url><xsl:value-of select="gmd:linkage/gmd:URL"/></url>
                        <name><xsl:value-of select="gmd:name/gco:CharacterString"/></name>
                    </wfs>
                </xsl:when>

                <xsl:otherwise>
                    <unknownResource>
                        <url>
                            <xsl:value-of select="gmd:linkage/gmd:URL"/>
                        </url>
                             <name><xsl:value-of select="gmd:name/gco:CharacterString"/></name>
                             <protocol>
                                 <xsl:value-of select="gmd:protocol/gco:CharacterString"/>
                             </protocol>
                    </unknownResource>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
