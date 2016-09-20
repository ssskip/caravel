FROM amancevice/pandas:0.18.1-python3
MAINTAINER smallweirdnum@gmail.com

# Install
RUN apk add --no-cache \
        curl \
        g++ \
        libffi-dev \
        mariadb-dev \
        postgresql-dev \
        cyrus-sasl-dev \
        git \
        nodejs && \
    pip3 install \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        sqlalchemy-redshift==0.5.0 && \
    git clone https://github.com/airbnb/caravel.git && \
    cd caravel/caravel/assets && \
    npm install && \
    npm run prod && \
    cd ../.. && \
    python3 setup.py install

# Default config
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=$PATH:/home/caravel/.bin \
    PYTHONPATH=/home/caravel:$PYTHONPATH

# Run as caravel user
WORKDIR /home/caravel
COPY caravel .
RUN addgroup caravel && \
    adduser -h /home/caravel -G caravel -D caravel && \
    mkdir /home/caravel/db && \
    chown -R caravel:caravel /home/caravel
USER caravel

# Deploy
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["caravel"]
CMD ["runserver"]
