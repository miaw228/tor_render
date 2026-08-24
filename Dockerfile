FROM nginx:alpine

RUN apk add --no-cache tor bash

RUN mkdir -p /var/lib/tor/hidden_service /var/log/tor /usr/share/nginx/html
COPY app/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN chmod 700 /var/lib/tor/hidden_service && \
    chown -R root:root /var/lib/tor/hidden_service

#COPY hidden_service_keys/ /var/lib/tor/hidden_service/

COPY torrc /etc/tor/torrc

COPY start.sh /start.sh
RUN chmod +x /start.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
    CMD wget -qO- http://localhost/health || exit 1

EXPOSE 80

CMD ["/start.sh"]