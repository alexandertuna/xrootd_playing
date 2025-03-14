git clone https://github.com/xrootd/xrootd.git
cd xrootd

mk-build-deps --install --remove -s sudo debian/control <<< yes

env CC=${CC} CXX=${CC/g*/g++} ctest -VV -S test.cmake

sudo cmake --install build

sudo python3 -m pip install --target /usr/lib/python3/dist-packages --use-pep517 --verbose build/bindings/python

tests/post-install.sh
tests/check-headers.sh
