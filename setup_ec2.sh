#!/usr/bin/env bash

function InstallPrep {
	echo 'install random shit'
	sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y opencl-headers build-essential protobuf-compiler libprotoc-dev libboost-all-dev libleveldb-dev hdf5-tools libhdf5-serial-dev libopencv-core-dev  libopencv-highgui-dev libsnappy-dev libsnappy1 libatlas-base-dev cmake libstdc++6-4.8-dbg libgoogle-glog0 libgoogle-glog-dev libgflags-dev liblmdb-dev git python-pip gfortran

	sudo apt-get clean && sudo apt-get install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`
}

function InstallCuda {
	echo 'install cuda'
	wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb
	sudo dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb
	sudo apt-get update && sudo apt-get install -y cuda
	sudo apt-get clean
	rm cuda-repo-ubuntu1404_7.5-18_amd64.deb
	nvidia-smi
	echo 'update bash_profile'
	echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"' >> ~/.bash_profile
	echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bash_profile
	. ~/.bash_profile
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
	sudo apt-get update && sudo apt-get install -y oracle-java8-installer
	echo "deb http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
	curl https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg | sudo apt-key add -
	sudo apt-get update && sudo apt-get install -y bazel
}

function InstallAnaconda {
	echo 'install anaconda'
	wget http://repo.continuum.io/archive/Anaconda2-4.0.0-Linux-x86_64.sh
	bash Anaconda2-4.0.0-Linux-x86_64.sh
	. ~/.bashrc
	rm Anaconda2-4.0.0-Linux-x86_64.sh
}

function SetupDataVolume {
	echo 'add data volume'
	lsblk
	sudo file -s /dev/xvdf
	sudo mkfs -t ext4 /dev/xvdf
	sudo cp /etc/fstab /etc/fstab.orig
	mkdir -p /home/ubuntu/data
	echo '/dev/xvdf       /home/ubuntu/data   ext4    defaults,nofail        0       2' | sudo tee --append /etc/fstab
	sudo mount -a && sleep 1
	sudo chown ubuntu data
}

function GitClone {
	echo 'git clones'
	git config --global credential.helper 'cache --timeout=2600000'
	cd ~/data
	git clone https://github.com/HighWestLabsInc/distracted.git
	git clone --recurse-submodules https://github.com/jhale-hwl/models.git
	git clone --recurse-submodules https://github.com/tensorflow/tensorflow.git
}

function CreateCondaEnv {	
	echo 'create conda env'
	conda create -n tensorflow python=2.7	
	source activate tensorflow
}

function InstallTensorflow {
	echo 'install tensorflow via pip'
	pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl
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
		;;
	*)
		echo 'Use ami-d05e75b8'
		echo $"Usage: $0 {part1|part2}"
		exit 1
esac