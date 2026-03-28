<#-- Theme-aware head section -->
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="icon" type="image/jpeg" href="/favicon.jpg">
<link rel="apple-touch-icon" href="/favicon.jpg">

<#-- Title -->
<#if content.uri == "index.html">
<title>Fahim Farook - CTO &amp; Software Architect</title>
<#elseif content.uri == "profile.html">
<title>About - Fahim Farook</title>
<#else>
<title>${content.title} - Fahim Farook</title>
</#if>

<#-- Meta -->
<#if (content.description)??>
<meta name="description" content="${content.description}">
<#else>
<meta name="description" content="Fahim Farook - CTO & Software Architect. 15+ years building enterprise platforms for telecom operators across Europe, MENA, South Asia, and the Pacific.">
</#if>
<meta name="author" content="Fahim Farook">

<#-- Open Graph -->
<#if content.uri == "index.html">
<meta property="og:title" content="Fahim Farook - CTO & Software Architect">
<meta property="og:description" content="15+ years building enterprise platforms for telecom operators across Europe, MENA, South Asia, and the Pacific.">
<#elseif content.uri == "profile.html">
<meta property="og:title" content="About - Fahim Farook">
<#else>
<meta property="og:title" content="${content.title} - Fahim Farook">
<#if (content.description)??>
<meta property="og:description" content="${content.description}">
</#if>
</#if>
<meta property="og:type" content="website">
<meta property="og:url" content="${config.site_host}/${content.uri}">

<#-- Twitter Card -->
<meta name="twitter:card" content="summary">
<#if content.uri == "index.html">
<meta name="twitter:title" content="Fahim Farook - CTO & Software Architect">
<meta name="twitter:description" content="15+ years building enterprise platforms for telecom operators across Europe, MENA, South Asia, and the Pacific.">
<#elseif content.uri == "profile.html">
<meta name="twitter:title" content="About - Fahim Farook">
<#else>
<meta name="twitter:title" content="${content.title} - Fahim Farook">
<#if (content.description)??>
<meta name="twitter:description" content="${content.description}">
</#if>
</#if>

<#-- Fonts -->
<#assign theme = config.site_theme!"tufte">
<#if theme == "tufte">
<link rel="stylesheet" href="/css/fonts.css">
<#else>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Montserrat:wght@400;500;600;700&family=Source+Code+Pro:wght@400&display=swap" rel="stylesheet">
</#if>

<#-- KaTeX for LaTeX math rendering (loaded only when needed) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js" crossorigin="anonymous" onload="renderMathInElement(document.body,{delimiters:[{left:'$$',right:'$$',display:true},{left:'$',right:'$',display:false}]});"></script>

<#-- RSS -->
<link rel="alternate" type="application/rss+xml" title="${config.site_title}" href="/feed.xml">

<#-- Theme CSS -->
<link rel="stylesheet" href="/css/${theme}.css">
