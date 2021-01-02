#! /bin/bash
set -ex
# Determine versions
ARCH="$(uname -m)"
RELEASE="$(uname -r)"
UPSTREAM="${RELEASE%%-*}"
LOCAL="${RELEASE#*-}"

# Get kernel sources
mkdir -p /usr/src;
wget -O "/usr/src/linux-${UPSTREAM}.tar.xz" "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${UPSTREAM}.tar.xz"
tar xf "/usr/src/linux-${UPSTREAM}.tar.xz" -C /usr/src/ && rm "/usr/src/linux-${UPSTREAM}.tar.xz"
ln -fns "/usr/src/linux-${UPSTREAM}" /usr/src/linux
ln -fns "/usr/src/linux-${UPSTREAM}" /lib/modules/${RELEASE}/build

# Install minimum requirements
(
    set +x
    apt update && \
	apt install --no-install-recommends -yq \
	    libssl-dev \
	    build-essential \
	    flex \
	    bison;
)

# Prepare kernel
(
    set +e
    zcat /proc/config.gz > /usr/src/linux/.config
    printf 'CONFIG_LOCALVERSION="%s"\nCONFIG_CROSS_COMPILE=""\n' "${LOCAL:+-$LOCAL}" >> /usr/src/linux/.config
    wget -O /usr/src/linux/Module.symvers "http://mirror.scaleway.com/kernel/${ARCH}/${RELEASE}/Module.symvers"
    make -C /usr/src/linux prepare modules_prepare
)

echo "All done."
