FROM nginx
RUN apt-get update -qq && apt-get -y install apache2-utils

WORKDIR /app

RUN mkdir log
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
