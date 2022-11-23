#!/bin/bash

##################################
go_version="1.19.1"
github_link="https://github.com/neutron-org/neutron"
binary_version="0.1.0"
binary_commit="a9e8ba5ebb9230bec97a4f2826d75a4e0e6130d9"

PROJECT_CHAIN="quark-1"
##################################

echo "
**********************************
********* NEUTRON INSTALL ********
 __     __   __     __   ________
|  \   /  | |  \   /  | |  ______|
| |\\_//| | | |\\_//| | | |______
| | \_/ | | | | \_/ | | |______  |
| |     | | | |     | |  ______| |
|_|     |_| |_|     |_| |________|

*********** WE ARE MMS ***********
**********************************"

echo "Enter the node name (Moniker) and press Enter:"
read PROJECT_MONIKER

# Server preparation #

apt update && apt upgrade -y

apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# Previous installation removing #

if [ -d $HOME/.neutrond ]; then rm -rf $HOME/.neutrond; fi

# GO installation #

wget "https://golang.org/dl/go$go_version.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$go_version.linux-amd64.tar.gz" && \
rm "go$go_version.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
if [[ "$(go version)" =~ "$go_version" ]]; then echo "GO version check passed."; else "ERROR: GO is not installed or the version is incorrect."; exit 1; fi

# Neutron binary installation #

git clone $github_link && cd neutron
git checkout v${binary_version}
make install

mv $HOME/go/bin/neutrond /usr/local/bin/neutrond

if [[ "$(neutrond version --long | grep -e version)" =~ "$binary_version" ]]; then echo "INFO: Binary version check passed."; else "ERROR: Neutron binary is not installed or the version is incorrect."; exit 1; fi

# Node initialization #

neutrond init $PROJECT_MONIKER --chain-id $PROJECT_CHAIN

# Download genesis #

wget -O $HOME/.neutrond/config/genesis.json "https://raw.githubusercontent.com/neutron-org/testnets/main/quark/genesis.json"

sha256sum ~/.neutrond/config/genesis.json
# 357c4d33fad26c001d086c0705793768ef32c884a6ba4aa73237ab03dd0cc2b4

# Node configuration #

neutrond config chain-id $PROJECT_CHAIN

sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025untrn\"/;" ~/.neutrond/config/app.toml

external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.neutrond/config/config.toml

peers="fcde59cbba742b86de260730d54daa60467c91a5@23.109.158.180:26656,5bdc67a5d5219aeda3c743e04fdcd72dcb150ba3@65.109.31.114:2480,3e9656706c94ae8b11596e53656c80cf092abe5d@65.21.250.197:46656,9cb73281f6774e42176905e548c134fc45bbe579@162.55.134.54:26656,27b07238cf2ea76acabd5d84d396d447d72aa01b@65.109.54.15:51656,f10c2cb08f82225a7ef2367709e8ac427d61d1b5@57.128.144.247:26656,20b4f9207cdc9d0310399f848f057621f7251846@222.106.187.13:40006,5019864f233cee00f3a6974d9ccaac65caa83807@162.19.31.150:55256,2144ce0e9e08b2a30c132fbde52101b753df788d@194.163.168.99:26656,b37326e3acd60d4e0ea2e3223d00633605fb4f79@nebula.p2p.org:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.neutrond/config/config.toml

seeds="e2c07e8e6e808fb36cca0fc580e31216772841df@seed-1.quark.ntrn.info:26656,c89b8316f006075ad6ae37349220dd56796b92fa@tenderseed.ccvalidators.com:29001"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.neutrond/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.neutrond/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.neutrond/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.neutrond/config/config.toml
sed -i -e "s/^timeout_commit *=.*/timeout_commit = \"2s\"/" $HOME/.neutrond/config/config.toml

# Pruning setup #

pruning="custom"
pruning_keep_recent="1000"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.neutrond/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.neutrond/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.neutrond/config/app.toml

# Service file creation #

sudo tee /etc/systemd/system/neutrond.service > /dev/null <<EOF
[Unit]
Description=neutrond
After=network-online.target

[Service]
User=$USER
ExecStart=$(which neutrond) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Service start #

systemctl daemon-reload
systemctl enable neutrond
systemctl restart neutrond && journalctl -u neutrond -f -o cat
