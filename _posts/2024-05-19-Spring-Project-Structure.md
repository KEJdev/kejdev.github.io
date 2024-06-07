---
layout: post
title: 스프링 프로젝트 구조 - 계층형과 도메인형 
date: 2024-06-02 00:00:00 +0900
category: Spring
---

스프링 프로젝트 구성은 기본적인 틀로 2가지로 구성되어 있다. 

### 계층형 구조

계층형 구조는 기능별로 시스템을 여러 계층으로 분리하여 모듈화한다. 각 계층은 명확한 책임을 가지고 있고, 상위 계층은 하위 계층에 의존하지만 그 반대는 허용하지 않는다. 현재 스터디에서 하고 있는 프로젝트 구조는 도메인 구조이지만 계층형으로 바꾼다고 하면 아래와 같이 바꿀 수 있다. 

<br>

```
├── main
│   ├── java
│   │   └── com
│   │       └── meowdev
│   │           └── echo
│   │               ├── application
│   │               │   └── EchoApplication.java
│   │               ├── presentation
│   │               │   ├── controller
│   │               │   │   ├── PolicyAgreeController.java
│   │               │   │   └── PolicyHistoryController.java
│   │               ├── business
│   │               │   ├── service
│   │               │   │   ├── base
│   │               │   │   │   ├── AbstractBaseEntity.java
│   │               │   │   │   ├── AbstractBaseUserByEntity.java
│   │               │   │   │   ├── AbstractBaseUserDeleteEntity.java
│   │               │   │   │   └── QuerydslConfiguration.java
│   │               │   │   ├── oauth
│   │               │   │   │   ├── AuthCodeRequestUrlProvider.java
│   │               │   │   │   ├── OauthMemberClient.java
│   │               │   │   │   └── GoogleApiClient.java
│   │               ├── data
│   │               │   ├── repository
│   │               │   │   ├── base
│   │               │   │   │   ├── QAbstractBaseEntity.java
│   │               │   │   │   ├── QAbstractBaseUserByEntity.java
│   │               │   │   │   ├── QAbstractBaseUserDeleteEntity.java
│   │               │   │   ├── hurdles
│   │               │   │   │   ├── QBag.java
│   │               │   │   │   └── QItem.java
│   │               │   │   ├── policy
│   │               │   │   │   ├── QPolicyAgree.java
│   │               │   │   │   └── QPolicyHistory.java
│   │               │   │   ├── quartz
│   │               │   │   │   └── QUserMetric.java
│   │               │   │   ├── user
│   │               │   │   │   ├── QUser.java
│   │               │   │   │   └── QUserMetric.java
│   │               │   └── config
│   │               │       └── AppConfig.java
│   │               ├── security
│   │               │   ├── BaseWebClient.java
│   │               │   ├── WebAuthenticationEntryPoint.java
│   │               │   ├── WebSecurityConfig.java
│   │               │   └── exception
│   │               │       └── TokenExpiredException.java
            ...
```

* 장점 
    * 프로젝트 전반적인 이해도가 낮아도, 구조만 보고 전체적인 구조를 파악할 수 있다.
        * API를 보고 흐름을 파악하고 싶으면, Controller 패키지 하나만 보고 파악할 수 있다. 
    * 계층별 응집도가 높아진다. 
        * 계층별 수정이 일어날 때, 하나의 패키지만 보면 된다. 

* 단점 
    * 상위 계층이 하위 계층에 강하게 의존할 수 있다. 
    * 규모가 커지면 하나의 패키지 안에 여러 클래스들이 모여서 구분하기 어렵다. 


### 도메인형 구조 

도메인형 구조는 도메인 주도 설계(DDD)의 원칙에 따라 도메인 모델을 중심으로 시스템을 구성하는 것을 말한다. 보통 복잡한 비즈니스 로직을 효과적으로 관리할 수 있도록 설계되어 있어서 많이 채용하는 편이다. 

