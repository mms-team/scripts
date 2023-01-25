#!/bin/bash

# Developed by fastom (MMS team)
# TG: @mmsnodes @fastom794

if [[ "$1" != "-b" ]] && [[ "$1" != "-g" ]] && [[ "$1" != "-a" ]]; then
	echo "========================================="
	echo "============ MMS TX SPAMMER ============="
	echo "========================================="
	echo "Usage:"
	echo ""
	echo "$0 -g	- Generate TXs"
	echo "$0 -b	- Broadcast TXs"
	echo "$0 -a	- Generate and broadcast TXs"
	echo ""
	echo "Note: Transaction generation takes a lot of time, so it's better to do it in advance."
	echo ""
	exit 1
fi

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SIGNED_TX_FOLDER=${currentDir}/temp
UNSIGNED_TX_JSON_FILE=${currentDir}/tx.json

### CONFIG

PROJECT_CHAIN=uptick_7000-2
PROJECT_WALLET=MMS_Wallet
PROJECT_PASSPHRASE=123123123
PROJECT_ADDR_FROM=uptick146hv265eqcvg3ewwwmagr4hcjp384y2mjx29tq
PROJECT_ADDR_TO=uptick146hv265eqcvg3ewwwmagr4hcjp384y2mjx29t
PROJECT_BINARY=uptickd
PROJECT_DENOM=auptick
PROJECT_RPC=tcp://0.0.0.0:29657

TX_COUNT=10
TX_AMOUNT=1
TX_MEMO="MMS"
TX_GAS_ADJUSTMENT=2
TX_FEES=100

PAUSE_BEFORE_CHECK=15

#### get last sequence and account functuons

function get_last_sequence {
	LAST_SEQUENCE=$(${PROJECT_BINARY} q account $PROJECT_ADDR_FROM --node $PROJECT_RPC | grep sequence: | awk -F '\"' '{print $2}')
	echo ${LAST_SEQUENCE}
}

function get_account_id {
	ACCOUNT_ID=$(${PROJECT_BINARY} q account $PROJECT_ADDR_FROM --node $PROJECT_RPC | grep account_number: | awk -F '\"' '{print $2}')
	echo ${ACCOUNT_ID}
}

function check_tx {
	local TX_CODE=$(${PROJECT_BINARY} query tx $1 --node ${PROJECT_RPC} 2>/dev/null | grep code: | awk '{print $NF}')
	if [[ "$TX_CODE" == "0" ]]; then echo "TX $1 : PASSED"; else echo "TX $1 : FAILED"; fi
}

#### init

function init {
if [ ! -d $SIGNED_TX_FOLDER ]; then mkdir $SIGNED_TX_FOLDER; fi
get_last_sequence > /dev/null
get_account_id > /dev/null
}

#### generate tx.json

function generate_tx {
echo -e "${PROJECT_PASSPHRASE} \n" | ${PROJECT_BINARY} tx bank send $PROJECT_ADDR_FROM $PROJECT_ADDR_TO ${TX_AMOUNT}${PROJECT_DENOM} --node $PROJECT_RPC --chain-id $PROJECT_CHAIN -y --note "${TX_MEMO}" --generate-only --gas-adjustment ${TX_GAS_ADJUSTMENT} --fees ${TX_FEES}${PROJECT_DENOM} > $UNSIGNED_TX_JSON_FILE
echo "Unsigned TX:"
cat $UNSIGNED_TX_JSON_FILE
}

### output ###

function checks {
echo "Account: ${ACCOUNT_ID}"
echo "Last Sequence: ${LAST_SEQUENCE}"
}

### sign txs

function sign_txs {
for (( i=$LAST_SEQUENCE;i<=((LAST_SEQUENCE+TX_COUNT)); i++ ))
do
	echo "Generating tx_$i.json"
	echo -e "${PROJECT_PASSPHRASE} \n" | ${PROJECT_BINARY} tx sign ${UNSIGNED_TX_JSON_FILE} -s $i -a $ACCOUNT_ID --offline --from $PROJECT_WALLET --gas-adjustment ${TX_GAS_ADJUSTMENT} --fees ${TX_FEES}${PROJECT_DENOM} --chain-id ${PROJECT_CHAIN} --output-document ${SIGNED_TX_FOLDER}/tx_$i.json
done
}

### broadcast txs

function broadcast_txs {
for (( i=$LAST_SEQUENCE;i<=((LAST_SEQUENCE+TX_COUNT)); i++ ))
do
        echo "Broadcasting tx_$i.json"
        echo -e "${PROJECT_PASSPHRASE} \n" | ${PROJECT_BINARY} tx broadcast ${SIGNED_TX_FOLDER}/tx_$i.json -y --node ${PROJECT_RPC} -b async > ${SIGNED_TX_FOLDER}/result_$i.json
done
}

### check txs

function check_txs {
sleep $PAUSE_BEFORE_CHECK
echo "CHECKING TXs"
for (( i=$LAST_SEQUENCE;i<=((LAST_SEQUENCE+TX_COUNT)); i++ ))
do
	tx=$(cat ${SIGNED_TX_FOLDER}/result_$i.json | grep txhash: | awk '{print $NF}')
	echo "result_$i.json | $(check_tx $tx)"
done
}
##########################################

init
if [[ "$1" == "-a" ]] || [[ "$1" == "-g" ]]; then generate_tx; fi
checks
if [[ "$1" == "-a" ]] || [[ "$1" == "-g" ]]; then sign_txs; fi
if [[ "$1" == "-a" ]] || [[ "$1" == "-b" ]]; then broadcast_txs; fi
if [[ "$1" == "-a" ]] || [[ "$1" == "-b" ]]; then check_txs; fi
