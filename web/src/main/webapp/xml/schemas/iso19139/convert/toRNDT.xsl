<?xml version="1.0" encoding="UTF-8"?>

<!-- CONVERTS A 19139 METADATO INTO RNDT FORMAT -->
<!-- This file is used both in
    web/src/main/webapp/xsl/conversion/export/xml_rndt.xsl
       for RNDT export and for CSW calls
    web/src/main/webapp/xml/schemas/iso19139/convert/toRNDT.xsl
       for RNDT formatted data into MEF files

    WHEN EDITING THIS FILE, PLEASE UPDATE BOTH LOCATIONS
-->

<xsl:stylesheet version="1.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xlink="http://www.w3.org/1999/xlink"

                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                xmlns:ows="http://www.opengis.net/ows"
                xmlns:ogc="http://www.opengis.net/ogc"
                xmlns:inspire_ds="http://inspire.ec.europa.eu/schemas/inspire_ds/1.0"
                xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
    
	<!-- This stylesheet converts ISO19115 and ISO19139 metadata into RNDT metadata in XML format -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

    <!-- we are requiring an XSL transformtion to GN, so we have to extract the real info from all the stuff, localization, USW -->
    <xsl:template match="/root">
		<xsl:choose>
            <!-- exporting single metadata -->
			<xsl:when test="gmd:MD_Metadata">
				<xsl:apply-templates select="gmd:MD_Metadata"/>
			</xsl:when>

            <!-- CSW stuff -->
            <xsl:when test="csw:Capabilities">
				<xsl:apply-templates select="csw:Capabilities"/>
			</xsl:when>
			<xsl:when test="csw:DescribeRecordResponse">
				<xsl:apply-templates select="csw:DescribeRecordResponse"/>
			</xsl:when>
			<xsl:when test="csw:GetRecordsResponse">
				<xsl:apply-templates select="csw:GetRecordsResponse"/>
			</xsl:when>
			<xsl:when test="csw:GetRecordByIdResponse">
				<xsl:apply-templates select="csw:GetRecordByIdResponse"/>
			</xsl:when>

			<xsl:when test="ows:ExceptionReport">
				<xsl:apply-templates select="ows:ExceptionReport"/>
			</xsl:when>
            <xsl:otherwise>
                <xsl:comment>Operation not recognized, check RNDT exporter</xsl:comment>
                <ows:ExceptionReport version="1.0.0" xsi:schemaLocation="http://www.opengis.net/ows http://schemas.opengis.net/ows/1.0.0/owsExceptionReport.xsd">
                    <ows:Exception exceptionCode="OperationNotSupported" locator="{/root/request/request}"/>
                </ows:ExceptionReport>
            </xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()[name(self::*)!='geonet:info']"/>
			</xsl:copy>
	</xsl:template>

    <!-- PROCESS CODELISTS: -->
    <!-- 1)  fill default @codeList if needed -->
    <!-- 2)  set text value as codeListValue if needed -->
    <!--
        gmd:MD_ScopeCode
        gmd:CI_RoleCode>
        gmd:CI_DateTypeCode>
        gmd:CI_PresentationFormCode
        gmd:MD_MaintenanceFrequencyCode
        gmd:MD_KeywordTypeCode
        gmd:CI_DateTypeCode
        gmd:MD_RestrictionCode
        gmd:MD_ClassificationCode
        gmd:MD_SpatialRepresentationTypeCode
        gmd:MD_CharacterSetCode
        gmd:MD_DimensionNameTypeCode
        gmd:MD_CellGeometryCode
        gmd:MD_CoverageContentTypeCode
    -->

    <xsl:template match="gmd:MD_ScopeCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ScopeCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:CI_RoleCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_RoleCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:LanguageCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#LanguageCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:CI_DateTypeCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:CI_PresentationFormCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_PresentationFormCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_MaintenanceFrequencyCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_MaintenanceFrequencyCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_KeywordTypeCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_RestrictionCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_RestrictionCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_ClassificationCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ClassificationCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_SpatialRepresentationTypeCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_SpatialRepresentationTypeCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_CharacterSetCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_CharacterSetCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_DimensionNameTypeCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_DimensionNameTypeCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_CellGeometryCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_CellGeometryCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_CoverageContentTypeCode">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_CoverageContentTypeCode</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="srv:SV_CouplingType">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#SV_CouplingType</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="srv:DCPList">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="./@codeList=''">
                <xsl:attribute name="codeList">http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#DCPList</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(string(.))">
                <xsl:value-of select="./@codeListValue"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- Remove empty MimeFileType:
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
<!--	<xsl:template match="gmd:onLine/gmd:CI_OnlineResource[gmd:name/gmx:MimeFileType/@type='']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()[name(self::*)!='geonet:info' and name(self::*)!='gmd:name']"/>
        </xsl:copy>
	</xsl:template>
