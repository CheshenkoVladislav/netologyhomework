services:

  reverse-proxy:
    image: haproxy:2.4
    restart: always
    networks:
      - backend
    ports:
    - "8080"
    - "1936"
    configs:
    - source: haproxy_config
      target: /usr/local/etc/haproxy/haproxy.cfg

  ingress-proxy:
    image: nginx:latest
    restart: always
    networks:
      - backend
    ports:
      - "8090:8090"
    configs:
      - source: nginx_default_config
        target: /etc/nginx/conf.d/default.conf
      - source: nginx_config
        target: /etc/nginx/nginx.conf

  web:
    image: cr.yandex/crpkkv7fp51quu546kd8/mainpy:latest
    restart: always
    env_file:
      - .env
    environment:
      DB_HOST: ${db_host}
      DB_USER: $${MYSQL_USER}
      DB_PASSWORD: $${MYSQL_PASSWORD}
      DB_NAME: $${MYSQL_DATABASE}
    networks:
      - backend
    ports:
      - "5000"

networks:
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

configs:
  haproxy_config:
    file: ./haproxy/reverse/haproxy.cfg
  nginx_config:
    file: ./nginx/ingress/nginx.conf
  nginx_default_config:
    file: ./nginx/ingress/default.conf