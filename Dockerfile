# The official AniCraft source is compiled into build-context/web by GitHub Actions.
FROM nginxinc/nginx-unprivileged:stable-alpine

COPY --chown=101:101 nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=101:101 web/ /usr/share/nginx/html/

EXPOSE 8080
