<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    ISO19110 support
    
    Feature catalogue support:
     * feature catalogue description
     * class/attribute/property/list of values viewing/editing support
    
    Known limitation:
     * iso19110 links between elements (eg. inheritance)
     * partial support of association and feature operation description
     
     @author francois
     @author mathieu
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:str="http://exslt.org/strings" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:geonet="http://www.fao.org/geonetwork" xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <!-- =================================================================== -->
    <!-- default: in simple mode just a flat list -->
    <!-- =================================================================== -->

    <xsl:template mode="iso19110" match="*|@*">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <!-- do not show empty elements in view mode -->
        <xsl:variable name="adjustedSchema">
            <xsl:choose>
                <xsl:when test="namespace-uri(.) != 'http://www.isotc211.org/2005/gfc'">
                    <xsl:text>iso19139</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$schema"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$adjustedSchema"/>
                    <xsl:with-param name="edit" select="true()"/>
                    <xsl:with-param name="flat" select="$currTab='simple'"/>
                </xsl:apply-templates>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="empty">
                    <xsl:apply-templates mode="iso19110IsEmpty" select="."/>
                </xsl:variable>
                <xsl:if test="$empty!=''">
                    <xsl:apply-templates mode="element" select=".">
                        <xsl:with-param name="schema" select="$adjustedSchema"/>
                        <xsl:with-param name="edit" select="false()"/>
                        <xsl:with-param name="flat" select="$currTab='simple'"/>
                    </xsl:apply-templates>
                </xsl:if>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ===================================================================== -->
    <!-- these elements should be boxed -->
    <!-- ===================================================================== -->

    <xsl:template mode="iso19110" match="gfc:*[gfc:FC_FeatureType]|
        gfc:*[gfc:FC_AssociationRole]|
        gfc:*[gfc:FC_AssociationOperation]|
        gfc:listedValue|gfc:constrainedBy|gfc:inheritsFrom|gfc:inheritsTo">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ===================================================================== -->
    <!-- some gco: elements -->
    <!-- ===================================================================== -->

    <xsl:template mode="iso19110"
        match="gfc:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure]|gmd:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gco:Scale|gco:RecordType]">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
        <!-- Generate a textarea when relevant -->
        <xsl:variable name="rows">
            <xsl:choose>
                <xsl:when test="name(.)='gfc:description' or 
                    (name(.)='gfc:definition' and name(parent::*)!='gfc:FC_ListedValue')
                    ">3</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema">
                <xsl:choose>
                    <xsl:when test="namespace-uri(.) != 'http://www.isotc211.org/2005/gfc'">
                        <xsl:text>iso19139</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$schema"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="rows" select="$rows">
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- ================================================================= -->
    <!-- codelists -->
    <!-- ================================================================= -->

    <xsl:template mode="iso19110" match="gfc:*[*/@codeList]|gmd:*[*/@codeList]">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:call-template name="iso19139Codelist">
            <xsl:with-param name="schema">
                <xsl:choose>
                    <xsl:when test="namespace-uri(.) != 'http://www.isotc211.org/2005/gfc'">
                        <xsl:text>iso19139</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$schema"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
    </xsl:template>


    <!-- ============================================================================= -->
    <!--
        date (format = %Y-%m-%d)
        editionDate
        dateOfNextUpdate
        mdDateSt is not editable (!we use DateTime instead of only Date!)
    -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19110"
        match="gfc:versionDate[gco:DateTime|gco:Date]|gmd:editionDate|gmd:dateOfNextUpdate"
        priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="text">
                        <xsl:variable name="ref"
                            select="gco:Date/geonet:element/@ref|gco:DateTime/geonet:element/@ref"/>

                        <table width="100%">
                            <tr>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="gco:DateTime">
                                            <input class="md" type="text" name="_{$ref}"
                                                id="_{$ref}_cal" value="{gco:DateTime/text()}"
                                                size="30" readonly="1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <input class="md" type="text" name="_{$ref}"
                                                id="_{$ref}_cal" value="{gco:Date/text()}" size="30"
                                                readonly="1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td align="center" width="30" valign="middle">
                                    <img src="{/root/gui/url}/scripts/calendar/img.gif"
                                        id="_{$ref}_trigger"
                                        style="cursor: pointer; border: 1px solid;"
                                        title="Date selector"
                                        onmouseover="this.style.background='red';"
                                        onmouseout="this.style.background=''"/>
                                    <script type="text/javascript">
                                        Calendar.setup({
                                                inputField  : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,         // ID of the input field
                                        <xsl:choose>
                                            <xsl:when test="gco:Date">
                                                ifFormat    : "%Y-%m-%d",
                                                showsTime   : false,
                                            </xsl:when>
                                            <xsl:otherwise>
                                                ifFormat    : "%Y-%m-%dT%H:%M:00",   // the date format
                                                showsTime   : true,                  // show the time
                                            </xsl:otherwise>
                                        </xsl:choose>
                                                button: &quot;_<xsl:value-of select="$ref"/>_trigger&quot;
                                            });
                                            Calendar.setup({
                                                inputField: &quot;_<xsl:value-of select="$ref"/>_cal&quot;, 
                                        <xsl:choose>
                                            <xsl:when test="gco:Date">
                                                ifFormat    : "%Y-%m-%d",
                                                showsTime   : false,
                                            </xsl:when>
                                            <xsl:otherwise>
                                                ifFormat    : "%Y-%m-%dT%H:%M:00",  // the date format
                                                showsTime   : true,                 // show the time
                                            </xsl:otherwise>
                                        </xsl:choose>
                                            button: &quot;_<xsl:value-of select="$ref"/>_cal&quot;
                                        });
                                    </script>
                                </td>
                                <td align="left" width="100%">
                                    <xsl:text>  </xsl:text>
                                    <a onclick="javascript:setBunload(false);"
                                        href="javascript:clearRef('{$ref}');">
                                        <xsl:value-of select="/root/gui/strings/clear"/>
                                    </a>
                                </td>
                            </tr>
                        </table>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="iso19139String">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==================================================================== -->
    <!-- Do not display those elements:
     * hide nested featureType elements
     * hide definition reference elements
     * inheritance : does not support linking feature catalogue objects (eg. to indicate subtype or supertype) 
    -->
    <xsl:template mode="iso19110" match="gfc:featureType[ancestor::gfc:featureType]|
        gfc:definitionReference|
        gfc:valueMeasurementunit|
        gfc:featureCatalogue|
        gfc:FC_InheritanceRelation/gfc:featureCatalogue|
        @gco:isoType" priority="100"/>
    
    <xsl:template mode="elementEP" match="
        geonet:child[@name='definitionReference']|
        geonet:child[@name='featureCatalogue']|
        geonet:child[@name='featureType']|
        geonet:child[@name='valueMeasurementunit']|
        gfc:FC_InheritanceRelation/geonet:child[@name='subtype']|
        gfc:FC_InheritanceRelation/geonet:child[@name='supertype']
        " priority="100"/>
    
    <!-- ==================================================================== -->
    <!-- Metadata -->
    <!-- ==================================================================== -->

    <xsl:template mode="iso19110" match="gfc:FC_FeatureCatalogue|*[@gco:isoType='gfc:FC_FeatureCatalogue']">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="embedded"/>

		<xsl:if test="/root/gui/config/editor-metadata-relation">
			<div style="float:right;">
				<xsl:call-template name="relatedResources">
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:call-template>
			</div>
		</xsl:if>

        <xsl:call-template name="iso19110Simple">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$currTab='simple'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ============================================================================= -->
    <!--
        simple mode; ISO order is:
    -->
    <!-- ============================================================================= -->

    <xsl:template name="iso19110Simple">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="flat"/>

        <xsl:call-template name="iso19110Metadata">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>

        <xsl:apply-templates mode="elementEP" select="gfc:featureType">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- ===================================================================== -->
    <!-- === iso19110 brief formatting === -->
    <!-- ===================================================================== -->

    <xsl:template name="iso19110Brief">
        <metadata>
            <xsl:variable name="id" select="geonet:info/id"/>
            <xsl:variable name="uuid" select="geonet:info/uuid"/>

            <xsl:if test="gfc:name">
                <title>
                    <xsl:value-of select="gfc:name/gco:CharacterString"/>
                </title>
            </xsl:if>

            <xsl:if test="gfc:scope">
                <abstract>
                    <xsl:value-of select="gfc:scope/gco:CharacterString"/>
                </abstract>
            </xsl:if>

            <xsl:copy-of select="geonet:*"/>
        </metadata>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template name="iso19110Metadata">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <!-- if the parent is root then display fields not in tabs -->
        <xsl:choose>
            <xsl:when test="name(..)='root'">
                <xsl:apply-templates mode="elementEP"
                    select="@uuid">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="false()"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gfc:name">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP" select="gfc:scope">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP" select="gfc:fieldOfApplication">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP" select="gfc:versionNumber">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP" select="gfc:versionDate">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP" select="gfc:producer">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP" select="gfc:functionalLanguage">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

            </xsl:when>

            <!-- otherwise, display everything because we have embedded gfc:FC_FeatureCatalogue -->

            <xsl:otherwise>
                <xsl:apply-templates mode="elementEP" select="*">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Display producer as contact in ISO 19139 -->
    <xsl:template mode="iso19110" match="gfc:producer">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
        <xsl:call-template name="contactTemplate">
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template mode="iso19110" match="gfc:carrierOfCharacteristics/gfc:FC_FeatureAttribute">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:variable name="content">
            <td class="padded-content" width="100%" colspan="2">
                <table width="100%">
                    <tr>
                        <td width="50%" valign="top">
                            <table width="100%">
                                
                                <xsl:apply-templates mode="elementEP" select="gfc:memberName|geonet:child[string(@name)='memberName']">
                                    <xsl:with-param name="schema" select="$schema"/>
                                    <xsl:with-param name="edit"   select="$edit"/>
                                </xsl:apply-templates>
                                
                                <xsl:apply-templates mode="elementEP" select="gfc:definition|geonet:child[string(@name)='definition']">
                                    <xsl:with-param name="schema" select="$schema"/>
                                    <xsl:with-param name="edit"   select="$edit"/>
                                </xsl:apply-templates>
                                
                                <xsl:apply-templates mode="elementEP" select="gfc:cardinality|geonet:child[string(@name)='cardinality']">
                                    <xsl:with-param name="schema" select="$schema"/>
                                    <xsl:with-param name="edit"   select="$edit"/>
                                </xsl:apply-templates>
                                
                                <xsl:apply-templates mode="elementEP" select="gfc:featureType|geonet:child[string(@name)='featureType']">
                                    <xsl:with-param name="schema" select="$schema"/>
                                    <xsl:with-param name="edit"   select="$edit"/>
                                </xsl:apply-templates>
                                
                                <xsl:apply-templates mode="elementEP" select="gfc:valueType|geonet:child[string(@name)='valueType']">
                                    <xsl:with-param name="schema" select="$schema"/>
                                    <xsl:with-param name="edit"   select="$edit"/>
                                </xsl:apply-templates>
                                
                            </table>
                        </td>
                        <td valign="top">
                            <table width="100%">
                                <xsl:choose>
                                    <xsl:when test="$edit=true() or $currTab!='simple'">
                                        <xsl:apply-templates mode="elementEP" select="gfc:listedValue|geonet:child[string(@name)='listedValue']">
                                            <xsl:with-param name="schema" select="$schema"/>
                                            <xsl:with-param name="edit" select="$edit"/>
                                        </xsl:apply-templates>        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="gfc:listedValue">
                                            <xsl:call-template name="complexElementGui">
                                                <xsl:with-param name="title">
                                                    <xsl:value-of select="/root/gui/iso19110/element[@name='gfc:listedValue']/label"/>
                                                    <xsl:text> </xsl:text>
                                                    (<xsl:value-of select="/root/gui/iso19110/element[@name='gfc:label']/label"/>
                                                    [<xsl:value-of select="/root/gui/iso19110/element[@name='gfc:code']/label"/>] :
                                                    <xsl:value-of select="/root/gui/iso19110/element[@name='gfc:definition']/label"/>)
                                                </xsl:with-param>
                                                <xsl:with-param name="content">
                                                
                                                <ul class="md">
                                                    <xsl:for-each select="gfc:listedValue/gfc:FC_ListedValue">
                                                        <li>
                                                            <b><xsl:value-of select="gfc:label/gco:CharacterString"/></b> 
                                                            [<xsl:value-of select="gfc:code/gco:CharacterString"/>] :
                                                            <xsl:value-of select="gfc:definition/gco:CharacterString"/>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </xsl:variable>

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:apply-templates>

    </xsl:template>
    
    <!-- handle cardinality edition 
        Update fixed info take care of setting UnlimitedInteger attribute.
    -->
    <xsl:template mode="iso19110" match="gfc:cardinality">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
        <!-- Variables -->
        <xsl:variable name="minValue" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:lower/gco:Integer"/>
        <xsl:variable name="maxValue" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper/gco:UnlimitedInteger"/>
        <xsl:variable name="isInfinite" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper/gco:UnlimitedInteger/@isInfinite"/>
        
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:variable name="cardinality">
                    <tr>
                        <td colspan="2">
                            <table width="100%">
                                <tr>
                                    <th class="md" width="20%" valign="top">
                                        <span id="stip.iso19110|gco:lower"  onclick="toolTip(this.id);" style="cursor: help;">
                                            <xsl:value-of select="string(/root/gui/iso19110/element[@name='gco:lower']/label)"/>
                                        </span>
                                    </th>
                                    <td class="padded" valign="top">
                                        <!-- Min cardinality list -->
                                        <select name="_{$minValue/geonet:element/@ref}" class="md" size="1">
                                            <option value=""/>
                                            <option value="0">
                                                <xsl:if test="$minValue = '0'">
                                                    <xsl:attribute name="selected"/>
                                                </xsl:if>
                                                <xsl:text>0</xsl:text>
                                            </option>
                                            <option value="1">
                                                <xsl:if test="$minValue = '1'">
                                                    <xsl:attribute name="selected"/>
                                                </xsl:if>
                                                <xsl:text>1</xsl:text>
                                            </option>
                                        </select>
                                    </td>
                                    <th class="md" width="20%" valign="top">
                                        <span id="stip.iso19110|gco:upper"  onclick="toolTip(this.id);" style="cursor: help;">
                                            <xsl:value-of select="string(/root/gui/iso19110/element[@name='gco:upper']/label)"/>
                                        </span>
                                    </th>
                                    <td class="padded" valign="top">
                                        <!-- Max cardinality list -->
                                        <select name="minCard" class="md" size="1" onchange="updateUpperCardinality('_{$maxValue/geonet:element/@ref}', this.value)">
                                            <option value=""/>
                                            <option value="0">
                                                <xsl:if test="$maxValue = '0'">
                                                    <xsl:attribute name="selected"/>
                                                </xsl:if>
                                                <xsl:text>0</xsl:text>
                                            </option>
                                            <option value="1">
                                                <xsl:if test="$maxValue = '1'">
                                                    <xsl:attribute name="selected"/>
                                                </xsl:if>
                                                <xsl:text>1</xsl:text>
                                            </option>
                                            <option value="n">
                                                <xsl:if test="$isInfinite = 'true'">
                                                    <xsl:attribute name="selected"/>
                                                </xsl:if>
                                                <xsl:text>n</xsl:text>
                                            </option>
                                        </select>
                                        
                                        <!-- Hidden value to post -->
                                        <input type="hidden" name="_{$maxValue/geonet:element/@ref}" id="_{$maxValue/geonet:element/@ref}" value="{$maxValue}" />
                                        <input type="hidden" name="_{$maxValue/geonet:element/@ref}_isInfinite" id="_{$maxValue/geonet:element/@ref}_isInfinite" value="{$isInfinite}"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </xsl:variable>
                <xsl:apply-templates mode="complexElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="$edit"/>
                    <xsl:with-param name="content">
                        <xsl:copy-of select="$cardinality"/>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td colspan="2">
                        <table width="100%">
                            <tr>
                                <xsl:if test="$minValue != ''">
                                    <th class="md" width="20%" valign="top">
                                        <span id="stip.iso19110|gco:lower"  onclick="toolTip(this.id);" style="cursor: help;">
                                            <xsl:value-of select="string(/root/gui/iso19110/element[@name='gco:lower']/label)"/>
                                        </span>
                                    </th>
                                    <td class="padded" valign="top">
                                        <xsl:value-of select="$minValue"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$maxValue !='' or $isInfinite = 'true'">
                                    <th class="md" width="20%" valign="top">
                                        <span id="stip.iso19110|gco:upper"  onclick="toolTip(this.id);" style="cursor: help;">
                                            <xsl:value-of select="string(/root/gui/iso19110/element[@name='gco:upper']/label)"/>
                                        </span>
                                    </th>
                                    <td class="padded" valign="top">
                                        <xsl:choose>
                                            <xsl:when test="$isInfinite = 'true'">
                                                <xsl:text>n</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$maxValue != ''">
                                                <xsl:value-of select="$maxValue"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </td>
                                </xsl:if>
                            </tr>
                        </table>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>