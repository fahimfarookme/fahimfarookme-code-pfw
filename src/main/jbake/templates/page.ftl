<!DOCTYPE html>
<html lang="en">
<head>
<#include "header.ftl">
</head>
<body>
<div class="site-container">
    <#include "menu.ftl">
    <#if content.uri == "index.html">
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
    <#else>
    <main class="content">
        <div class="page-header">
            <h1 class="page-title">${content.title}</h1>
            <button class="hamburger" id="hamburgerBtn" aria-label="Menu" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
            <nav class="nav-dropdown" id="navDropdown">
                <a href="/">Home</a>
                <a href="/profile.html"<#if content.uri == "profile.html"> class="active"</#if>>About</a>
                <a href="/writing.html"<#if content.uri == "writing.html"> class="active"</#if>>Writing</a>
                <a href="/contact.html"<#if content.uri == "contact.html"> class="active"</#if>>Contact</a>
            </nav>
        </div>
        <#if (content.subtitle)??>
        <p class="page-subtitle">${content.subtitle}</p>
        </#if>
        ${content.body}
    </main>
    <script>
    (function() {
        var btn = document.getElementById('hamburgerBtn');
        var nav = document.getElementById('navDropdown');
        if (btn && nav) {
            /* Position nav-dropdown at hamburger level */
            nav.style.top = btn.offsetTop + 'px';
            btn.addEventListener('click', function() {
                var isOpen = nav.classList.toggle('open');
                btn.classList.toggle('open');
                btn.setAttribute('aria-expanded', isOpen);
            });
        }
        /* Linked sidenotes: hover on [data-note] highlights the marginnote and vice versa */
        document.querySelectorAll('[data-note]').forEach(function(el) {
            var noteId = el.getAttribute('data-note');
            var note = document.getElementById(noteId);
            if (!note) return;
            el.addEventListener('mouseenter', function() { note.classList.add('highlight'); el.classList.add('highlight'); });
            el.addEventListener('mouseleave', function() { note.classList.remove('highlight'); el.classList.remove('highlight'); });
            note.addEventListener('mouseenter', function() { el.classList.add('highlight'); note.classList.add('highlight'); });
            note.addEventListener('mouseleave', function() { el.classList.remove('highlight'); note.classList.remove('highlight'); });
        });
    })();
    </script>
    </#if>
    <#include "footer.ftl">
</div>
</body>
</html>