```
├── main
│   ├── generated
│   │   └── com
│   │       └── meowdev
│   │           └── echo
│   │               └── service
│   │                   ├── base
│   │                   │   ├── QAbstractBaseEntity.java
│   │                   │   ├── QAbstractBaseUserByEntity.java
│   │                   │   └── QAbstractBaseUserDeleteEntity.java
│   │                   ├── hurdles
│   │                   │   └── domain
│   │                   │       ├── QBag.java
│   │                   │       └── QItem.java
│   │                   ├── policy
│   │                   │   └── domain
│   │                   │       ├── QPolicyAgree.java
│   │                   │       └── QPolicyHistory.java
│   │                   ├── quartz
│   │                   │   └── domain
│   │                   │       └── QUserMetric.java
│   │                   └── user
│   │                       └── domain
│   │                           ├── QUser.java
│   │                           └── QUserMetric.java
│   ├── java
│   │   └── com
│   │       └── meowdev
│   │           └── echo
│   │               ├── EchoApplication.java
│   │               ├── controller
│   │               │   ├── policy
│   │               │   │   ├── PolicyAgreeController.java
│   │               │   │   └── PolicyHistoryController.java
│   │               │   └── user
│   │               │       ├── EmailController.java
│   │               │       ├── OauthController.java
│   │               │       └── UserSignController.java
│   │               ├── security
│   │               │   ├── BaseWebClient.java
│   │               │   ├── WebAuthenticationEntryPoint.java
│   │               │   ├── WebSecurityConfig.java
│   │               │   └── exception
│   │               │       └── TokenExpiredException.java
│   │               ├── service
│   │               │   ├── base
│   │               │   │   ├── AbstractBaseEntity.java
│   │               │   │   ├── AbstractBaseUserByEntity.java
│   │               │   │   ├── AbstractBaseUserDeleteEntity.java
│   │               │   │   └── QuerydslConfiguration.java
│   │               │   ├── config
│   │               │   │   └── AppConfig.java
│   │               │   ├── oauth
│   │               │   │   ├── AuthCodeRequestUrlProvider.java
│   │               │   │   ├── AuthCodeRequestUrlProviderComposite.java
│   │               │   │   ├── HttpInterfaceConfig.java
│   │               │   │   ├── OauthMemberClient.java
│   │               │   │   ├── OauthMemberClientComposite.java
│   │               │   │   ├── OauthServerTypeConverter.java
│   │               │   │   ├── google
│   │               │   │   │   ├── GoogleApiClient.java
│   │               │   │   │   ├── GoogleAuthCodeRequestUrlProvider.java
│   │               │   │   │   ├── GoogleMemberClient.java
│   │               │   │   │   ├── GoogleOauthProviderConfig.java
│   │               │   │   │   ├── GoogleOauthRegistrationConfig.java
│   │               │   │   │   └── GoogleUserMeInfoResponseDto.java
│   │               │   │   ├── kakao
            .... 
```

* 장점   
    * 비즈니스 요구사항을 모델링하기에 적합하다.
    * 도메인 모델을 쉽게 변경할 수 있다. 
    * 도메인별 응집도가 높아진다.   

* 단점  
    * DDD 개념을 익히고 적용하는데 시간이 필요하다.
    * 단순한 애플리케이션에는 과할 수 있다.
    * 애플리케이션의 전반적인 흐름을 한눈에 파악하기 어렵다.   

### 어떤 것이 효율적일까?  

무조건적으로 좋은 것은 없고 그냥 규모와 장단점을 비교해서 선택하는 것이 좋다.  

* 계층형 구조를 선택하는 경우  
규모가 작고, 도메인이 적은 경우 계층형이 좋다. 왜냐하면 규모가 작고 도메인이 적은 만큼 변경 범위가 그렇게 크지 않기 때문이다. 

* 도메인형 구조를 선택하는 경우 
규모가 크고 도메인이 많은 경우에는 도메인형이 좋다. 규모가 큰 만큼 도메인의 응집도가 높은것이 중요하기 때문이다. 
