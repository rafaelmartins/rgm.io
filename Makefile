### Settings

AUTHOR_NAME      = "Rafael Martins"
AUTHOR_EMAIL     = "rafael@rafaelmartins.eng.br"
SITE_TITLE       = "Rafael Martins"
SITE_TAGLINE     = "Rafael Martins' website."
BASE_DOMAIN      = "https://rgm.io"
LICENSE          = "CC-BY-NC-ND-4.0"
LOCALE           = "en_US.utf-8"
TOCTREE_MAXDEPTH = "2"

# content should be sorted in the order wanted for index.
# atom feeds will sort automatically by date.
CONTENT = \
	post/balde-internals-part1-foundations \
	-project/blogc \
	meta/colophon \
	-meta/author \
	talk/fosdem17 \
	talk/fisl15 \
	talk/pybr9 \
	talk/linuxcon2011 \
	talk/goj2011 \
	error \
	$(NULL)

CONTENT_FILES = \
	talk/fisl15-balde.pdf \
	talk/fosdem17-lago.pdf \
	talk/goj2011-distpatch.pdf \
	talk/linuxcon2011-linuxeng.pdf \
	$(NULL)

CONTENT_TYPES = \
	project \
	post \
	meta \
	talk \
	$(NULL)

ATOM_TAGS = \
	gentoo \
	$(NULL)

PRIMER_SCSS = \
	index.scss \
	base/base.scss \
	base/index.scss \
	base/kbd.scss \
	base/normalize.scss \
	base/typography-base.scss \
	layout/container.scss \
	layout/grid-offset.scss \
	layout/grid.scss \
	layout/index.scss \
	markdown/blob-csv.scss \
	markdown/code.scss \
	markdown/headings.scss \
	markdown/images.scss \
	markdown/index.scss \
	markdown/lists.scss \
	markdown/markdown-body.scss \
	markdown/tables.scss \
	support/index.scss \
	support/mixins/buttons.scss \
	support/mixins/layout.scss \
	support/mixins/misc.scss \
	support/mixins/typography.scss \
	support/variables/colors.scss \
	support/variables/color-system.scss \
	support/variables/layout.scss \
	support/variables/misc.scss \
	support/variables/typography.scss \
	utilities/animations.scss \
	utilities/borders.scss \
	utilities/box-shadow.scss \
	utilities/colors.scss \
	utilities/details.scss \
	utilities/flexbox.scss \
	utilities/index.scss \
	utilities/layout.scss \
	utilities/margin.scss \
	utilities/padding.scss \
	utilities/typography.scss \
	utilities/visibility-display.scss \
	$(NULL)

ASSETS = \
	anchor.min.js \
	highlight/github.css \
	highlight/highlight.pack.js \
	$(NULL)


### Programs

BLOGC           ?= $(shell which blogc)
BLOGC_RUNSERVER ?= $(shell which blogc-runserver)

MKDIR ?= $(shell which mkdir)
SASSC ?= $(shell which sassc)
CP    ?= $(shell which cp)


### Overridable settings

BLOGC_RUNSERVER_HOST ?= 127.0.0.1
BLOGC_RUNSERVER_PORT ?= 8080

OUTPUT_DIR  ?= _build
BASE_URL    ?=


### Helper variables

DATE_FORMAT      = "%b %d, %Y"
DATE_FORMAT_ATOM = "%Y-%m-%dT%H:%M:%SZ"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D AUTHOR_NAME=$(AUTHOR_NAME) \
		-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
		-D SITE_TITLE=$(SITE_TITLE) \
		-D SITE_TAGLINE=$(SITE_TAGLINE) \
		-D BASE_DOMAIN=$(BASE_DOMAIN) \
		-D LICENSE=$(LICENSE) \
		-D TOCTREE_MAXDEPTH=$(TOCTREE_MAXDEPTH) \
		-D BASE_URL=$(BASE_URL) \
		-D ATOM_TAGS="$(ATOM_TAGS)" \
		-D CONTENT_TYPES="$(CONTENT_TYPES)" \
	$(NULL)

CONTENT_LIST = $(foreach base, $(CONTENT), $(wildcard content/$(base:-%=%).txt) $(wildcard content/$(base:-%=%)/index.txt))
CONTENT_TYPE_LIST = $(addprefix content/, $(addsuffix /index.txt, $(CONTENT_TYPES)))


### Rules

all: \
	$(OUTPUT_DIR)/index.html \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(filter-out -%,$(CONTENT)))) \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(CONTENT_TYPES))) \
	$(OUTPUT_DIR)/atom/index.xml \
	$(addprefix $(OUTPUT_DIR)/atom/, $(addsuffix /index.xml, $(ATOM_TAGS))) \
	$(OUTPUT_DIR)/assets/primer.min.css \
	$(addprefix $(OUTPUT_DIR)/assets/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/files/, $(CONTENT_FILES)) \
	$(NULL)

$(OUTPUT_DIR)/index.html: $(CONTENT_LIST) $(CONTENT_TYPE_LIST) templates/main.html Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-l \
		$(addprefix -e , $(CONTENT_TYPE_LIST)) \
		-o $@ \
		-t templates/main.html \
		$(CONTENT_LIST)

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.html Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.html \
		$<

$(OUTPUT_DIR)/%/index.html: content/%/index.txt $(CONTENT_LIST) templates/main.html Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_TYPE=$* \
		-l \
		-e $< \
		-o $@ \
		-t templates/main.html \
		$(CONTENT_LIST)

$(OUTPUT_DIR)/atom/index.xml: $(CONTENT_LIST) templates/atom.xml Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_SORT=1 \
		-D FILTER_TAG=posts \
		-l \
		-o $@ \
		-t templates/atom.xml \
		$(CONTENT_LIST)

$(OUTPUT_DIR)/atom/%/index.xml: $(CONTENT_LIST) templates/atom.xml Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_SORT=1 \
		-D FILTER_TAG=$(shell echo $@ | rev | cut -d/ -f2 | rev) \
		-l \
		-o $@ \
		-t templates/atom.xml \
		$(CONTENT_LIST)

$(OUTPUT_DIR)/assets/primer.min.css: $(addprefix assets/primer/, $(PRIMER_SCSS)) Makefile
	$(MKDIR) -p $(dir $@)
	$(SASSC) --style compressed $< $@

$(OUTPUT_DIR)/assets/%: assets/% Makefile
	$(MKDIR) -p $(dir $@)
	$(CP) $< $@

$(OUTPUT_DIR)/files/%: content/files/% Makefile
	$(MKDIR) -p $(dir $@)
	$(CP) $< $@

ifneq ($(BLOGC_RUNSERVER),)
runserver: all
	$(BLOGC_RUNSERVER) -t $(BLOGC_RUNSERVER_HOST) -p $(BLOGC_RUNSERVER_PORT) $(OUTPUT_DIR)

.PHONY: runserver
endif

clean:
	rm -rf "$(OUTPUT_DIR)"

# this rule is just an alias, so website-builder knows that this Makefile
# supports it!
website-builder: all

.PHONY: all clean website-builder
