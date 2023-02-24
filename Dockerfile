FROM debian:bullseye-slim

RUN apt update && apt install -y --no-install-recommends cloud-init && apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENTRYPOINT [ "/usr/bin/cloud-init", "devel", "schema", "--config-file" ]
CMD [ "--help" ]
