---
layout: post
title: 논문 리뷰 - Faster RCNN
date: 2024-01-08 00:00:00 +0000
category : Paper
---

Paper URL : [https://arxiv.org/pdf/1506.01497.pdf](https://arxiv.org/pdf/1506.01497.pdf)

## Faster RCNN 이 나오게 된 배경

Fast RCNN은 이전에 있던 RCNN보다 효율적인 객체탐지를 제공했지만, Selective Search를 사용하기 때문에 아직까지 병목 현상을 일으키고 있고 시간이 많이 소요되는 문제가 있었다. 객체 탐지의 속도와 효율성을 더욱 개선하기 위해 객체 후보 영역 추출 작업을 수행하는 과정을 네트워크 내부에 통합할 필요가 있었다. 

## Faster RCNN 목표와 가설  

* 목표 : Region Proposal Network(RPN)을 사용하여 후보 영역 추출을 신경망 내부에 통합하여 속도와 효율성을 향상 시키고, end-to-end로 인하여 더 빠르고 정확하게 객체 탐지할 수 있다. 

* 가설 : Region Proposal Network(RPN)를 도입해서 후보 영역을 추출하는 과정을 신경망 내부에 통합하고, 전체 객체 탐지 과정의 효율성과 속도를 개선할 수 있다. 또한 RPN과 Fast RCNN을 결합한 하나의 네트워크로 전체 과정을 end-to-end로 학습하여 후보 영역 추출과 객체 탐지 성능을 동시에 향상 시킬 수 있을 것이다.

## Faster RCNN  

Faster RCNN의 아키텍처는 아래와 같다. 

<img src="/public/img/FasterRCNN.png" alt="FasterRCNN" width="300" height="450">


* 전체 이미지를 Convolutional Neural Network(CNN)에 통과시켜 feature map을 생성한다.  
* 생성된 feature map은 Region Proposal Network(RPN)으로 전달된다. RPN은 여러 크기와 비율을 가진 anchor boxes를 사용하여 후보 영역을 추출한다. 

    <aside>
    <span class="icon">🥕</span> 
    <div class="content">
        <p> Region Proposal Network(RPN)은 입력 이미지로부터 feature map을 추출하고, 해당 feature map을 활용하여 객체가 존재할 가능성이 있는 영역, 즉 region proposals을 생성하는 것을 말한다. 이 과정에서 RPN은 각 위치에 sliding window(보통 3x3 크기)를 적용하여 해당 위치에서 객체를 예측한다.</p>
    </div>
    </aside>


* RPN이 추출한 후보 영역에서 각 anchor box에 대해 객체일 가능성을 점수화하고, 이 점수가 높은 object proposals를 선택한다.

    <aside>
    <span class="icon">🥕</span> 
    <div class="content">
        <p>Anchor boxes는 Faster R-CNN 내의 Region Proposal Network(RPN)에서 사용되는, 미리 정의된 고정된 비율과 크기를 가진 사각형들이다.  다양한 형태와 크기의 실제 객체를 감지하기 위한 기준점으로 사용된다. RPN은 이 anchor boxes를 기반으로 각 위치에서 객체가 있을 것으로 예상되는 영역(proposals)에 대한 점수를 계산하고, 후보 영역을 추출한다.</p>
    </div>
    </aside>

* 선택된 object proposals에 대해 RoI Pooling을 수행하여 각각의 후보 영역에 대해 고정된 크기의 feature vector를 얻는다.
* RoI Pooling으로 얻은 feature vector는 fully connected layers로 전달되어 최종적으로 classification과 bounding box regression을 수행하여 객체의 종류와 위치를 결정한다. 

## faster RCNN 결론 

Region Proposal Network(RPN)를 도입함으로써 후보 영역 추출 과정을 네트워크에 통합하였고, 객체 탐지 속도를 크기 향상시켰고 end-to-end 학습이 가능해졌다. 



