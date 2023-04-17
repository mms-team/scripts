#!/bin/bash
# Default variables
function="install"
nvm_version=`wget -qO- https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r ".tag_name" | sed "s%v%%g"`

# Options
. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/colours.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/logo_mms.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs or uninstalls NVM"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help             show the help page"
		echo -e "  -v,  --version VERSION  NVM VERSION to install (default is ${C_LGn}${nvm_version}${RES})"
		echo -e "  -un, --uninstall        uninstall NVM"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		return 0 2>/dev/null; exit 0
		;;
	-v*|--version*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		nvm_version=`option_value "$1"`
		shift
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
	echo -e "${C_LGn}NVM installation...${RES}"
	if ! nvm --version | grep -q $nvm_version; then
		sudo apt update
		sudo apt upgrade -y
		sudo apt install wget -y
		cd $HOME
		. <(wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh")
		export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	fi
}
uninstall() {
	echo -e "${C_LGn}Uninstalling NVM...${RES}"
	rm -rf $NVM_DIR
	sed -i "/NVM_DIR/d" $HOME/.bashrc
	unset nvm
}

# Actions
$function
. $HOME/.bashrc
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
