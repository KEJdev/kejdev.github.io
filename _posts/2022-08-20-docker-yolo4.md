---
layout: post
title : Docker와 YOLOv4 사용하기
date: 2022-08-20 10:00:00 +0300
category: MachineLearning
---
 

Docker환경에서 YOLOv4를 학습시키려고 한다.  
GPU로 돌릴 예정이기 때문에 Docker Hub에서 [Nvidia CUDA](https://hub.docker.com/r/nvidia/cuda) 이미지를 사용했다.  


```
docker pull nvidia/cuda:11.6.0-cudnn8-devel-ubuntu20.04
```

버전은 각자 컴퓨터 사양에 맞게 하면 되는데 나는 11.6 버전으로 진행하였다. 해당 이미지는 cudnn까지 설치되어 있어서 따로 cudnn까지 설치는 하지 않아도 된다.     

![yolo1](/public/img/yolo1.png){: .center}


이미지를 실행 시킬때 `--runtime=nvidia` 라던가 `--gpus` 옵션을 사용하지 않는다면 cpu로 돌아가니 주의하자. 

```
docker run -it --gpus all -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --privileged nvidia/cuda:11.6.0-cudnn8-devel-ubuntu20.04
```

나는 Docker에서 yolo를 돌리면서 이미지나 그래프를 확인하고 싶어서 내 화면에 띄우기 위해 DISPLAY 옵션을 넣었다. 나처럼 도커에서 실행한 이미지결과를 확인하고 싶다면 
[Xming X Server for Windows](https://sourceforge.net/projects/xming/)를 설치, 도커 실행 후 `apt-get install x11-apps` 와 `export DISPLAY=WINDOWS_IP:0.0` 를 꼭 해줘야 한다. 

이미지 실행 후 `nvidia-smi` 와 `nvcc -V`으로 CUDA가 잘 잡히는지 확인하자. 

![yolo2](/public/img/yolo2.png){: .center}

참고로 `nvidia-smi` 에서 보이는 CUDA Version의 경우에는 현재 driver와 호환이 잘되는 CUDA버전을 추천해주는 것이지 현재의 CUDA 버전을 이야기하는 것은 아니다. 그래서 `nvcc -V`로 현재의 버전을 보면 된다.  

이제 yolo를 사용하기 위해 아래와 같이 [Git clone](https://github.com/AlexeyAB/darknet) 받자

```
apt-get update
apt install git
apt install vim
apt install wget
sudo apt-get install libopencv-dev # opencv=0으로 할꺼면 빼도 된다.
git clone https://github.com/AlexeyAB/darknet.git
```

아래와 같이 파일이 들어와 있다면 잘 된 것이다

![yolo3](/public/img/yolo3.png){: .center}

우선 Makefile을 아래와 수정하자.  

![yolo4](/public/img/yolo4.png){: .center}

그리고 `make` 를 입력하면 아래와 같이 `darknet` 파일이 생기는 것을 볼 수 있다. 

![yolo5](/public/img/yolo5.png){: .center}

가중치 파일을 다운 받아야하는데 나는 `yolov4.conv.137` 를 사용하였다. 

```
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
```

![yolo6](/public/img/yolo6.png){: .center}

```
./darknet detector train cfg/coco.data cfg/yolov4.cfg yolov4.conv.137
```

vi로 coco.data 경로 맞춰주고 일부 수정한다면 아래와 같이 돌아가는 모습을 볼 수 있다. 


![yolo7](/public/img/yolo7.png){: .center}


만약 학습말고 기존의 가중치로 결과를 확인하고 싶다면 아래와 같이 명령어를 입력하면 확인할 수 있다. 

```
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights
./darknet detect cfg/yolov4.cfg yolov4.weights data/dog.jpg
```

![yolo9](/public/img/yolo9.png){: .center}

도커에서 실행한 이미지를 내 컴퓨터로 띄어서 확인할 수 있다. 

![yolo8](/public/img/yolo8.png){: .center}