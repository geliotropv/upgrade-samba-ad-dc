FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get -y install attr krb5-config krb5-user ldap-utils libnss-winbind libpam-krb5 libpam-winbind samba winbind && \
	rm -f /etc/samba/smb.conf

COPY entrypoint.sh /entrypoint.sh
COPY create-users.sh /create-users.sh
COPY default_user /default_user

RUN chmod 755 /entrypoint.sh /create-users.sh && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists

ENTRYPOINT ["/entrypoint.sh"]

CMD ["samba"]
