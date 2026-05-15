include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for WiFi and Wired History
LUCI_DEPENDS:=+luci-base +rpcd-mod-iwinfo +ucode +ucode-mod-fs +ucode-mod-ubus
LUCI_DESCRIPTION:=Track and display history of WiFi and Wired associated stations

PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

LUCI_INIT_SCRIPTS := clienthistory

# call BuildPackage - OpenWrt buildroot signature
