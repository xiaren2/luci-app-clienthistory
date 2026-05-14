# SPDX-License-Identifier: Apache-2.0
# Maintainer: 你的名字 <you@example.com>

PKG_NAME:=luci-app-clienthistory
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for WiFi and Ethernet Client History
LUCI_DEPENDS:=+luci-base +rpcd-mod-iwinfo +ucode +ucode-mod-fs +ucode-mod-ubus
LUCI_DESCRIPTION:=Track and display history of connected WiFi and Ethernet clients
PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

LUCI_INIT_SCRIPTS := clienthistory

# ============================================================
# Install
# ============================================================

define Package/luci-app-clienthistory/install
	# 安装 init 脚本
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./etc/init.d/clienthistory $(1)/etc/init.d/clienthistory

	# 安装可执行文件
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./usr/sbin/clienthistory $(1)/usr/sbin/clienthistory

	# 安装静态网页资源
	$(CP) ./htdocs $(1)/

	# 安装 ucode 相关文件
	$(CP) ./ucode $(1)/

	# 安装共享资源
	$(CP) ./share $(1)/

	# 安装 root 文件夹内容
	$(CP) ./root/* $(1)/

	# 安装本地化文件
	$(CP) ./po $(1)/
endef

# ============================================================
# Post-install: 确保权限 + 自启
# ============================================================

define Package/luci-app-clienthistory/postinst
#!/bin/sh
[ -f /etc/init.d/clienthistory ] && {
	chmod 755 /etc/init.d/clienthistory
	/etc/init.d/clienthistory enable
	/etc/init.d/clienthistory restart
}
endef

# ============================================================
# Build package
# ============================================================

$(eval $(call BuildPackage,luci-app-clienthistory))
