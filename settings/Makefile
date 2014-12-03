export TARGET=iphone:8.1:6.0
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = PrivateSpace
PrivateSpace_FILES = Settings.mm
PrivateSpace_INSTALL_PATH = /Library/PreferenceBundles
PrivateSpace_FRAMEWORKS = UIKit
PrivateSpace_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PrivateSpace.plist$(ECHO_END)