-->

    <!-- Remove all MimeFileType -->
	<xsl:template match="gmd:onLine/gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType">
        <xsl:element name="gco:CharacterString">
            <xsl:value-of select="."/>
        </xsl:element>
        <xsl:comment>Replaced gmx:MimeFileType type "<xsl:value-of select="@type"/>"</xsl:comment>
	</xsl:template>


    <xsl:template match="gmd:verticalCRS[@xlink:href='']">
        <xsl:copy>
            <xsl:attribute name="href">http://www.rndt.gov.it/ReferenceSystemCode#999</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
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

    <!-- Remove the full time extent if neither begin not end postion is defined -->

    <xsl:template match="gmd:MD_DataIdentification/gmd:extent|srv:SV_ServiceIdentification/srv:extent"></xsl:template>
        <xsl:choose>
            <!-- both start and end position missing -->
            <xsl:when test="gmd:EX_Extent/gmd:temporalElement and not(string(gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition)) and not(string(gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition))">
                <xsl:comment>Limiti temporali non definiti</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="datetime2date">
        <xsl:param name="datetime">0000-00-00</xsl:param>
        <xsl:choose>
            <xsl:when test="contains($datetime, 'T')">
                <xsl:value-of select="substring-before($datetime, 'T')"/>
            </xsl:when>
            <xsl:otherwise>
                    <xsl:value-of select="$datetime"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Remove empty beginPosition element -->

    <xsl:template match="gml:beginPosition | gml:endPosition">
        <xsl:choose>
            <xsl:when test="string(.)">
                <xsl:copy>
                    <xsl:call-template name="datetime2date">
                        <xsl:with-param name="datetime" select="."/>
                    </xsl:call-template>
                    <!--<xsl:apply-templates select="@*|node()"/>-->
                </xsl:copy>
                <xsl:comment>Date cropped from gco:DateTime "<xsl:value-of select="."/>"</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>Limite del TimePeriod non definito, possibile errore in validazione RNDT</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Remove un-compiled conformance -->

    <!-- next template is what is required by INSPIRE, but RNDT implementation requires to null the pass element-->
<!--    <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report">
        <xsl:choose>
            <xsl:when test="gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:explanation/gco:CharacterString='non valutato'">
                <xsl:comment>Conformance non compilata</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->

    <!-- Remove pass element in un-compiled conformance -->

    <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:pass">
        <xsl:choose>
            <xsl:when test="../gmd:explanation/gco:CharacterString='non valutato'">
                <xsl:copy>
                </xsl:copy>
                <xsl:comment>Conformance non compilata</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Remove bitsPerValue if not compiled -->

    <xsl:template match="gmd:MD_ImageDescription/gmd:dimension">
        <xsl:choose>
            <xsl:when test="string(gmd:MD_Band/gmd:bitsPerValue/gco:Integer)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>bitsPerValue non definito</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Remove resolution/measure if not compiled -->

    <xsl:template match="gmd:MD_Dimension/gmd:resolution">
        <xsl:choose>
            <xsl:when test="string(gco:Measure)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>resolution/Measure non definito</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Add decimals and coords separators -->
    <xsl:template match="gml:coordinates">
        <xsl:copy>
            <xsl:attribute name="decimal">.</xsl:attribute>
            <xsl:attribute name="cs">,</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Crop all DateTime to Date -->
    <xsl:template match="gco:DateTime">
        <xsl:element name="gco:Date">
            <xsl:value-of select="substring-before(., 'T')"/>
        </xsl:element>
        <xsl:comment>Date cropped from gco:DateTime "<xsl:value-of select="."/>"</xsl:comment>
    </xsl:template>


    <!-- ================================================================== -->
    <!-- CSW TRANSFORMATIONS ============================================== -->
    <!-- ================================================================== -->

    <!-- getCapabilities -->

    <!-- Add ".rndt" to csw service endpoint -->

    <!--
        <ows:Operation name="GetDomain">
            <ows:DCP>
                <ows:HTTP>
                    <ows:Get xlink:href="$PROTOCOL://$HOST:$PORT$SERVLET/srv/$LOCALE/csw"/>
                    <ows:Post xlink:href="$PROTOCOL://$HOST:$PORT$SERVLET/srv/$LOCALE/csw"/>
     -->

    <xsl:template match="ows:Operation/ows:DCP/ows:HTTP/ows:Get">
        <xsl:copy>
            <xsl:attribute name="xlink:href"><xsl:value-of select="@xlink:href"/>.rndt</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ows:Operation/ows:DCP/ows:HTTP/ows:Post">
        <xsl:copy>
            <xsl:attribute name="xlink:href"><xsl:value-of select="@xlink:href"/>.rndt</xsl:attribute>
        </xsl:copy>
    </xsl:template>


    <!--
        <inspire_ds:ExtendedCapabilities>
          <inspire_common:ResourceLocator>
            <inspire_common:URL>http://localhost:8080/geonetwork/srv/en/csw?SERVICE=CSW&amp;VERSION=2.0.2&amp;REQUEST=GetCapabilities</inspire_common:URL>
    -->


    <xsl:template match="inspire_ds:ExtendedCapabilities/inspire_common:ResourceLocator/inspire_common:URL[string(../inspire_common:MediaType)='application/xml']">
        <xsl:copy>
            <xsl:value-of select='concat(substring-before(string(.),"/csw?"),"/csw.rndt?",substring-after(string(.),"/csw?"))'/>
        </xsl:copy>
    </xsl:template>



    <!-- TODO: probably we need to add matches for SOAP CSW requests -->


</xsl:stylesheet>
