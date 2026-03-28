<!DOCTYPE html>
<html lang="en">
<head>
<#include "header.ftl">
</head>
<body>
<div class="site-container">
    <#include "menu.ftl">
    <main class="hero">
        <p>I'm <strong>Fahim Farook</strong> - a CTO and software architect with ${.now?string("yyyy")?number - 2011} years building enterprise platforms for telecom operators including British Telecom, du, Ooredoo, and Vodafone across Europe, MENA, South Asia, and the Pacific.</p>

        <p>I started as an engineer at <a href="https://www.virtusa.com/" target="_blank" rel="noopener">Virtusa</a>, progressed through increasingly senior roles, and spent the last five years as CTO at <a href="https://arimac.digital" target="_blank" rel="noopener">Arimac Digital</a>. Currently, I'm exploring programming language design for standards-heavy enterprise domains through <a href="https://asymm.systems" target="_blank" rel="noopener">Asymm Systems</a>, my research and product studio.</p>

        <p>I'm a contributor to <a href="https://github.com/spring-cloud/spring-cloud-netflix" target="_blank" rel="noopener">Spring Cloud Netflix</a>, <a href="https://github.com/spring-projects/spring-boot" target="_blank" rel="noopener">Spring Boot</a>, and <a href="https://github.com/debezium/debezium" target="_blank" rel="noopener">Debezium</a>.</p>

        <p class="contact-links">
            <a href="https://linkedin.com/in/fahimfarookme" target="_blank" rel="noopener">LinkedIn</a>
            <span class="separator">&middot;</span>
            <a href="https://github.com/fahimfarookme" target="_blank" rel="noopener">GitHub</a>
            <span class="separator">&middot;</span>
            <a href="mailto:fahim@asymm.systems">fahim@asymm.systems</a>
        </p>
    </main>
    <#include "footer.ftl">
</div>
</body>
</html>
