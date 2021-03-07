# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 调整CFLAGS等级为O2
sed -i 's/Os/O2/g' include/target.mk

# 开启irqbalance
sed -i 's/0/1/g' feeds/packages/utils/irqbalance/files/irqbalance.config

# 旁路由预置防火墙命令
pushd package/network/config/firewall/files
sed -i "/special user chains, e.g. input_wan_rule or postrouting_lan_rule/a\iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" firewall.user
popd

# 删除lienol luci内的旧版argon主题
rm -rf feeds/luci/themes/luci-theme-argon

# 为lean源添加sub-web & subconverter
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/sub-web package/sub-web
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/subconverter package/subconverter
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/duktape package/duktape
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/jpcre2 package/jpcre2
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/rapidjson package/rapidjson

# Add Jerrykuku's packages(vssr/jd-daily/argon theme/argon config)
git clone https://github.com/jerrykuku/lua-maxminddb package/jerrykuku/lua-maxminddb
git clone https://github.com/jerrykuku/luci-app-argon-config package/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus package/jerrykuku/luci-app-jd-dailybonus
git clone https://github.com/jerrykuku/luci-app-vssr package/jerrykuku/luci-app-vssr
git clone -b master https://github.com/jerrykuku/luci-theme-argon.git package/jerrykuku/luci-theme-argon

# Add luci-app-ssr-plus
git clone https://github.com/fw876/helloworld package/luci-app-ssr-plus
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2 package/redsocks2

# Add luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/openwrt-passwall

# Add OpenClash.
git clone -b master --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Add po2lmo
git clone https://github.com/openwrt-dev/po2lmo.git package/po2lmo
pushd package/po2lmo
make && sudo make install
popd

# Add ServerChan
git clone --depth=1 https://github.com/tty228/luci-app-serverchan package/luci-app-serverchan

# Add luci-theme-edge
git clone --depth=1 https://github.com/garypang13/luci-theme-edge package/luci-theme-edge

# Add luci-app-bypass
git clone https://github.com/garypang13/luci-app-bypass package/luci-app-bypass
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}

# Add luci-app-dnsfilter
git clone https://github.com/garypang13/luci-app-dnsfilter package/luci-app-dnsfilter

# Add luci-app-godproxy
git clone https://github.com/project-lede/luci-app-godproxy package/luci-app-godproxy

# 为lienol源补充v2包
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/lean/v2ray package/lean/v2ray

