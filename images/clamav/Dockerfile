FROM --platform=$TARGETPLATFORM clamav/clamav-debian:1.3

COPY "./images/clamav/scripts/unprivileged-entrypoint.sh" "/unpriv-init"

RUN sed -i 's/^LogFile .*/LogFile \/dev\/stdout/' /etc/clamav/clamd.conf && \
    sed -i 's/^LogFile .*/LogFile \/dev\/stdout/' /etc/clamav/clamav-milter.conf && \
    sed -i 's/^UpdateLogFile .*/UpdateLogFile \/dev\/stdout/' /etc/clamav/freshclam.conf

RUN chown -R clamav:clamav /var/lib/clamav /unpriv-init

USER clamav
HEALTHCHECK --start-period=6m CMD clamdcheck.sh
ENTRYPOINT [ "/unpriv-init" ]
