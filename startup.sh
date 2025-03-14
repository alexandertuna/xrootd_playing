# docker run -it -v .:/data/ ubuntu /bin/bash
export NB_USER="jovyan"
export NB_UID="1001"

# export TZ=Etc/UTC
export DEBIAN_FRONTEND=noninteractive
export CC="gcc"
export CMAKE_VERBOSE_MAKEFILE="true"
export CTEST_OUTPUT_ON_FAILURE="true"
export CMAKE_ARGS='-DINSTALL_PYTHON_BINDINGS=0;-DUSE_SYSTEM_ISAL=1;-DCMAKE_INSTALL_PREFIX=/usr'

time apt update -qq
time apt install -qq -y build-essential devscripts equivs git cmake sudo golang-go

useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
usermod -aG sudo ${NB_USER}

echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${NB_USER}
sudo chmod 440 /etc/sudoers.d/${NB_USER}

cd /home/${NB_USER}

# exec su ${NB_USER}
su ${NB_USER}

