# -*- coding: utf-8 -*-

import sys
import os

import sphinx_rtb_theme

source_suffix = '.rst'
master_doc = 'index'
copyright = u'2017'
exclude_patterns = ['_build', 'README.rst']

pygments_style = 'tango'
html_theme = 'sphinx_rtb_theme'
html_theme_path = [sphinx_rtb_theme.get_html_theme_path()]

html_theme_options = {
    'navigation_depth': 2,
    'blog_url': 'https://pawamoy.github.io',
    'disqus_comments': False,
    'disqus_username': 'pawamoy'
}

html_show_copyright = False
# html_favicon = "images/favicon.ico"
project = "ReadTheBlog"
html_title = project

html_context = {
    'extra_css_files': [
        '_static/extra.css',
    ],
}

html_static_path = [
    "extra.css",
]

suppress_warnings = ["image.nonlocal_uri"]
