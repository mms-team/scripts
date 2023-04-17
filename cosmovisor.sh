#!/bin/bash
# Default variables
function="install"

# Options
. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/colours.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/logo_mms.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs or uninstalls Cosmovisor"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help             show the help page"
		echo -e "  -un, --uninstall        uninstall Cosmovisor"
		return 0 2>/dev/null; exit 0
		;;
	-u|-un|--uninstall)
		function="uninstall"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
install() {
	echo -e "${C_LGn}Cosmovisor installation...${RES}"
	sudo apt update
	sudo apt upgrade -y
	sudo apt install wget git build-essential make jq -y
	. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Install/main/golang.sh)
	cd
	git clone https://github.com/cosmos/cosmos-sdk
	cd cosmos-sdk/
	local cosmovisor_version=`git tag -l "cosmovisor*" | tail -n1`
	git checkout $cosmovisor_version
	make cosmovisor
	mv cosmovisor/cosmovisor /usr/bin
	cd
	rm -rf $HOME/cosmos-sdk/
}
uninstall() {
	echo -e "${C_LGn}Cosmovisor uninstalling...${RES}"
	rm -rf $HOME/cosmos-sdk/ `which cosmovisor`
}

# Actions
$function
echo -e "${Bl_Gn}All Operation Completed!${RES}"
. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/logo_mms.sh)
echo
		echo -e "${C_LGn}Visit our resources:${RES}"
		echo -e "${C_C}https://mms.team${RES} — Main_Site"
		echo -e "${C_C}https://t.me/nftmms${RES} — MMS_Research_Chat"
		echo -e "${C_C}https://t.me/cosmochannel_mms${RES} — MMS_Cosmos_Ecosystem_Chat"
		echo -e "${C_C}https://t.me/mmsnodes${RES} — MMS_Nodes_Chat"
		echo -e "${C_C}https://nodes.mms.team${RES} — Guides_and_Manual's"
		echo
