# docker run -it -v .:/data/ ubuntu /bin/bash
export NB_USER="jovyan"
export NB_UID="1001"

export DEBIAN_FRONTEND=noninteractive
export CC="gcc"
export CMAKE_VERBOSE_MAKEFILE="true"
export CTEST_OUTPUT_ON_FAILURE="true"
export CMAKE_ARGS='-DINSTALL_PYTHON_BINDINGS=0;-DUSE_SYSTEM_ISAL=1;-DCMAKE_INSTALL_PREFIX=/usr'

# packages
time apt update -qq
time apt install -qq -y build-essential devscripts equivs git cmake sudo golang-go

# non-root user
useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
usermod -aG sudo ${NB_USER}

# sudo
echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${NB_USER}
sudo chmod 440 /etc/sudoers.d/${NB_USER}

# switch to user
cd /home/${NB_USER}
exec su ${NB_USER}

# recreate CI for xrootd
git clone https://github.com/xrootd/xrootd.git
cd xrootd
mk-build-deps --install --remove -s sudo debian/control <<< yes
env CC=${CC} CXX=${CC/g*/g++} ctest -VV -S test.cmake
sudo cmake --install build
sudo python3 -m pip install --target /usr/lib/python3/dist-packages --use-pep517 --verbose build/bindings/python
tests/post-install.sh
tests/check-headers.sh

# recreate CI for xrootd-s3-http
cd /home/${NB_USER}
git clone https://github.com/PelicanPlatform/xrootd-s3-http.git
RUNNER_WORKSPACE=$(pwd)
GITHUB_WORKSPACE=${RUNNER_WORKSPACE}/xrootd-s3-http
RELEASE="linux-arm64"
MINIO=/usr/bin/minio
if [ ! -e "${MINIO}" ]; then
    sudo curl -L https://dl.min.io/server/minio/release/${RELEASE}/minio -o ${MINIO}
    sudo chmod +x ${MINIO}
fi
MC=/usr/bin/mc
if [ ! -e "${MC}" ]; then
    sudo curl -L https://dl.min.io/client/mc/release/${RELEASE}/mc -o ${MC}
    sudo chmod +x ${MC}
fi
rm -rf ${RUNNER_WORKSPACE}/build/
export BUILD_TYPE="Debug"
cmake -E make_directory ${RUNNER_WORKSPACE}/build
cd ${RUNNER_WORKSPACE}/build
cmake ${GITHUB_WORKSPACE} -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DBUILD_TESTING=yes
cmake --build . --config $BUILD_TYPE -j 8
ctest -C $BUILD_TYPE --verbose
cd ${RUNNER_WORKSPACE}
