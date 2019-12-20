<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="text"
        encoding="UTF-8"/>
    
    
    <xsl:template match="/"><xsl:apply-templates select="//tei:body"/></xsl:template>
    
<xsl:template match="tei:body">
/*Raw output from transformation*/

<xsl:apply-templates select="tei:div[@type='volume']"/>
</xsl:template>
    
    <xsl:template match="tei:div[@type='volume']">
        [div:type=<xsl:value-of select="@type"/>:n=<xsl:value-of select="@n"/>]
        
        <xsl:apply-templates select="./tei:div"/>
        
        [/div]
    </xsl:template>
    
    <xsl:template match="tei:div">
        [div:type=<xsl:value-of select="@type"/>:n=<xsl:value-of select="@n"/>]
        
        <xsl:apply-templates/>
        
        [/div]
    </xsl:template>
    
    <xsl:template match="tei:p">
        [p]
        
        <xsl:apply-templates/>
        
        [/p]
    </xsl:template>
    
    <xsl:template match="tei:pb">
        [pb=<xsl:value-of select="@n"/>] </xsl:template>
    
    <xsl:template match="tei:lb">
        [lb=<xsl:value-of select="@n"/>] </xsl:template>
    
    <xsl:template match="tei:head"> [head] <xsl:apply-templates/> [/head] </xsl:template>
    
    <xsl:template match="tei:add[@place]"> [add:place=<xsl:value-of select="@place"/>]<xsl:apply-templates/>[/add] </xsl:template>
    
    <xsl:template match="tei:fw[@place]"> [catch]<xsl:apply-templates/>[/catch] </xsl:template>
    
    
    
    <!-- TODO: corr -->
    <!-- TODO: sic -->
    <!-- TODO: hi -->
    <!-- TODO: supplied -->
    <!-- TODO: abbreviation -->
    <!-- TODO: g -->
    <!-- TODO: surplus -->
    <!-- TODO: gap -->
    <!-- TODO: name -->
    
    
    
    
</xsl:stylesheet>