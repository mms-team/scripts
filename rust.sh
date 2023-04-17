#!/bin/bash
# Default variables
function="install"
nightly="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/colours.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/logo_mms.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs or uninstalls Rust"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help       show the help page"
		echo -e "  -n,  --nightly    install nightly version of Rust"
		echo -e "  -un, --uninstall  uninstall Rust"
		return 0 2>/dev/null; exit 0
		;;
	-n|--nightly)
		nightly="true"
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
	echo -e "${C_LGn}Rust installation...${RES}"
	sudo apt update
	sudo apt upgrade -y
	sudo apt install curl build-essential pkg-config libssl-dev libudev-dev clang make -y
	touch $HOME/.bash_profile
	curl --proto '=https' -sSf https://sh.rustup.rs | sh -s -- -y
	echo -e "${C_R}^ X Don't do that X ^${RES}\n"
	sed -i '0,/cargo\/env/{/cargo\/env/d;}' $HOME/.bash_profile
	local former_path="$PATH"
	sed -i '0,/ PATH=/{/ PATH=/d;}' $HOME/.bash_profile
	. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/add_variables.sh) -n PATH -v "$HOME/.cargo/bin:$former_path"
	if [ "$nightly" = "true" ]; then
		rustup toolchain install nightly
		rustup default nightly
	fi
}
uninstall() {
	echo -e "${C_LGn}Rust uninstalling...${RES}"
	rustup self uninstall -y
	local new_path=`sed -e "s%$HOME/.cargo/bin:%%" <<< "$PATH"`
	sed -i '0,/ PATH=/{/ PATH=/d;}' $HOME/.bash_profile
	. <(wget -qO- https://raw.githubusercontent.com/1Malenok1/Stuff/main/add_variables.sh) -n PATH -v "$new_path"	
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
