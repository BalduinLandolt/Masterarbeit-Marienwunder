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
            <!--<stripped>
                <xsl:copy-of select="$stripped"/>
            </stripped>-->
            <!--<restructured>-->
                <xsl:apply-templates select="$stripped//pb" mode="restructure"/>
            <!--</restructured>-->
        </xml>
    </xsl:template>
    
    <!-- TODO: what if page border is in word? -->
    
    
    
    
    <xsl:template match="tei:w" mode="strip">
        <xsl:variable name="this" select="."/>
        <xsl:choose>
            <xsl:when test=".//tei:lb">
                <xsl:apply-templates select="." mode="strip_lb_in_word"></xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <w>
                    <xsl:apply-templates mode="strip"/>
                </w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:w" mode="strip_lb_in_word">
        <w>
            <xsl:for-each select="child::node()[count(preceding-sibling::tei:lb) = 0]">
                <xsl:apply-templates select="." mode="strip"/>
            </xsl:for-each>
        </w>
        <xsl:apply-templates select="tei:lb" mode="strip_lb_in_word"/>
        <wordpart>
            <xsl:for-each select="child::node()[count(preceding-sibling::tei:lb) > 0]">
                <!-- FIXME: doesn't work -->
                <xsl:apply-templates select="." mode="strip"/>
            </xsl:for-each>
        </wordpart>
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
        <xsl:if test="name(..) != 'w'">
            <xsl:element name="lb">
                <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:lb" mode="strip_lb_in_word">
        <xsl:element name="lb">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:choice" mode="strip">
        <xsl:if test="name(child::node()[1]) = 'abbr'">
            <abbreviation>
                <xsl:apply-templates select="tei:abbr" mode="strip"/>
                <xsl:apply-templates select="tei:expan" mode="strip"/>
            </abbreviation>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:abbr" mode="strip">
        <am>
            <xsl:apply-templates select="tei:am" mode="strip"/>
        </am>
    </xsl:template>
    
    <xsl:template match="tei:expan" mode="strip">
        <infix>
            <xsl:value-of select="child::text()"/>
        </infix>
        <ex>
            <xsl:apply-templates select="tei:ex" mode="strip"/>
        </ex>
    </xsl:template>
    
    <xsl:template match="tei:g" mode="strip">
        <xsl:element name="g">
            <xsl:attribute name="ref"><xsl:value-of select="@ref"/></xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    
    
    
    <xsl:template match="pb" mode="restructure">
        <xsl:element name="page">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <xsl:variable name="count_pb" select="count(preceding::pb)"/>
            <xsl:for-each select="following::lb[count(preceding::pb) = $count_pb+1]">
                <xsl:variable name="number" select="@n"/>
                <xsl:if test="@n != ''">
                    <xsl:apply-templates select="." mode="restructure"></xsl:apply-templates>
                </xsl:if>
            </xsl:for-each>
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
            <!-- TODO: solve problem of linebeginnings in words -->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="pc" mode="restructure">
        <pc><xsl:apply-templates mode="restructure"/></pc>
    </xsl:template>
    
    <xsl:template match="w" mode="restructure">
        <w><xsl:apply-templates mode="restructure"/></w>
    </xsl:template>
    
    <xsl:template match="g" mode="restructure">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="abbreviation" mode="restructure">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
