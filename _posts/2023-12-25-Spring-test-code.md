---
layout: post
title: Spring Test Code 종류
date: 2023-12-25 09:00:00 +0300
category : Spring
---

### Test Code 

테스트 코드는 특정 부분(기능)이 올바르게 동작하는지 검증하기 위해 작성하는 코드를 말한다. 다양한 기능들이 의도된 대로 작동하는지 확인하고 변경사항이나 업데이트로 인해 발생할 수 있는 문제를 사전에 발견하는데 도움을 준다. 

테스트 코드는 종류가 많은데 일반적으로 단위 테스트(Unit Test)와 통합 테스트(Integration Test)가 있다.

#### Unit Test

가장 작은 단위(주로 함수나 메서드)를 테스트한다. 외부 의존성 없이 코드가 의도한대로 동작하는지 확인한다.

* 장점 : 개별 함수나 메소드를 독립적으로 테스트 할 수 있어서 문제를 정확히 진단하기 쉽다. 
* 단점 : 실제 운영 환경과 다른 조건에서 테스트되므로 환경 차이로 인한 문제나, 전체 시스템의 동작을 검증하기 힘들다. 

#### 좋은 단위 테스트

- 단위 테스트는 1개의 테스트는 1개의 기능에 대해서만 테스트해야된다. 
- 각 테스트는 다른 테스트에 의존하지 않고 독립적으로 실행되어야 한다.
- 단위 테스트는 빠르게 실행되어야 하며, 오래 걸리는 I/O작업이나 네트워크 호출을 피해야 한다.
- 어떤 환경에서도 동일한 결과를 내야 하므로, 외부 환경 설정에 의존하지 않아야 한다.

#### Integration Test

모듈을 통합화하는 과정에서 모듈 간의 호환성을 테스트한다. 

* 장점 : 다양한 컴포넌트가 서로 올바르게 상호작용하는지 검증하고, 실제 운영 환경에 까가운 조건에서 테스트 되기 때문에 빠르게 이슈를 캐치 할 수 있다.
* 단점 : 단위 테스트보다는 실행속도가 느리며, 관리하는 것이 복잡하다.

#### 좋은 통합 테스트

- 가능한 실제 운영 환경을 모방하여 테스트 환경을 구성해야 한다.
- 시스템의 각 컴포넌트 간의 인터페이스가 정확하게 데이터를 주고 받는지 확인해야 한다. 인터페이스 오류는 통합 테스트에서 가장 흔하게 발생하는 문제다.
- 통합 테스트는 단위 테스트에 의해 커버 되지 않는 경로나 조건을 포함해야 한다.
- 예외 사항과 에러가 적절히 처리하는지 검증해야 한다.(에러 핸들러 검증)
- 성능과 부하 상황에 대한 테스트를 포함해야 한다.

### Spock 와 RestDocs

Spock과 RestDocs 둘 다 테스트할때 사용할 수 있는데, 각각의 목적과 사용방법에 차이가 있다.
결론적으로 말하자면, Spock은 테스트 자체의 작성과 실행에 초점을 맞추고, Spring RESTDocs는 생성된 테스트 결과를 바탕으로 API 문서를 작성하는데 주로 사용된다. 따라서 어떤 테스트 방식을 채용할 것인지는 프로젝트 성향에 맞춰서 채용하면 된다. 

#### Spock 

- 주로 테스트 코드를 작성하기 위한 프레임워크이며, 단위 테스트 및 통합 테스트를 위해 사용된다.
- Groovy 기반의 문법을 사용하여 깔끔하며 유지보수하기 쉬운 방식으로 작성이 가능하다.
- BDD(Behavior-Driven Development) 방식에 기반하여 'Given-When-Then' 형식이다.  
*BDD(Behavior-Driven Development) : 소프트웨어의 기능이 어떻게 행동해야 하는지에 초점을 맞춘 소프트웨어 개발 방법론

```
Given(설정) : 테스트에 필요한 환경을 설정하는 작업
When(행동) : 테스트 코드를 실행
Then(검증) : 테스트 코드 결과 검증, 예외 및 조건에 대한 결과를 확인 
Expect : 테스트 코드 실행 및 검증 (When+then)하는건데 한줄로 합쳐서 간결하게 표현할때 사용
Where : 다양한 입력값을 넣어서 테스트 로직을 실행함
```

#### RestDocs 

- RESTful API를 테스트하면서 동시에 문서화를 생성하는데 사용된다.
- Spring MVC Test 프레임워크와 함께 작동하며, API의 요청 및 응답을 기반으로 문서를 자동으로 생성한다.

여기서 눈치 채신 사람들도 있겠지만, RestDocs는 Swagger랑 성격이 비슷하다.
둘 다 공통점으로 RESTful API문서화하기 때문이지만, 접근 방식과 기능면에서 차이가 있다.

#### RestDocs와 Swagger의 차이 

* RestDocs : 실제 테스트 케이스를 바탕으로 문서를 생성하며, 테스트가 성공적으로 실행될 때만 문서가 생성되거나 업데이트 되며 아래와 같은 상황일 때 사용하는 것이 적합하다. 
1. 코드와 문서 사이에 일관성을 유지하고 싶을 때
2. 실제 요청과 응답을 정확하게 문서화하고자 할 때 
3. 코드 변경에 따른 문서의 자동 업데이트를 원할 때  

* Swagger : 코드에 작성된 어노테이션 또는 API 명세를 바탕으로 문서를 자동 생성되며 아래와 같은 상황일 때 사용하는 것이 적합하다.
1. 빠르고 쉽게 문서를 생성하고 싶을 때
2. 인터랙티브한 API 문서를 제공하고 싶을 때
3. API 설계와 테스트를 동시에 진행하고자 할 때


#### Spock Test 
RestDocs는 다음에 다룰예정이고, 우선 Spock 간단하게 테스트 해보자.
간단하게 덧셈 기능을 테스트 해보자.

![spock-1](/public/img/Spock1.png)

이렇게 간단하게 `Calculate` 클래스를 만들었고, Test폴더에 아래와 같이 Groovy파일을 만들었다. 

![spock-2](/public/img/Spock2.png)

그리고 두근거리는 마음으로 실행했더니 아래와 같은 에러가 발생했다.

```
execution failed for task ':test'.
No tests found for given includes: ~~~ 

User
* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.
Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.
You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.
For more on this, please refer to https://docs.gradle.org/8.5/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.
BUILD FAILED in 4s
4 actionable tasks: 1 executed, 3 up-to-date
```

뭐지? 하고 싶어서 찾아봤더니 Gradle 설정 수정해주면 된다고 하길래 아래와 같이 수정했다.

![spock-3](/public/img/Spock3.png)

이렇게 수정했더니 아래와 같이 성공했다!

![spock-4](/public/img/Spock4.png)


