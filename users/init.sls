#!jinja|yaml

{% from 'users/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('users:lookup')) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

{%- macro set_p(paramname, dictvar) -%}
  {%- if paramname in dictvar -%}
- {{ paramname }}: {{ dictvar[paramname] }}
  {%- endif -%}
{%- endmacro -%}

{% set users = salt['pillar.get']('users:manage', {}) %}
{% set groups = salt['pillar.get']('groups:manage', {}) %}

{% for id, g in groups|dictsort %}
  {% set name = g.name|default(id) %}

group_{{ name }}:
  group:
    - present
    - name: {{ name }}
{{ set_p('gid', g)|indent(4, True) }}
{{ set_p('system', g)|indent(4, True) }}
{{ set_p('addusers', g)|indent(4, True) }}
{{ set_p('delusers', g)|indent(4, True) }}
{{ set_p('members', g)|indent(4, True) }}
{% endfor %}

{% for id, u in users|dictsort %}
  {% set name = u.name|default(id) %}
  {% set home_dir = u.home|default(salt['user.info'](name).home|default('/home/' ~ name)) %}

user_{{ name }}:
  user:
    - present
    - name: {{ name }}
{{ set_p('uid', u)|indent(4, True) }}
{{ set_p('gid', u)|indent(4, True) }}
{{ set_p('groups', u)|indent(4, True) }}
{{ set_p('optional_groups', u)|indent(4, True) }}
{{ set_p('home', u)|indent(4, True) }}
{{ set_p('shell', u)|indent(4, True) }}
{{ set_p('createhome', u)|indent(4, True) }}
{{ set_p('password', u)|indent(4, True) }}
{{ set_p('system', u)|indent(4, True) }}

user_{{ name }}_sshdir:
  file:
    - directory
    - name: {{ home_dir }}/.ssh
    - mode: 700
    - user: {{ name }}
    - group: {{ name }}
    - require:
      - user: user_{{ name }}

  {% for k in u.sshpubkeys|default([]) %}
user_{{ name }}_ssh_auth_{{ k.key[-20:] }}:
  ssh_auth:
    - {{ k.ensure|default('present') }}
    - name: {{ k.key }}
    - user: {{ name }}
    - enc: {{ k.enc|default('ssh-rsa') }}
{{ set_p('comment', k)|indent(4, True) }}
{{ set_p('options', k)|indent(4, True) }}
  {% endfor %}

  {% if 'sshconfig' in u %}
user_{{ name }}_ssh_config:
  file:
    - managed
    - name: {{ home_dir }}/.ssh/config
    - user: {{ name }}
    - group: {{ name }}
    - mode: 640
    - contents: |
    {%- for configid, configsettings in u.sshconfig|dictsort %}
{{ configsettings.content|indent(8, True) }}
    {% endfor %}
  {% endif %}
{% endfor %}
