include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-clienthistory
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for WiFi and Ethernet Client History
LUCI_DEPENDS:=+luci-base +rpcd-mod-iwinfo +ucode +ucode-mod-fs +ucode-mod-ubus
LUCI_DESCRIPTION:=Track and display history of connected WiFi and Ethernet clients

PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-clienthistory/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./etc/init.d/clienthistory $(1)/etc/init.d/clienthistory

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./usr/sbin/clienthistory $(1)/usr/sbin/clienthistory

	$(CP) ./htdocs $(1)/
	$(CP) ./ucode $(1)/
	$(CP) ./share $(1)/
	$(CP) ./root/* $(1)/
	$(CP) ./po $(1)/
endef

define Package/luci-app-clienthistory/postinst
#!/bin/sh
[ -f /etc/init.d/clienthistory ] && {
	chmod 755 /etc/init.d/clienthistory
	/etc/init.d/clienthistory enable
	/etc/init.d/clienthistory restart
}
endef

$(eval $(call BuildPackage,luci-app-clienthistory))
