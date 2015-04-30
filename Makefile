ARCHS = armv7 arm64
include theos/makefiles/common.mk
THEOS_DEVICE_IP = 192.168.2.13
TWEAK_NAME = Muswitch
Muswitch_FILES = Tweak.xm
Muswitch_FRAMEWORKS = UIKit
Muswitch_PRIVATE_FRAMEWORKS  = MediaRemote
Muswitch_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
include $(THEOS_MAKE_PATH)/aggregate.mk
