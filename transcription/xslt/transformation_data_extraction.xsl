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
            <xsl:variable name="stripped">
                <xsl:apply-templates select="//tei:w | //tei:pc | //tei:pb | //tei:lb" mode="strip"/>
            </xsl:variable>
            <stripped>
                <xsl:copy-of select="$stripped"/>
            </stripped>
            <restructured>
                <xsl:apply-templates select="$stripped//pb" mode="restructure"/>
            </restructured>
        </xml>
    </xsl:template>
    
    
    
    
    <xsl:template match="tei:w" mode="strip">
        <w>
            <xsl:apply-templates mode="strip"/>
        </w>
    </xsl:template>
    
    <xsl:template match="tei:pc" mode="strip">
        <pc><xsl:apply-templates/></pc>
    </xsl:template>
    
    <xsl:template match="tei:pb" mode="strip">
        <xsl:element name="pb">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:lb" mode="strip">
        <xsl:element name="lb">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- TODO: make abbreviations right -->
    <xsl:template match="tei:choice" mode="strip">
        <xsl:if test="name(child::node()[1]) = 'abbr'">
            <abbreviation>
                <xsl:apply-templates select="tei:abbr"/>
                <xsl:apply-templates select="tei:expan"/>
            </abbreviation>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:abbr" mode="strip">
        <am>
            <xsl:apply-templates select="tei:am"/>
        </am>
    </xsl:template>
    
    <xsl:template match="tei:expan" mode="strip">
        <infix>
            <xsl:value-of select="child::text()"/>
        </infix>
        <ex>
            <xsl:apply-templates select="tei:ex"/>
        </ex>
    </xsl:template>
    
    <xsl:template match="tei:g" mode="strip">
        <xsl:element name="g">
            <xsl:attribute name="ref"><xsl:value-of select="@ref"/></xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    
    <!-- TODO: Remove unnecessary -->
    
    <xsl:template match="pb" mode="restructure">
        <xsl:element name="page">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:variable name="count_pb" select="count(preceding::pb)"/>
            <xsl:apply-templates select="following::lb[count(preceding::pb) = $count_pb+1]" mode="restructure"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="lb" mode="restructure">
        <xsl:element name="line">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:variable name="count_lb" select="count(preceding::lb)"/>
            <xsl:for-each select="following::*[count(preceding::lb) = $count_lb+1]">
                <xsl:variable name="current" select="."/>
                <xsl:if test="name(.) = 'pc' or name(.) = 'w'">
                    <xsl:apply-templates select="." mode="restructure"/>
                </xsl:if>
            </xsl:for-each>
            <!-- TODO: suppress lines with catchwords -->
            <!-- TODO: solve problem of linebeginnings in words -->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="pc" mode="restructure">
        <pc><xsl:apply-templates mode="restructure"/></pc>
    </xsl:template>
    
    <xsl:template match="w" mode="restructure">
        <w><xsl:apply-templates/></w>
    </xsl:template>

</xsl:stylesheet>
