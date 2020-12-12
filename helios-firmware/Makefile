include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=helios-mcu-firmware
PKG_RELEASE:=1
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./mcu_025.bin $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/helios-mcu-firmware
	SECTION:=firmware
	CATEGORY:=Firmware
	DEPENDS:=@TARGET_ipq40xx
	TITLE:=Sony NCP-HG100 mcu firmware
endef

define Package/helios-mcu-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/mcu_025.bin $(1)/lib/firmware/mcu_025.bin
endef

$(eval $(call BuildPackage,helios-mcu-firmware))
