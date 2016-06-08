#!/usr/bin/env bash

function InstallPrep {
	echo 'install random shit'
	sudo apt-get -qq update && sudo apt-get -qq upgrade -y && sudo apt-get -qq install -y opencl-headers build-essential protobuf-compiler libprotoc-dev libboost-all-dev libleveldb-dev hdf5-tools libhdf5-serial-dev libopencv-core-dev  libopencv-highgui-dev libsnappy-dev libsnappy1 libatlas-base-dev cmake libstdc++6-4.8-dbg libgoogle-glog0 libgoogle-glog-dev libgflags-dev liblmdb-dev git python-pip gfortran

	sudo apt-get -qq clean && sudo apt-get -qq install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`
}

function InstallCuda {
	echo 'install cuda'
	wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb
	sudo dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb
	sudo apt-get -qq update && sudo apt-get -qq install -y cuda
	sudo apt-get -qq clean
	rm cuda-repo-ubuntu1404_7.5-18_amd64.deb
	nvidia-smi
	echo 'update bash_profile'
	echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"' >> ~/.bash_profile
	echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bash_profile
}

function InstallCudnn {
	echo 'install cudnn'
	wget https://s3.amazonaws.com/tmp.poorhouselabs/cudnn-7.0-linux-x64-v4.0-prod.tgz
	tar xvzf cudnn-7.0-linux-x64-v4.0-prod.tgz
	sudo cp cuda/include/cudnn.h /usr/local/cuda/include
	sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64/
	sudo chmod a+r /usr/local/cuda/lib64/libcudnn*
	rm cudnn-7.0-linux-x64-v4.0-prod.tgz
	rm -rf cuda/
}

function InstallBazel {
	echo 'install bazel'
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get -qq update && sudo apt-get -qq install -y oracle-java8-installer
	echo "deb http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
	curl https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg | sudo apt-key add -
	sudo apt-get -qq update && sudo apt-get -qq install -y bazel
}

function InstallAnaconda {
	echo 'install anaconda'
	wget http://repo.continuum.io/archive/Anaconda2-4.0.0-Linux-x86_64.sh
	bash Anaconda2-4.0.0-Linux-x86_64.sh
	rm Anaconda2-4.0.0-Linux-x86_64.sh
	echo 'export PATH="/home/ubuntu/anaconda2/bin:$PATH"' >> ~/.bash_profile
}

function SetupDataVolume {
	echo 'setup working volume'
	sudo mkdir -p /mnt/working
	sudo chown ubuntu /mnt/working
	ln -s /mnt/working ~/working
}

function GitClone {
	echo 'git clones'
	git config --global credential.helper 'cache --timeout=2600000'
	cd ~
	git clone https://github.com/HighWestLabsInc/distracted.git
	git clone --recurse-submodules https://github.com/jhale-hwl/models.git
}

function CreateCondaEnv {	
	echo 'create conda env'
	~/anaconda2/bin/conda create -n tensorflow python=2.7	
	echo 'please run ". ~/.bash_profile"'
	echo 'Please run "source activate tensorflow"'
}

function InstallTensorflow {
	echo 'install tensorflow via pip'
	pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl
}

function AddEc2EnvVar {
	echo 'export RUNNING_ON_EC2=True' >> ~/.bash_profile
	echo 'please run ". ~/.bash_profile"'
}

case "$1" in
	InstallPrep)
		InstallPrep
		;;
	InstallCuda)
		InstallCuda
		;;
	InstallCudnn)
		InstallCudnn
		;;
	InstallBazel)
		InstallBazel
		;;
	InstallAnaconda)
		InstallAnaconda
		;;
	SetupDataVolume)
		SetupDataVolume
		;;
	GitClone)
		GitClone
		;;
	CreateCondaEnv)
		CreateCondaEnv
		;;
	InstallTensorflow)
		InstallTensorflow
		;;
	part1)
		InstallPrep
		InstallCuda
		InstallCudnn
		InstallBazel
		InstallAnaconda
		SetupDataVolume
		GitClone
		CreateCondaEnv
		;;
	part2)
		InstallTensorflow
		AddEc2EnvVar
		;;
	*)
		echo 'Use ami-d05e75b8'
		echo $"Usage: $0 {part1|part2}"
		exit 1
esac
