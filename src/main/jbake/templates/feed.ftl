<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <title>${config.site_title}</title>
        <link>${config.site_host}</link>
        <atom:link href="${config.site_host}/feed.xml" rel="self" type="application/rss+xml" />
        <description>Technical writing on distributed systems, enterprise architecture, and telecom digital transformation.</description>
        <language>en</language>
        <#list published_posts as post>
        <item>
            <title><![CDATA[${post.title}]]></title>
            <link>${config.site_host}/${post.uri}</link>
            <guid isPermaLink="true">${config.site_host}/${post.uri}</guid>
            <pubDate>${post.date?string("EEE, dd MMM yyyy HH:mm:ss Z")}</pubDate>
            <#if (post.description)??><description><![CDATA[${post.description}]]></description></#if>
        </item>
        </#list>
    </channel>
</rss>
