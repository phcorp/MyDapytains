FROM python:3.13.5-bookworm

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        curl \
        make \
        zsh \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY . /app

WORKDIR /app

RUN make install

ENTRYPOINT exec python -m dapytains.app.app
