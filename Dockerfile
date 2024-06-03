ARG PREFIX="/neovim"
ARG NEOVIM_RELEASE="0.10.0"
ARG CMAKE_RELEASE="3.29.3"

FROM alpine:3.20.0 AS base
RUN addgroup -S neovim-users \
  && adduser -S neovim -G neovim-users \
  && mkdir /neovim && chown -R neovim:neovim-users /neovim && chmod g+s /neovim
WORKDIR /neovim
USER neovim

FROM base AS build-deps
USER root
RUN apk add cmake git zsh jq build-base coreutils curl unzip gettext-tiny-dev
WORKDIR /neovim
USER neovim

FROM build-deps AS neovim
RUN git clone --depth=1 https://github.com/neovim/neovim /tmp/neovim \
  && (cd /tmp/neovim; git fetch --all --tags --prune;) \
  && (cd /tmp/neovim; git checkout tags/v0.10.0;) \
  && (cd /tmp/neovim; make CMAKE_INSTALL_PREFIX=/neovim CMAKE_BUILD_TYPE=Release install;)
  && (cd /tmp/neovim; ls neovim;)

FROM base AS final
USER neovim
WORKDIR /neovim
RUN ls $(pwd); ls /tmp/neovim
COPY --from=neovim /neovim .
CMD [ "/bin/ash" ]
