export TARGET=iphone:7.0:6.0
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = PrivateSpace
PrivateSpace_FILES = Tweak.xm
PrivateSpace_FRAMEWORKS = Accounts UIKit Social

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -exec touch -r _/Library/MobileSubstrate/DynamicLibraries/PrivateSpace.dylib {} \;

after-package::
	rm -fr .theos/packages/*