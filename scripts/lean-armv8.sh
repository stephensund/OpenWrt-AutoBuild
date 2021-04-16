# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 调整CFLAGS等级为O3
sed -i 's/Os/O3/g' include/target.mk

# 开启irqbalance
sed -i 's/0/1/g' feeds/packages/utils/irqbalance/files/irqbalance.config

# 替换默认软件源为腾讯源（armv8）
pushd files/etc/opkg
touch distfeeds.conf
cat > distfeeds.conf <<EOF
src/gz core https://mirrors.cloud.tencent.com/lede/snapshots/targets/armvirt/64/packages
src/gz base https://mirrors.cloud.tencent.com/lede/snapshots/packages/aarch64_cortex-a53/base
src/gz luci https://mirrors.cloud.tencent.com/lede/snapshots/packages/aarch64_cortex-a53/luci
src/gz packages https://mirrors.cloud.tencent.com/lede/snapshots/packages/aarch64_cortex-a53/packages
src/gz routing https://mirrors.cloud.tencent.com/lede/snapshots/packages/aarch64_cortex-a53/routing
src/gz telephony https://mirrors.cloud.tencent.com/lede/snapshots/packages/aarch64_cortex-a53/telephony
EOF
popd

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d-%H%M"))/g" zzz-default-settings
popd

# Add luci-app-dnsfilter
git clone https://github.com/garypang13/luci-app-dnsfilter package/luci-app-dnsfilter

# Add luci-app-godproxy
git clone https://github.com/project-lede/luci-app-godproxy package/luci-app-godproxy

# Add Jerrykuku's packages
rm -rf package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/lua-maxminddb package/jerrykuku/lua-maxminddb
git clone https://github.com/jerrykuku/luci-app-argon-config package/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-vssr package/jerrykuku/luci-app-vssr
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/jerrykuku/luci-theme-argon
sed -i 's/DEPENDS.*/& \+luci-theme-argon/g'  package/jerrykuku/luci-app-argon-config/Makefile

# Add passwall
rm -rf package/lean/dns2socks 
rm -rf package/lean/ipt2socks 
rm -rf package/lean/kcptun
rm -rf feeds/packages/net/kcptun
rm -rf package/lean/microsocks
rm -rf package/lean/pdnsd-alt
rm -rf package/lean/simple-obfs
rm -rf package/lean/shadowsocksr-libev
rm -rf package/lean/trojan
rm -rf package/lean/v2ray-plugin
git clone https://github.com/xiaorouji/openwrt-passwall package/openwrt-passwall

# Add bypass
git clone --depth=1 https://github.com/garypang13/luci-app-bypass package/luci-app-bypass
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}
git clone https://github.com/garypang13/smartdns-le package/smartdns-le
sed -i 's/default n/default y/g' package/luci-app-bypass/Makefile

# Add OpenClash
git clone --depth=1 -b master https://github.com/vernesong/OpenClash package/openclash
pushd package/openclash/luci-app-openclash/tools/po2lmo
make && sudo make install
popd


# 补全Openclash依赖
sed -i 's/DEPENDS.*/& \+kmod-tun +libcap-bin/g'  package/openclash/luci-app-openclash/Makefile

# Add ServerChan
git clone --depth=1 https://github.com/tty228/luci-app-serverchan package/luci-app-serverchan

# Add adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome

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

# Disable goproxy in some packages
sed -i 's/default y/default n/g' package/lean/UnblockNeteaseMusicGo/Makefile

# passwall/vssr默认子项目全选
sed -i 's/default n/default y/g' package/openwrt-passwall/luci-app-passwall/Makefile
sed -i 's/default n/default y/g' package/jerrykuku/luci-app-vssr/Makefile

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
