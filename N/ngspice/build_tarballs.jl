# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "ngspice"
version = v"32.2.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/imr/ngspice.git", "5c3e2b6526b22015ddec692450f5c5077efa1d80"),
    DirectorySource("./bundled")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
for f in ${WORKSPACE}/srcdir/patches/*.patch; do
    atomic_patch -p1 ${f}
done
cd ngspice/
./autogen.sh
./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux i686 {libc=glibc},
    Linux x86_64 {libc=glibc},
    Linux aarch64 {libc=glibc},
    Linux armv7l {call_abi=eabihf, libc=glibc},
    Linux powerpc64le {libc=glibc},
    Linux i686 {libc=musl},
    Linux x86_64 {libc=musl},
    Linux aarch64 {libc=musl},
    Linux armv7l {call_abi=eabihf, libc=musl},
    FreeBSD x86_64
]


# The products that we will ensure are always built
products = [
    ExecutableProduct("ngspice", :ngspice)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
