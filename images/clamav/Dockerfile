FROM clamav/clamav-debian:1.2

COPY "./images/clamav/scripts/unprivileged-entrypoint.sh" "/unpriv-init"

RUN chown -R clamav:clamav /var/lib/clamav
RUN chown -R clamav:clamav /unpriv-init

USER clamav

HEALTHCHECK --start-period=6m CMD clamdcheck.sh

ENTRYPOINT [ "/unpriv-init" ]
