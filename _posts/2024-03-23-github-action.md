---
layout: post
title: Github Action 이란?
date: 2024-03-23 09:00:00 +0300
category: ETC
---

## Github Action

Github Action은 소프트웨어 개발 워크플로우를 자동화할 수 있는 CI/CD(지속적 통합 및 지속적 배포) 플랫폼이다. Github Repository에 대한 여러 이벤트(예를 들어 푸시, 풀 리퀘스트, 이슈 생성 등)에 따라 자동으로 작업을 실행할 수 있다. 빌드, 테스트, 배포 등의 과정을 자동화하여 개발 효율성을 높일 수 있다.

<br>  

**1. 워크플로우(Workflows):** 워크 플로우는 하나 이상의 작업(job)을 정의하고, 이벤트에 따라 실행되는 자동화된 프로세스다. 보통 `./github/workflows` 디렉토리에 YAML 파일 형식으로 저장한다.    

<br>  

**2. 이벤트(Events):** 워크 플로우 트리거 역활을 한다. 예를 들어 `push` 나  `pull reauest` 이벤트에 대해 워크플로우를 실행하도록 설정할 수 있다.  

<br>  


**3. 작업(Job):** 워크플로우 내에서 실행되는 일련의 단계(steps)를 말하는데, 작업들은 동일한 러너(runner)에서 실행되거나 다른 러너에서 병렬로 실행될 수 있다.   

<br>  


**4. 액션(Actions):** 재사용 가능한 작업 단위이다. 커뮤니티에서 공유하는 액션을 사용하거나 직접 만들어 사용할 수 있다.    


<br>  

**5. 러너(Runners)** 워크플로우를 실행하는 서버이고, Github는 Linux, Windows, MacOS러너를 제공하고 자체적인 러너를 설정할 수 있다. 

<br>  



Github Actions를 사용하면 개발 워크플로우를 극대화할 수 있는 유연성과 편리한데, 예를 들어 코드가 푸시될때 마다 자동으로 테스트를 실행하고, 풀 리퀘스트가 병합될때마다 자동으로 클라우드에 애플리케이션을 배포하는 과정을 설정할 수 있다. 

<br>  

이런 기능을 통해 개발 팀은 반복적인 작업에 드는 시간을 줄이고, 코드 품질을 개선하고 배포 프로세스를 자동화할 수 있다. 

## Github Action Test 

이번 포스팅에서는 간단하게 "Hello World" 를 찍어보자
Github Action 으로 Push나 Pull Request를 하게 되면 Hello World가 나오게 된다. 

<br>

```
name: Java CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  hello-world:

    runs-on: ubuntu-latest

    steps:
    - name: Print Hello World
      run: echo "Hello, World!"
```  

<br>

나는 테스트 리포지토리로 자바 알고리즘 풀던 곳에 Github Action을 설정했고, Push했다.  

![GithubAction](/public/img/Github-Action.png){: .center}

Push 했더니 위 이미지처럼 잘 돌아가는 모습을 볼 수 있다.  
