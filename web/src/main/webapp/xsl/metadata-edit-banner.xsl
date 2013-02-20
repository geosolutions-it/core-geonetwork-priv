<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
	metadata edit html banner
	-->
	<xsl:template name="metadatabanner">

		<table width="100%">

			<!-- title -->
			<tr>
				<td>
					<img src="{/root/gui/url}/images/csi/banner1.jpg" alt="CSI Piemonte logo" />
				</td>
				<td align="right" style="vertical-align: bottom">
					<img src="{/root/gui/url}/images/csi/banner2.jpg" alt="Regione Piemonte logo" align="middle"/>
				</td>
				<!--td class="banner">
					<img src="{/root/gui/url}/images/header-left.jpg" alt="World picture" align="top" />
				</td>
				<td align="right" class="banner">
					<img src="{/root/gui/url}/images/header-right.gif" alt="GeoNetwork opensource logo" align="top" />
				</td-->
			</tr>
		</table>
	</xsl:template>

</xsl:stylesheet>

