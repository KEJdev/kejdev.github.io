---
layout: post
title: AWS NAT Instance 만들기
date: 2024-05-19 00:00:00 +0900
category: AWS
---

현재 프리티어를 사용하고 있는데, 생성한 EC2안에 Docker를 설치하려고 한다. ECR(Elastic Container Registry)에 Docker 이미지 저장소는 구축되어 있지만 어찌되었건 EC2에서 Docker를 쓰려면 설치해야 한다.

## NAT(Network Address Translation)

NAT는 내부 네트워크 IP주소를 외부 네트워크 IP주소로 변환하고, 통신을 할 수 있도록 하는 것이 NAT의 역할을 한다. 따라서 프라이빗 서브넷의 인스턴스가 NAT 인스턴스나 NAT 게이트웨이를 사용해야지만, 인터넷에 접근할 수 있다. NAT는 아래와 같이 2가지 종류가 있지만 나는 NAT 인스턴스를 만들 것이다.

- NAT 게이트웨이 : AWS 관리형 서비스로, 생성 및 관리는 쉽지만 비용이 비싸다.
- NAT 인스턴스 : EC2 instance를 NAT용으로 바꿔 사용하는 것을 말한다.

## EC2(NAT Instance) 생성

EC2 인스턴스를 아래와 같이 만들어 주자.

![aws-nat-1](/public/img/aws-nat-1.png)

NAT Instance용이기 때문에 이름을 대충 echo-nat라고 했다.

![aws-nat-2](/public/img/aws-nat-2.png)

여기서 중요한데 AMI는 꼭 NAT용 AMI로 꼭 설정해줘야 한다. 커뮤니티 버전은 무료이라 나는 커뮤니티 버전에 아무거나 사용했다.

![aws-nat-3](/public/img/aws-nat-3.png)

만들어둔 VPC를 할당하고 서브넷을 할당하는데 서브넷을 할당할때는 꼭 IGW가 있는 퍼블릭 서브넷으로 설정해야한다. (\*예시로 찍은 이미지라 private 잘못 설정되어 있으니 주의!ㅠ)

퍼블릭 IP 자동할당 부분은 과금이 될 수 있는 부분인데, 사실 요것도 선택이다.

EIP(Elastic IP)를 사용하느냐 퍼블릭 IP 자동할당 사용하냐 둘 중 하나 선택하면 된다. 물론 2개 다 선택해도 되지만 마찬가지로 과금이 될수 있으니 주의하자.

프리티어는 EIP 하나는 무료로 쓸 수 있다고 하니, 나는 퍼블릭 IP 자동 할당을 버리고 EIP을 사용하려고 한다.

![aws-nat-4](/public/img/aws-nat-4.png)

보안 그룹 규칙은 위 이미지처럼 간단하게 구성했다.

![aws-nat-5](/public/img/aws-nat-5.png)

인스턴스 생성 완료했으면 방금 만든 NAT 인스턴스를 체크하여 소스/대상 확인 변경을 클릭하자.

![aws-nat-6](/public/img/aws-nat-6.png)

그리고 이미지와 같이 중지를 체크하고 저장을 눌러자. 왜냐하면 NAT 인스턴스는 소스 또는 대상이 그 자체가 아닐 때 트래픽을 송수신할 수 있어야 하기 때문이다.

![aws-nat-7](/public/img/aws-nat-7.png)

그리고 EIP를 할당 받자.

![aws-nat-8](/public/img/aws-nat-8.png)

할당 받았으면 바로 아까 만들었던 NAT 인스턴스를 연결해주면 끝난다.  
EIP의 경우 할당 받고 아무 인스턴스에도 연결되어 있지 않으면 과금되는 구조이기 때문에 할당 받았으면 바로 연결해주자. 실행 중인 인스턴스에 주소를 할당하게 되면 과금은 되지 않는다.

![aws-nat-9](/public/img/aws-nat-9.png)

EIP 연결이 끝났으면 라우팅 테이블을 새로 하나 만들어 서브넷 프라이빗을 아래와 같이 설정하자. 이미 서브넷 프라이빗이 있는 라우팅 테이블이 있다면 이 단계를 건너뛰어도 된다.

![aws-nat-10](/public/img/aws-nat-10.png)

그리고 대상을 인스턴스로 설정하고 아까 만들었던 NAT 인스턴스를 넣고 저장을 누르면 NAT 인스턴스 만들기는 끝난다.

## EC2 Docker Install

이제 NAT 인스턴스 설정이 끝났다면 EC2에 도커를 아래와 같이 설치하자.

```sh
# 패키지 업데이트
sudo dnf update -y

# Docker 패키지 설치
sudo dnf install docker -y

# Docker 서비스 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 도커 버전 확인하기
docker --version
```
