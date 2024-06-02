ARG PREFIX_DEFAULT="/neovim"
ARG TMPDIR_DEFAULT="/tmp"
ARG NEOVIM_RELEASE_DEFAULT="0.10.0"
ARG CMAKE_RELEASE_DEFAULT="3.29.3"

FROM alpine:3.20.0 AS base
ARG PREFIX=$PREFIX_DEFAULT
ARG TMPDIR=$TMPDIR_DEFAULT
ARG NEOVIM_RELEASE=$NEOVIM_RELEASE_DEFAULT
ARG CMAKE_RELEASE=$CMAKE_RELEASE_DEFAULT
RUN addgroup -S neovim-users \
  && adduser -S neovim -G neovim-users \
  && mkdir /neovim && chown -R neovim:neovim-users /neovim && chmod g+s /neovim \
  && mkdir /o0 && chown -R neovim:neovim-users /o0 && chmod g+s /o0
WORKDIR /o0
USER neovim

FROM base AS build-deps
USER root
RUN apk update && apk add git zsh jq build-base coreutils curl unzip gettext-tiny-dev

FROM build-deps AS cmake
ENV CMAKE_INSTALL_FILE=v$CMAKE_RELEASE/cmake-$CMAKE_RELEASE-linux-x86_64.sh
ENV CMAKE_INSTALL_URL=https://github.com/Kitware/CMake/releases/download/$CMAKE_INSTALL_FILE
RUN curl -sSLvo $TMPDIR/cmake-install.sh $CMAKE_INSTALL_URL \
  && chmod a+x $TMPDIR/cmake-install.sh \
  && $TMPDIR/cmake-install.sh  \
  --skip-license --prefix=$PREFIX \
  && rm $TMPDIR/cmake-install.sh

FROM build-deps AS neovim
ARG PREFIX=$PREFIX_DEFAULT
ARG TMPDIR=$TMPDIR_DEFAULT
ARG NEOVIM_RELEASE=$NEOVIM_RELEASE_DEFAULT
COPY --from=cmake $PREFIX . 
RUN git clone --depth=1 https://github.com/neovim/neovim $TMPDIR/neovim \
  && cd $TMPDIR/neovim \
  && git fetch --all --tags --prune \
  && git checkout tags/v$NEOVIM_RELEASE \
  && make CMAKE_INSTALL_PREFIX=$PREFIX CMAKE_BUILD_TYPE=Release install \
  && rm -rf $TMPDIR/neovim

FROM base AS final
ARG PREFIX=$PREFIX_DEFAULT
COPY --from=neovim $PREFIX . 
WORKDIR "$PREFIX"
USER neovim
CMD [ "$PREFIX/bin/nvim" ]
