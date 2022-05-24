set -e

SAMBA_LOG_LEVEL=${SAMBA_LOG_LEVEL-3}
SAMBA_AD_REALM=${SAMBA_AD_REALM-testrealm}
SAMBA_AD_DOMAIN=${SAMBA_AD_DOMAIN-testdomain}
SAMBA_AD_DISABLE_STRONG_AUTH=${SAMBA_AD_DISABLE_STRONG_AUTH-no}
SAMBA_DISABLE_DEFAULT_USER=${DISABLE_DEFAULT_USER-"0"}
SAMBA_DISABLE_TMPFS=${DISABLE_TMPFS-"0"}

SAMBA_DOMAIN_ARGS="--realm=${SAMBA_AD_REALM} --domain=${SAMBA_AD_DOMAIN} --server-role=dc"

if [ ! -z $SAMBA_AD_HOST_NAME ]; then
	$SAMBA_DOMAIN_ARGS="${SAMBA_DOMAIN_ARGS} --host-name=${SAMBA_AD_HOST_NAME}"
fi

if [ ! -z $SAMBA_AD_HOST_IP ]; then
	$SAMBA_DOMAIN_ARGS="${SAMBA_DOMAIN_ARGS} --host-ip=${SAMBA_AD_HOST_IP}"
fi

if [ ! -z $SAMBA_AD_RFC2307 ] && [ $SAMBA_AD_RFC2307 -ne 0 ]; then
	$SAMBA_DOMAIN_ARGS="${SAMBA_DOMAIN_ARGS} --use-rfc2307"
fi


if [ "$1" = "samba" ]; then
	if [ ! -f /etc/samba/smb.conf ] || ! grep -q 'netbios name = ' /etc/samba/smb.conf; then
		samba-tool domain provision $SAMBA_DOMAIN_ARGS
	fi

	if ! grep -q 'log level = ' /etc/samba/smb.conf ; then
		sed -i "s/\[global\]/[global]\n\tlog level = ${LOGLEVEL}/" /etc/samba/smb.conf
	fi

	if [ "${SAMBA_AD_DISABLE_STRONG_AUTH}" = "yes" ] && ! grep -q 'ldap server require strong auth = no' /etc/samba/smb.conf; then
		sed -i 's/\[global\]/[global]\n\tldap server require strong auth = no/' /etc/samba/smb.conf
		samba-tool domain passwordsettings set --complexity=off
		samba-tool domain passwordsettings set --history-length=0
		samba-tool domain passwordsettings set --min-pwd-age=0
		samba-tool domain passwordsettings set --max-pwd-age=0
	fi

	if [ "${SAMBA_DISABLE_DEFAULT_USER}" -eq "0" ]; then
		/create-users.sh /default_user
	fi

	if [ -f /newusers ]; then
		/create-users.sh /newusers
	fi

	shift 1

	exec /usr/sbin/samba -i "$@"
fi

exec "$@"
