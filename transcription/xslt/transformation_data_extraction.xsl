<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="xs tei"
                version="2.0">
    
    <xsl:output method="xml"
                encoding="UTF-8"
                indent="yes"/>


    <xsl:template match="/">
        
        <xml>
            <xsl:apply-templates select="//tei:pb"/>
            <!--<xsl:apply-templates select="//tei:div"/>-->
        </xml>
    </xsl:template>
    
<!--    <xsl:template match="tei:div">
        <xsl:for-each select=".//tei:pb">
            <page>
                Page: <xsl:value-of select="position()"/> <br/>
                <xsl:for-each select="following::*">
                    
                    <xsl:copy-of select="."></xsl:copy-of>
                </xsl:for-each>
            </page>
        </xsl:for-each>
    </xsl:template>-->
    
    <xsl:template match="tei:pb">
        <xsl:element name="page">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:variable name="count" select="count(preceding::tei:pb)"/>
            Page: <xsl:value-of select="$count"/>
<!--            <xsl:for-each select="following::*">
                expression: <xsl:value-of select="count(preceding::tei:pb)"/>
            </xsl:for-each>-->
            <xsl:apply-templates select="following::*[count(preceding::tei:pb) = $count+1]"></xsl:apply-templates>
<!--            <xsl:for-each select="following::*[count(preceding::tei:pb) = $count]">
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:for-each>-->
        </xsl:element>
    </xsl:template>


</xsl:stylesheet>
