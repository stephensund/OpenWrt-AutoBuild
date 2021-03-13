# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 调整CFLAGS等级为O3
sed -i 's/Os/O3/g' include/target.mk

# 开启irqbalance
sed -i 's/0/1/g' feeds/packages/utils/irqbalance/files/irqbalance.config

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d-%H%M"))/g" zzz-default-settings
popd

# 旁路由预置防火墙命令
pushd package/network/config/firewall/files
sed -i "/special user chains, e.g. input_wan_rule or postrouting_lan_rule/a\iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" firewall.user
popd

# Add luci-app-bypass
git clone https://github.com/garypang13/luci-app-bypass package/luci-app-bypass
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}

# 为lean源补充v2包
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/lean/v2ray package/lean/v2ray

# 为lean源添加sub-web & subconverter
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/sub-web package/sub-web
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/subconverter package/subconverter
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/duktape package/duktape
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/jpcre2 package/jpcre2
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/ctcgfw/rapidjson package/rapidjson
svn co https://github.com/immortalwrt/packages/trunk/lang/node-yarn package/node-yarn

# Add luci-app-dnsfilter
git clone https://github.com/garypang13/luci-app-dnsfilter package/luci-app-dnsfilter

# Add luci-app-godproxy
git clone https://github.com/project-lede/luci-app-godproxy package/luci-app-godproxy

# Add Jerrykuku's packages(vssr/jd-daily/argon theme)
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/luci-app-jd-dailybonus
git clone https://github.com/jerrykuku/lua-maxminddb package/jerrykuku/lua-maxminddb
git clone https://github.com/jerrykuku/luci-app-argon-config package/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus package/jerrykuku/luci-app-jd-dailybonus
git clone https://github.com/jerrykuku/luci-app-vssr package/jerrykuku/luci-app-vssr
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/jerrykuku/luci-theme-argon

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package package/Lienol-package

# Add luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/openwrt-passwall

# Add OpenClash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash  package/luci-app-openclash

# 补全Openclash依赖
sed -i 's/DEPENDS.*/& \+kmod-tun +libcap-bin/g'  package/luci-app-openclash/Makefile

# Add po2lmo
git clone https://github.com/openwrt-dev/po2lmo.git package/po2lmo
pushd package/po2lmo
make && sudo make install
popd

# Add ServerChan
git clone --depth=1 https://github.com/tty228/luci-app-serverchan package/luci-app-serverchan

# Add luci-app-adguardhome
git clone --depth=1 https://github.com/SuLingGG/luci-app-adguardhome package/luci-app-adguardhome

# Add luci-theme-edge
git clone -b 18.06 --depth=1 https://github.com/garypang13/luci-theme-edge package/luci-theme-edge


# Add luci-app-diskman
git clone --depth=1 https://github.com/SuLingGG/luci-app-diskman package/luci-app-diskman
mkdir package/parted
cp package/luci-app-diskman/Parted.Makefile package/parted/Makefile

# Add luci-app-dockerman
rm -rf package/lean/luci-app-docker
git clone --depth=1 https://github.com/KFERMercer/luci-app-dockerman package/luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-lib-docker package/lisaac/luci-lib-docker

# Add smartdns
git clone -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns

# Use Lienol's https-dns-proxy package
pushd feeds/packages/net
rm -rf https-dns-proxy
svn co https://github.com/Lienol/openwrt-packages/trunk/net/https-dns-proxy
popd

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
svn co https://github.com/openwrt/packages/trunk/libs/libssh
popd

# Use snapshots syncthing package
pushd feeds/packages/utils
rm -rf syncthing
svn co https://github.com/openwrt/packages/trunk/utils/syncthing
popd

# preset cores for openclash
mkdir -p files/etc/openclash/core
open_clash_main_url=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/Clash | grep /clash-linux-armv8 | sed 's/.*url\": \"//g' | sed 's/\"//g')
clash_tun_url=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN-Premium | grep /clash-linux-armv8 | sed 's/.*url\": \"//g' | sed 's/\"//g')
clash_game_url=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN | grep /clash-linux-armv8 | sed 's/.*url\": \"//g' | sed 's/\"//g')
wget -qO- $open_clash_main_url | tar xOvz > files/etc/openclash/core/clash
wget -qO- $clash_tun_url | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $clash_game_url | tar xOvz > files/etc/openclash/core/clash_game
chmod +x files/etc/openclash/core/clash*


# preset terminal tools(oh-my-zsh)

mkdir -p files/root
pushd files/root

## Install oh-my-zsh
# Clone oh-my-zsh repository
git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh

# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions

# Get .zshrc dotfile
cp $GITHUB_WORKSPACE/data/zsh/.zshrc .
popd

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd
