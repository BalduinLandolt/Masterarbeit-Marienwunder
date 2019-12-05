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
        </xml>
    </xsl:template>
    
    <xsl:template match="tei:pb">
        <xsl:element name="page">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:variable name="count_pb" select="count(preceding::tei:pb)"/>
            <xsl:apply-templates select="following::tei:lb[count(preceding::tei:pb) = $count_pb+1]"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <xsl:element name="line">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:variable name="count_lb" select="count(preceding::tei:lb)"/>
            <xsl:for-each select="following::*[count(preceding::tei:lb) = $count_lb+1]">
                <xsl:if test="name(.) != 'lb'">
                    <xsl:apply-templates select="."/>
                </xsl:if>
            </xsl:for-each>
            <!-- TODO: suppress lines with catchwords -->
            <!-- TODO: fix, when lb is in some particulat element, not just p -->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:hi">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:supplied">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:w">
        <w><xsl:apply-templates/></w>
    </xsl:template>
    
    <xsl:template match="tei:g">
        <xsl:element name="g">
            <xsl:attribute name="ref"><xsl:value-of select="@ref"/></xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:choice">
        <xsl:if test="name(child::node()[1]) = 'abbr'">It's an abbreviation!</xsl:if>
    </xsl:template>

</xsl:stylesheet>
