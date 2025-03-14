# cd 
# git clone https://github.com/PelicanPlatform/xrootd-s3-http.git

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
