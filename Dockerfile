FROM baseimage

MAINTAINER Nicos Maris <nicosmaris@>

ARG username
ARG userid
ARG givencommit

ENV COMMIT $GIVENCOMMIT
ENV DEBIAN_FRONTEND noninteractive
ENV APP_HOME /app

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y curl gnupg && \
curl -sL https://deb.nodesource.com/setup_nodejsversion | bash -  && \
apt-get install -y nodejs  && \
nodejs -v  && \
npm -v

# Install latest chrome dev package
# Note: this also installs the necessary libs so we don't need the dependencies
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y $(apt-cache depends google-chrome-unstable | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ') \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

WORKDIR $APP_HOME

RUN useradd --no-create-home --user-group --shell /bin/bash --home-dir $APP_HOME --uid $userid $username
RUN chown -R $username: $APP_HOME

# Run user as non privileged.
USER $username

# Uncomment to skip the chromium download when installing puppeteer.
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

COPY package.json /tmp
RUN cd /tmp \
    && npm install  \
    && cd $APP_HOME \
    && ln -s /tmp/node_modules

CMD ["bash", "entrypoint.sh"]
