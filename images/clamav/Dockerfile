FROM --platform=$TARGETPLATFORM clamav/clamav-debian:1.3

COPY "./images/clamav/scripts/unprivileged-entrypoint.sh" "/unpriv-init"

RUN chown -R clamav:clamav /var/lib/clamav /unpriv-init

USER clamav
HEALTHCHECK --start-period=6m CMD clamdcheck.sh
ENTRYPOINT [ "/unpriv-init" ]
