#!/usr/bin/env python

from emojiextension import EmojiExtension

AUTHOR = "Nolan Conaway"
SITENAME = "Nolan Conaway's Blog"
SITEURL = ""
PATH = "content"
TIMEZONE = "America/New_York"
DEFAULT_LANG = "en"
DEFAULT_PAGINATION = False
THEME = "theme"
ARTICLE_PATHS = ["articles"]
ARTICLE_SAVE_AS = "blog/{date:%Y}/{slug}.html"
ARTICLE_URL = "blog/{date:%Y}/{slug}.html"
PAGE_SAVE_AS = "{slug}.html"
PAGE_URL = "{slug}.html"
STATIC_PATHS = ["pdfs"]
PLUGIN_PATHS = [
    "plugins",
]
PLUGINS = [
    "bootstrapify",
]
MARKDOWN = {
    "extensions": [EmojiExtension.create_from_json("./resources/emojis.json")],
    "extension_configs": {
        "markdown.extensions.codehilite": {"css_class": "highlight"},
        "markdown.extensions.toc": {},
        "markdown.extensions.extra": {},
        "markdown.extensions.meta": {},
    },
    "output_format": "html5",
}

BOOTSTRAPIFY = {
    "table": ["table", "table-sm", "table-hover"],
    "img": ["img-fluid"],
    "blockquote": ["blockquote"],
}
