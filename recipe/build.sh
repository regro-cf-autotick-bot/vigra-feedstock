#!/bin/bash

EXTRA_CMAKE_ARGS=""
if [[ `uname` == 'Darwin' ]];
then
    EXTRA_CMAKE_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}"
else
    export CXXFLAGS="-pthread ${CXXFLAGS}"
fi
export EXTRA_CMAKE_ARGS

export CXXFLAGS="${CXXFLAGS} -std=c++11"

# In release mode, we use -O2 because gcc is known to miscompile certain vigra functionality at the O3 level.
# (This is probably due to inappropriate use of undefined behavior in vigra itself.)
export CXXFLAGS_RELEASE="-O2 -DNDEBUG ${CXXFLAGS}"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

# Configure
mkdir build
cd build
cmake ..\
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        -DCMAKE_CXX_LINK_FLAGS="${LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DCMAKE_CXX_FLAGS_RELEASE="${CXXFLAGS_RELEASE}" \
        -DCMAKE_CXX_FLAGS_DEBUG="${CXXFLAGS}" \
\
        -DWITH_VIGRANUMPY=TRUE \
        -DWITH_BOOST_THREAD=1 \
        -DDEPENDENCY_SEARCH_PREFIX=${PREFIX} \
\
        -DFFTW3F_INCLUDE_DIR=${PREFIX}/include \
        -DFFTW3F_LIBRARY=${PREFIX}/lib/libfftw3f${SHLIB_EXT} \
        -DFFTW3_INCLUDE_DIR=${PREFIX}/include \
        -DFFTW3_LIBRARY=${PREFIX}/lib/libfftw3${SHLIB_EXT} \
\
        -DHDF5_CORE_LIBRARY=${PREFIX}/lib/libhdf5${SHLIB_EXT} \
        -DHDF5_HL_LIBRARY=${PREFIX}/lib/libhdf5_hl${SHLIB_EXT} \
        -DHDF5_INCLUDE_DIR=${PREFIX}/include \
\
        -DBoost_INCLUDE_DIR=${PREFIX}/include \
        -DBoost_LIBRARY_DIRS=${PREFIX}/lib \
        -DBoost_PYTHON_LIBRARY=${PREFIX}/lib/libboost_python${CONDA_PY}${SHLIB_EXT} \
\
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_INCLUDE_PATH=${PREFIX}/include \
\
        -DZLIB_INCLUDE_DIR=${PREFIX}/include \
        -DZLIB_LIBRARY=${PREFIX}/lib/libz${SHLIB_EXT} \
\
        -DPNG_LIBRARY=${PREFIX}/lib/libpng${SHLIB_EXT} \
        -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
\
        -DTIFF_LIBRARY=${PREFIX}/lib/libtiff${SHLIB_EXT} \
        -DTIFF_INCLUDE_DIR=${PREFIX}/include \
\
        -DJPEG_INCLUDE_DIR=${PREFIX}/include \
        -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg${SHLIB_EXT} \
        ${EXTRA_CMAKE_ARGS}

make -j${CPU_COUNT}
# Can't run tests due to a bug in the clang compiler provided with XCode.
# For more details see here ( https://llvm.org/bugs/show_bug.cgi?id=21083 ).
# Also, these tests are very intensive, which makes them challenging to run in CI.
#eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make check_python
make install
