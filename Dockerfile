FROM alpine:3.16

RUN set -eux;             \
    mkdir /root/.ssh;     \
    chmod 700 /root/.ssh;

EXPOSE 22

VOLUME ["/sock-puppet"]

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]

RUN apk add --no-cache \
        gnupg          \
        openssh        \
        socat          \
        tini           \
    ;

COPY sshd_config /etc/ssh/sshd_config

COPY docker-entrypoint.sh /
COPY ssh-entrypoint.sh /
