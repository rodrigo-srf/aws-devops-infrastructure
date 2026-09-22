FROM nginxinc/nginx-unprivileged:1.29-alpine

COPY --chown=101:101 app/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=101:101 app/index.html /usr/share/nginx/html/index.html

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health || exit 1
