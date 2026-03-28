title=Fahim Farook
description=Fahim Farook - CTO, Software Architect, and Founder of Asymm Systems. 15+ years in distributed systems and telecom digital transformation.
subtitle=Career, approach, open source, education.
type=page
status=published
~~~~~~

I've spent the last <span class="years-since" data-since="2011"></span> years building enterprise platforms, primarily in telecommunications - from engineer at Virtusa serving British Telecom Openreach, through progressively senior roles, to CTO at Arimac Digital where I led delivery for clients like du, Ooredoo, and Vodafone across Europe, MENA, South Asia, and the Pacific.

## What I Do

The work I enjoy most sits at the intersection of systems thinking and hands-on engineering - designing architectures that work at scale, and being willing to go as deep as the problem demands when they don't. I've traced production issues from TCP packet captures through load balancer logs, reactive thread models, JVM heap dumps, and database query execution plans. I believe the best technical leaders stay close to the systems they design.

## Convictions

<span class="marginnote" id="note-decomposition">I favor volatility-based decomposition over domain-driven design as the primary driver of system structure.</span>

- Most enterprise systems fail not because of technology choices, but because of <span data-note="note-decomposition">decomposition choices</span> - cutting along the wrong boundaries.

<span class="marginnote" id="note-close-to-systems">I’ve diagnosed Infinispan split-brain conditions and traced cascading failures from TCP packet captures to JVM heap dumps, and beyond.</span>

- I stay close to the systems I design - especially when they're under load and <span data-note="note-close-to-systems">the abstractions start to break.</span>

- Legacy technologies are still good. XML and XSLT are still excellent - I choose technologies based on the problem, regardless of what's fashionable.

<span class="marginnote" id="note-first-principles">I deliberately chose Docker on VMs over Kubernetes for one Pacific operator because their team wasn't ready for K8s. The architecture that ships and stays up beats the architecture that's theoretically elegant.</span>

- I think from first principles. <span data-note="note-first-principles">If a popular pattern doesn't hold up under scrutiny for a specific context</span>, I don't use it - regardless of how widely adopted it is.

---

## Current Roles

<div class="role-entry"><h4><span data-note="note-arimac-current">Fractional CTO - Arimac Digital</span></h4><span class="marginnote" id="note-arimac-current">Oct 2025 – Present</span></div>

Defining the technical vision, governance, and architecture for telecom platforms and products.

<div class="role-entry"><h4><span data-note="note-asymm">Founder & Principal Architect - Asymm Systems</span></h4><span class="marginnote" id="note-asymm">Aug 2025 – Present</span></div>

A research and product studio exploring distributed systems, novel programming languages, and enterprise integration.

---

## Past Career

<div class="role-entry"><h4><span data-note="note-arimac-cto">Arimac Digital - CTO</span></h4><span class="marginnote" id="note-arimac-cto">Nov 2020 – Aug 2025<br><br>du (UAE) · Ooredoo (Algeria, Oman, Maldives, Myanmar) · Vodafone (PNG, Vanuatu) · Sri Lanka Airlines</span></div>

CTO of a 250+ person technology company. Led enterprise architecture, engineering governance, technology strategy, and technical delivery across 20+ client engagements in telecom, aviation, retail, and government sectors. Engagements ranged from $1B digital transformation programs to greenfield platform builds for operators serving millions of subscribers. Restructured engineering from siloed departments into cross-functional delivery pods. Established architecture governance, engineering policy frameworks, and technology strategy.

<div class="role-entry"><h4><span data-note="note-virtusa">Virtusa Corporation - Engineer → Lead Consultant</span></h4><span class="marginnote" id="note-virtusa">Apr 2011 – Sep 2020<br><br>BT · Singtel · Veracode · McDonald's · Thomson Reuters</span></div>

9+ years at Virtusa Corporation (Nasdaq: VRTU), primarily serving British Telecom Openreach as Software Architect for 7+ years - across order orchestration, network inventory, security operations, and digital transformation. Led 20+ member engineering teams.

---

## Open Source

I contribute to the projects I use.

<ul class="oss-list">
<li><span class="project-name">Spring Cloud Netflix</span> (Hystrix, Eureka) - Contributed PRs addressing distributed platform requirements for British Telecom Openreach. <a href="https://github.com/spring-cloud/spring-cloud-netflix" target="_blank" rel="noopener">GitHub</a></li>
<li><span class="project-name">Spring Boot</span> - Contributed to make map-property-sources refreshable on Spring Cloud environments. <a href="https://github.com/spring-projects/spring-boot" target="_blank" rel="noopener">GitHub</a></li>
<li><span class="project-name">Jasypt Spring Boot</span> - Introduced Jasypt encryption integration for Spring Cloud. <a href="https://github.com/ulisesbocchio/jasypt-spring-boot" target="_blank" rel="noopener">GitHub</a></li>
<li><span class="project-name">Debezium</span> - Contributed a fix to the CDC platform's error handling framework. <a href="https://github.com/debezium/debezium" target="_blank" rel="noopener">GitHub</a></li>
<li><span class="project-name">FSM4JS</span> (Creator) - A declarative Finite State Machine library in JavaScript with stateful states, programmatic transitions, and transition hooks. <a href="https://github.com/fahimfarookme/fsm4js" target="_blank" rel="noopener">GitHub</a></li>
<li><span class="project-name">Hikma</span> (Creator) - A CLI tool for structured knowledge and dotfile management with Zettelkasten-style note linking, PARA-based digital asset organization, template system, and Git integration. <a href="https://github.com/asymmsystems/hikma-cli" target="_blank" rel="noopener">GitHub</a></li>
</ul>

---

## Education

BSc Information Technology - Curtin University, Australia (2008–2011)
*CGPA 3.79 / 4.0*

---

## Selected Recognition

- Top Talent at Virtusa Corporation - continuously rated Outstanding/Exceeds Expectations (2012–2020)
- BT Awards for engineering efficiency, innovation, on-time delivery, and teamwork (2019)
- Mentor Award for significant positive impact on mentees' career growth (2016)
- Merit-based scholarships for superior academic performance at Curtin University (2008–2010)

<script>document.querySelectorAll('.years-since').forEach(function(el){el.textContent=new Date().getFullYear()-parseInt(el.getAttribute('data-since'))});</script>
