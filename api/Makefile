APPLEDOCFILES = $(wildcard *.h) $(wildcard prefs/*.h)
DOCS_STAGING_DIR = _docs
DOCS_OUTPUT_PATH = docs

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = TypeStatusProvider
TypeStatusProvider_FILES = $(wildcard *.m) $(wildcard *.x) $(wildcard *.xm)
TypeStatusProvider_PUBLIC_HEADERS = TypeStatusProvider.h HBTSNotification.h HBTSProvider.h HBTSProviderController.h
TypeStatusProvider_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc
TypeStatusProvider_FRAMEWORKS = MobileCoreServices
TypeStatusProvider_PRIVATE_FRAMEWORKS = AppSupport
TypeStatusProvider_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
TypeStatusProvider_LIBRARIES = rocketbootstrap
TypeStatusProvider_INSTALL_PATH = /usr/lib/TypeStatus

include $(THEOS)/makefiles/framework.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Frameworks$(ECHO_END)

docs::
	[[ -d "$(DOCS_STAGING_DIR)" ]] && rm -r "$(DOCS_STAGING_DIR)" || true

	-appledoc --project-name "TypeStatus" --project-company "HASHBANG Productions" --company-id ws.hbang \
		--project-version 1.2 --no-install-docset --keep-intermediate-files --create-html --publish-docset \
		--docset-feed-url "https://hbang.github.io/typestatus-plus/xcode-docset.atom" \
		--docset-atom-filename xcode-docset.atom --docset-package-url "https://hbang.github.io/typestatus-plus/docset.xar" \
		--docset-package-filename docset --docset-fallback-url "https://hbang.github.io/typestatus-plus/" \
		--docset-feed-name TypeStatusPlusProvider --index-desc README.md --no-repeat-first-par \
		--output "$(DOCS_STAGING_DIR)" $(APPLEDOCFILES)

	[[ -d "$(DOCS_OUTPUT_PATH)" ]] || git clone -b gh-pages git@github.com:hbang/TypeStatus.git "$(DOCS_OUTPUT_PATH)"
	rsync -ra "$(DOCS_STAGING_DIR)"/{html,publish}/ "$(DOCS_OUTPUT_PATH)"
	rm -r "$(DOCS_STAGING_DIR)"
