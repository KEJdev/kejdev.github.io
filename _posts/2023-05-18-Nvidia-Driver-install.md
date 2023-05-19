---
layout: post
title: nvidia- smi has failed because it couldn't communicate with the nvidia driver 해결, nvidia driver 재설치
date: 2023-05-18 09:00:00 +0300
category : ETC
---


무슨 이유인지 회사 AI 서버 중 하나가 nvidia-smi 안된다고 해서 내가 nvidia driver 잡는거 시도해보고 안되면 재설치하겠다고 이야기 하고 빠르게 진행했다.


## 1. install Nvidia-Driver

```
1. Install Nvidia driver
apt search nvidia-driver*
sudo apt-get purge "nvidia*" 
ubuntu-drivers devices

1. 지정된 드라이버를 설치하고 싶을 경우
sudo apt install [driver_name]

2. 추천되는 드라이버를 설치하고 싶을 경우
sudo ubuntu-drivers autoinstall

sudo reboot
```

이렇게 하고 보통 `nvidia-smi` 하면 나와야 하는데, 아래와 같은 에러가 발생 했다.

### 1.1 **couldn't communicate with the NVIDIA driver**

찾아보니, 딥러닝 작업을 종료하지 않은채로 서버의 전원을 내리거나 시스템 종료하는 경우에 오류가 많이 발생한다고 하는데, 이상하네…다 확인을 했는데..ㅠㅠ

```
apt --installed list | grep nvidia-driver
sudo apt remove nvidia-driver-<설치된 버전> # 나의 경우 530 버전
sudo apt autoremove
sudo apt-get install nvidia-driver-<설치된 버전> 
sudo reboot now
nvidia-smi 
```

근데도 안되네…

### 1.2 Nvidia Docs를 참고하자.

이럴땐 그냥 깔끔하게 [정식 문서](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html) 보고 설치하자. 

```
wget https://download.nvidia.com/XFree86/Linux-x86_64/530.30.02/NVIDIA-Linux-x86_64-530.30.02.run
sudo apt-get install linux-headers-$(uname -r)
sudo sh NVIDIA-Linux-x86_64-530.30.02.run
nvidia-smi 

+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 530.30.02              Driver Version: 530.30.02    CUDA Version: 12.1     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                  Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf            Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA RTX A6000                Off| 00000000:3B:00.0 Off |                  Off |
| 30%   58C    P8                9W / 300W|      1MiB / 49140MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
|   1  NVIDIA RTX A6000                Off| 00000000:5E:00.0 Off |                  Off |
| 30%   54C    P8                8W / 300W|      1MiB / 49140MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
|   2  NVIDIA RTX A6000                Off| 00000000:86:00.0 Off |                  Off |
| 30%   46C    P8                7W / 300W|      1MiB / 49140MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
|   3  NVIDIA RTX A6000                Off| 00000000:AF:00.0 Off |                  Off |
| 30%   57C    P8               23W / 300W|      1MiB / 49140MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|  No running processes found                                                           |
```

이제 잘 잡히니까 CUDA 설치까지 마무리하자

## 2. Install Nvidia CUDA Driver, cuDNN

```
sudo sh cuda_11.6.0_510.39.01_linux.run # CUDA
sudo dpkg -i cuda-repo-ubuntu2004-11-6-local_11.6.2-510.47.03-1_amd64.deb # cuDNN 

export PATH=/usr/local/cuda-11.6/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64:$LD_LIBRARY_PATH
source ~/.bashrc
```

끝! 

