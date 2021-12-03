#!/usr/bin/env bashio

yell() { bashio::log.info "\033[1;32m$*\033[m" >&2; }
die() { bashio::log.error "\033[1;31m$*\033[m"; exit 111; }
try() { "$@" || die "\033[1;31muh-oh! cannot\033[m $*"; }

ECC_ARG="--ecc"

CONFIG="/data/options.json"

SYS_CERTFILE=$(bashio::config 'lets_encrypt.certfile')
SYS_KEYFILE=$(bashio::config 'lets_encrypt.keyfile')

# duckdns
if bashio::config.has_value "ipv4"; then IPV4=$(bashio::config 'ipv4'); else IPV4=""; fi
if bashio::config.has_value "ipv6"; then IPV6=$(bashio::config 'ipv6'); else IPV6=""; fi
TOKEN=$(bashio::config 'token')
DOMAINS=$(bashio::config 'domains | join(",")')
WAIT_TIME=$(bashio::config 'seconds')
# lets encrypt config
ACCOUNT=$(bashio::config 'lets_encrypt.account')
ALGO=$(bashio::config 'lets_encrypt.algo')
CHALLENGE_ALIAS=$(bashio::config 'lets_encrypt.challenge_alias')
CERT_DOMAINS=$(bashio::config 'lets_encrypt.cert_domains | join(" ")')

export DuckDNS_Token="${TOKEN}"

DOMAIN_ARGS=()
T=
IFS=" " read -r -a T <<< "${CERT_DOMAINS}"
for i in "${T[@]}"; do
    DOMAIN_ARGS+=("-d" "${i}")
done
DOMAIN=${T[0]}


register_account() {
    bashio::config.true 'registered' && return 0

    if bashio::config.true 'lets_encrypt.accept_terms'; then
        yell "Registering account ${ACCOUNT}"
        ! (bashio::config.has_value 'lets_encrypt.account') && die "account not set"
        try acme.sh --register-account -m "${ACCOUNT}"

        try bashio::addon.option 'registered' '^true'
        try bashio::addon.options > ${CONFIG}
    else
        yell "lets_encrypt is not enabled."
    fi

    return 0
}

install_cert() {
    yell "installing certificate"
    try acme.sh --install-cert -d "${DOMAIN}" "${ECC_ARG}" --key-file "/ssl/$SYS_KEYFILE" --fullchain-file "/ssl/$SYS_CERTFILE"
}

issue_cert() {
    bashio::config.true 'issued' && return 0

    ! (bashio::config.true 'lets_encrypt.accept_terms') && return 0
    ! (bashio::config.true 'registered') && die "you want a cert but your not registered"

    try acme.sh --issue "${DOMAIN_ARGS[@]}" -k "${ALGO}" --dns dns_duckdns --challenge-alias "${CHALLENGE_ALIAS}" --force
    #local DA=()
    #for i in "${T[@]}"; do
    #    DA+=("-d" "${i}")
    #    try acme.sh --issue "${DA[@]}" -k "${ALGO}" --dns dns_duckdns --challenge-alias "${CHALLENGE_ALIAS}"
    #done

    try install_cert

    try bashio::addon.option 'issued' '^true'
    try bashio::addon.options > ${CONFIG}

    return 0
}

renew_cert() {
    if bashio::config.true 'issued'; then
        acme.sh --renew "${ECC_ARG}" -d "${DOMAIN}"
    fi
    return 0
}

try register_account
try issue_cert

while true; do
    [[ ${IPV4} != *:/* ]] && ipv4=${IPV4} || ipv4=$(curl -s -m 10 "${IPV4}")
    [[ ${IPV6} != *:/* ]] && ipv6=${IPV6} || ipv6=$(curl -s -m 10 "${IPV6}")

    yell "Proccessing: ${DOMAIN}"

    if answer="$(curl -s "https://www.duckdns.org/update?domains=${DOMAINS}&token=${TOKEN}&ip=${ipv4}&ipv6=${ipv6}&verbose=true")" && [ "${answer}" != 'KO' ]; then
        bashio::log.info "${answer}"
    else
        bashio::log.warning "${answer}"
    fi

    try renew_cert
    sleep "${WAIT_TIME}"
done