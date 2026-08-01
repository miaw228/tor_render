FROM python:3.11-slim

RUN apt-get update && \
    apt-get install -y tor && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app /var/lib/tor/hidden_service /var/log/tor
RUN echo "<h1>Hello from Tor Hidden Service!</h1>" > /app/index.html
WORKDIR /app

EXPOSE 80 9050 9051

#COPY hidden_service_keys/ /var/lib/tor/hidden_service/
RUN chmod 700 /var/lib/tor/hidden_service && \
    chown -R root:root /var/lib/tor/hidden_service

COPY torrc /etc/tor/torrc

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]