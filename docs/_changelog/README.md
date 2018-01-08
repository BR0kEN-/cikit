---
title: Changelog
permalink: /changelog/
---

{% assign changelog = site.changelog | reverse %}

{% for item in changelog %}
  {% if page.url != item.url %}
## [{{ item.title }}]({{ item.url }})
<div>{{ item.excerpt }}</div>
  {% endif %}
{% endfor %}
