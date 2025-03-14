cd
RUNNER_WORKSPACE=$(pwd)
GITHUB_WORKSPACE=${RUNNER_WORKSPACE}/xrootd-s3-http
rm -rf ${RUNNER_WORKSPACE}/build/
export BUILD_TYPE="Debug"
cmake -E make_directory ${RUNNER_WORKSPACE}/build
cd ${RUNNER_WORKSPACE}/build
cmake ${GITHUB_WORKSPACE} -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DBUILD_TESTING=yes
cmake --build . --config $BUILD_TYPE -j 8
ctest -C $BUILD_TYPE -E "xmltest" --verbose
cd ${RUNNER_WORKSPACE}
