---
layout: post
title: Python환경 OpenCV + CUDA Build 하기
date: 2022-10-03 08:00:00 +0300
category : ETC
use_math : true
---   
 

최근에 OpenCV Build 하면서 많이 헤맸는데, 이번 기회에 OpenCV빌드에 필요한 내용을 정리해볼까한다.  

### 준비사항 

1. OpenCV : [https://github.com/opencv/opencv](https://github.com/opencv/opencv)
2. OpenCV Contrib : [https://github.com/opencv/opencv_contrib](https://github.com/opencv/opencv_contrib)
3. CMake : [https://cmake.org/download/](https://cmake.org/download/)
4. Visual Studio 2019 : [https://learn.microsoft.com/ko-kr/visualstudio](https://learn.microsoft.com/ko-kr/visualstudio/releases/2019/release-notes) 


### 가상환경 구성 

```
# 가상환경 생성 
conda create --name 가상환경 이름 python=3.7

# 가상환경 활성화
conda activate 가상환경 이름

conda install numpy
```

✔ 체크 할 부분
- numpy 설치 후 잘 되는지 확인!
- cv2 있는지 확인 할 것. (cv2가 있으면 안됨)

![opencv](/public/img/opencv1.png)


### OpenCV & OpenCV contrib 

opencv와 opencv contrib를 zip 형태로 다운로드 후 C드라이브에 아래와 같이 풀자.

![opencv2](/public/img/opencv2.png)

저는 C드라이브 밑에 opencvgpu 라는 폴더에 다운 받은 폴더를 풀었고, build하고 생성되는 파일을 담기 위해 build 파일 하나 생성했다.  

그리고 선택 사항이지만, opencv contrib/modules안에 복붙 후 opencv/modules 안에 넣으면 CMake 빌드할때 따로 경로 설정을 안해도 된다. 

### CMake Build 

![opencv3](/public/img/opencv3.png)

CMake에 Where is the source code에는 아까 다운 받은 opencv 폴더 경로, 아래에는 build폴더를 넣는다. 

![opencv4](/public/img/opencv4.png)

그리고 Configure를 누르면 아래와 같이 창이 뜨면 아래와 같이 설정 후 Finish를 누른다. 

* WITH_CUDA = ON
* OPENCV_DNN_CUDA = ON
* ENABLE_FAST_MATH = ON
* INSTALL_PYTHON_EXAMPLES = ON

Configire 를 누른다. 

* WITH_CUDNN = ON
* WITH_CUBLAS = ON
* CUDA_FAST_MATH = ON

CUDA ARCH BIN은 [https://en.wikipedia.org/wiki/CUDA](https://en.wikipedia.org/wiki/CUDA)에서 자신의 그래픽에 맞늦
번호를 찾으면 된다. 나의 경우는 3060 그래픽이기 때문에 8.6으로 했다. 

* CUDA_ARCH_BIN = 8.6

아래 경로는 아까 생성했던 가상환경을 아래처럼 넣어준다. 

* PYTHON3_EXECUTABLE = C:/Users/ejkim/anaconda3/envs/opencv_gpu/python.exe
* PYTHON3_INCLUDE_DIR = C:/Users/ejkim/anaconda3/envs/opencv_gpu/include
* PYTHON3_LIBRARY = C:/Users/ejkim/anaconda3/envs/opencv_gpu/libs/python37.lib
* PYTHON3_LIBRARY_DEBUG = C:/Users/ejkim/anaconda3/envs/opencv_gpu/libs/python37.lib
* PYTHON3_NUMPY_INCLUDE_DIRS = C:/Users/ejkim/anaconda3/envs/opencv_gpu/Lib/site-packages/numpy/core/include
* PYTHON3_PACKAGES_PATH = C:/Users/ejkim/anaconda3/envs/opencv_gpu/Lib/site-packages  
* BUILD_opencv_world = ON 
* OPENCV_ENABLE_NONFREE = ON
* BUILD_WITH_STATIC_CRT = OFF
* CPU_DISPATCH = 공백

Configire 누른 후 Generate를 누른다. 

![opencv5](/public/img/opencv5.png)

그럼 이렇게 build 폴더에 여러 파일이 생성되는데 여기서 OpenCV.sin을 눌러 Visual Studio 2019를 연다. 

![opencv6](/public/img/opencv6.png)

Release, x64로 설정하고 ALL_BUILD에서 빌드를 누른다. 

![opencv7](/public/img/opencv7.png)

빌드 끝나면, 다시 INSTALL 우클릭 후 빌드 눌러서 빌드 한다. 

![opencv8](/public/img/opencv8.png)


빌드가 끝나면 아래와 같은 경로에 폴더가 생긴다. 

![opencv12](/public/img/opencv12.png)

빌드가 잘된 것을 확인 했으니, 아래와 같이 경로를 잡아준다. 

![opencv10](/public/img/opencv10.png) 

시스템 변수로 위와 같이 잡아주고, Path에 `%OPENCV_DIR%\x64\vc16\bin` 를 적어 넣어준다. 

![opencv11](/public/img/opencv11.png) 

그리고 `cv2.cuda.getCudaEnabledDeviceCount()` 로 GPU가 잡히는지 확인하면 끝! 
나는 그래픽 카드가 1개 설치되어 있어서 1이 나온다.


아 그리고, 
하다가 중간에 `ImportError: OpenCV loader: missing configuration file: ['config-3.7.py', 'config-3.py']` 와 같은 에러를 만약 보게 된다면, 파이썬 버전을 확인해보자.  


나의 경우에는 가상환경 생성 시에 Python 3.7로 생성했는데, 실제 빌드하고 나니까 아래와 같이 파이썬 3.9로 빌드되어 있었다. 

![opencv9](/public/img/opencv9.png)

이때 해결법은 두가지인데, 첫번째는 다시 밀고 처음부터 빌드하거나 두번째는 파이썬 3.9로 빌드되어 있으니, 가상환경 파이썬 버전도 3.9로 맞춰준다.

나는 두가지 다 해봤는데, 첫번째의 경우에는 밀고 다시 처음부터를 3번정도 반복하니까.... 잘되었고, 다른 컴퓨터에 다시 빌드 했을 때는 그냥 귀찮아서 파이썬 버전을 맞춰주니 금방 끝났다. 

가상환경 파이썬 버전을 다시 맞출 때는 `conda install python==3.9` 라고 하면 끝난다. 

그리고, 혹시나 빌드 후에 cv2파일이 생성되지 않았다면, CMake 빌드를 위 순서대로 해야 제대로 생성된다. 