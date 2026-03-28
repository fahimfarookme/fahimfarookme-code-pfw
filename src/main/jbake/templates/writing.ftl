<!DOCTYPE html>
<html lang="en">
<head>
<#include "header.ftl">
</head>
<body>
<div class="site-container">
    <main class="content">
        <div class="page-header">
            <h1 class="page-title">${content.title}</h1>
            <button class="hamburger" id="hamburgerBtn" aria-label="Menu" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
            <nav class="nav-dropdown" id="navDropdown">
                <a href="/">Home</a>
                <a href="/profile.html">About</a>
                <a href="/writing.html" class="active">Writing</a>
                <a href="/contact.html">Contact</a>
            </nav>
        </div>
        <#if (content.subtitle)??>
        <p class="page-subtitle">${content.subtitle}</p>
        </#if>

        <#-- Auto-generated post list from published_posts -->
        <#list published_posts as post>
        <div class="writing-post">
            <a href="/${post.uri}">${post.title}</a>
            <span class="writing-date">${post.date?string("MMMM yyyy")}</span>
        </div>
        </#list>

        <#-- Manual content from writing.md body (e.g. "coming soon" entries) -->
        ${content.body}
    </main>
    <script>
    (function() {
        var btn = document.getElementById('hamburgerBtn');
        var nav = document.getElementById('navDropdown');
        btn.addEventListener('click', function() {
            var isOpen = nav.classList.toggle('open');
            btn.classList.toggle('open');
            btn.setAttribute('aria-expanded', isOpen);
        });
    })();
    </script>
    <#include "footer.ftl">
</div>
</body>
</html>
