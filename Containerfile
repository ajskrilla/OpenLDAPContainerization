# Containerfile
FROM rockylinux:9

# 1) Install OpenLDAP
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled plus && \
    dnf install -y openldap-servers openldap-clients iproute && \
    dnf clean all

# 2) Copy your working slapd.conf (with a single valid rootpw line)
COPY slapd.conf /etc/openldap/slapd.conf

# 3) Expose only the LDAP port
EXPOSE 389

# 4) Run slapd in static-config mode, binding only to 389
CMD ["slapd","-f","/etc/openldap/slapd.conf","-d","256","-h","ldap://0.0.0.0:389/"]
