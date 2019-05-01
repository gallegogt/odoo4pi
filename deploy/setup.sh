#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
NC='\033[0m' # No Color
SUCCESS='\033[0;32m'


echo_success() {
  echo -n ".... ${SUCCESS}[OK]${NC}"
}

echo_failure() {
  echo -n ".... ${SUCCESS}[ERROR]${OK}"
  exit 1
}

# Use step(), try(), and next() to perform a series of commands and print
# [  OK  ] or [FAILED] at the end. The step as a whole fails if any individual
# command fails.
#
# Example:
#     step "Remounting / and /boot as read-write:"
#     try mount -o remount,rw /
#     try mount -o remount,rw /boot
#     next
step() {
    echo -n "$@"

    STEP_OK=0
    [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
}

try() {
    # Check for `-b' argument to run command in the background.
    local BG=

    [[ $1 == -b ]] && { BG=1; shift; }
    [[ $1 == -- ]] && {       shift; }

    # Run the command.
    if [[ -z $BG ]]; then
        "$@"
    else
        "$@" &
    fi

    # Check if command failed and update $STEP_OK if so.
    local EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        STEP_OK=$EXIT_CODE
        [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$

        if [[ -n $LOG_STEPS ]]; then
            local FILE=$(readlink -m "${BASH_SOURCE[1]}")
            local LINE=${BASH_LINENO[0]}

            echo "$FILE: line $LINE: Command \`$*' failed with exit code $EXIT_CODE." >> "$LOG_STEPS"
        fi
    fi

    return $EXIT_CODE
}

next() {
    [[ -f /tmp/step.$$ ]] && { STEP_OK=$(< /tmp/step.$$); rm -f /tmp/step.$$; }
    [[ $STEP_OK -eq 0 ]]  && echo_success || echo_failure
    echo

    return $STEP_OK
}

#
# Instalación de addons
#
CUR_PATH=$(dirname "$0")
ADDONS_PATH=$PWD/$CUR_PATH/volumes/odoo/addons/
# cd $CUR_PATH/volumes/odoo/addons/
mkdir -p /tmp/odoo-addons
cd /tmp/odoo-addons
rm -rf *

step "Configurando KonosCL addons ..."
try git clone --branch 11.0 https://github.com/KonosCL/addons-konos.git
next
try cp -rf ./addons-konos/* $ADDONS_PATH
next

# step "Configurando dansanti/l10n_cl_dte_point_of_sale addons ..."
# try git clone --branch 11.0 https://gitlab.com/dansanti/l10n_cl_dte_point_of_sale.git
# next
# try cp -rf ./l10n_cl_dte_point_of_sale $ADDONS_PATH
# next

# step "Configurando dansanti/l10n_cl_fe addons ..."
# try git clone --branch 11.0 https://gitlab.com/dansanti/l10n_cl_fe.git
# next
# try cp -rf ./l10n_cl_fe $ADDONS_PATH
# next

step "Configurando dansanti/payment_khipu.git addons ..."
try git clone --branch 11.0 https://gitlab.com/dansanti/payment_khipu.git
next
try cp -rf ./payment_khipu $ADDONS_PATH
next

step "Configurando dansanti/payment_webpay addons ..."
try git clone --branch 11.0 https://gitlab.com/dansanti/payment_webpay.git
next
try cp -rf ./payment_webpay $ADDONS_PATH
next

# step "Configurando dansanti/l10n_cl_stock_picking addons ..."
#try git clone https://gitlab.com/dansanti/l10n_cl_stock_picking.git
# next
# try cp -rf ./l10n_cl_stock_picking $ADDONS_PATH
# next

step "Configurando odoocoop/facturacion_electronica addons ..."
try git clone --branch 11.0 https://github.com/odoocoop/facturacion_electronica.git
next
try cp -rf ./facturacion_electronica/*  $ADDONS_PATH
next

step "Configurando OCA/reporting-engine addons ..."
try git clone --branch 11.0 https://github.com/OCA/reporting-engine.git
next
try cp -rf ./reporting-engine/*  $ADDONS_PATH
next
