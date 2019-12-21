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
    
    <xsl:template match="tei:pb[@n]">
        [pb=<xsl:value-of select="@n"/>] </xsl:template>
    <xsl:template match="tei:pb">
        [pb] </xsl:template>
    
    <xsl:template match="tei:lb[@n]">
        [lb=<xsl:value-of select="@n"/>] </xsl:template>
    <xsl:template match="tei:lb">
        [lb/>] </xsl:template>
    
    <xsl:template match="tei:head"> [head] <xsl:apply-templates/> [/head] </xsl:template>
    
    <xsl:template match="tei:add[@place]"> [add:place=<xsl:value-of select="@place"/>]<xsl:apply-templates/>[/add] </xsl:template>
    <xsl:template match="tei:add"> [add]<xsl:apply-templates/>[/add] </xsl:template>
    
    <xsl:template match="tei:fw"> [catch]<xsl:apply-templates/>[/catch] </xsl:template>
    
    <xsl:template match="tei:supplied[@reason]"> [supplied:reason=<xsl:value-of select="@reason"/>] <xsl:apply-templates/> [/supplied] </xsl:template>
    <xsl:template match="tei:supplied"> [supplied] <xsl:apply-templates/> [/supplied] </xsl:template>
    
    <xsl:template match="tei:surplus[@reason]"> [surplus:reason=<xsl:value-of select="@reason"/>] <xsl:apply-templates/> [/surplus] </xsl:template>
    <xsl:template match="tei:surplus"> [surplus] <xsl:apply-templates/> [/surplus] </xsl:template>
    
    <xsl:template match="tei:hi[@rend]"> [hi:rend=<xsl:value-of select="@rend"/>] <xsl:apply-templates/> [/hi] </xsl:template>
    <xsl:template match="tei:hi"> [hi] <xsl:apply-templates/> [/hi] </xsl:template>
    
    <xsl:template match="tei:name[@type]"> [name:type=<xsl:value-of select="@type"/>] <xsl:apply-templates/> [/name] </xsl:template>
    <xsl:template match="tei:name"> [name] <xsl:apply-templates/> [/name] </xsl:template>
    
    <xsl:template match="tei:gap"> [gap<xsl:for-each select="@*">:<xsl:value-of select="name(.)"/>=<xsl:value-of select="."/></xsl:for-each>] </xsl:template>
    
    <xsl:template match="tei:g[@ref]">{<xsl:value-of select="substring(@ref,2)"/>}</xsl:template>
    
    
    <!-- TODO: corr -->
    <!-- TODO: sic -->
    <!-- TODO: abbreviation -->
    
    
    
    
</xsl:stylesheet>
