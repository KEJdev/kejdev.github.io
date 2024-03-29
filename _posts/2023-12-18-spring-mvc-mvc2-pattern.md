---
layout: post
title: 스프링 MVC와 MVC2
date: 2023-12-18 09:00:00 +0300
category: Spring
---

## 🥕 MVC(Model-View-Controller)

MVC(Model-View-Controller)와 MVC2는 소프트웨어 디자인 패턴 중 하나이다. 우선 MVC가 무엇인지에 대해 먼저 알아보자.

- Model : Model은 데이터베이스, 파일, 외부 서비스와의 연동 등 데이터 관련 작업을 수행한다. 처리한 작업 데이터를 클라이언트에게 응답으로 돌려주는 작업의 처리 결과 데이터를 Model이라고 한다.

- View : 사용자 인터페이스를 담당하는 부분이다. 사용자가 보는 화면을 구성하며, Model에서 제공하는 데이터를 시작적으로 표현한다. (HTML, PDF, JSON)

- Controller : 사용자의 입력을 받고 처리하는 부분이다. 사용자의 요청을 분석하고 , 해당하는 Model을 호출하고 그 결과를 View에 전달한다.

이제 스프링에서 사용하는 MVC 구조를 살펴보자.

### Spring MVC구조

![MVC-Process](/public/img/MVC-Process.png)
이미지 출처: [Spring MVC Architecture](https://terasolunaorg.github.io/guideline/5.0.1.RELEASE/en/Overview/SpringMVCOverview.html)

- Dispatcher Servlet : 모든 요청을 받아서 Controller에게 넘겨주는 역할을 주로 함
- HandlerMapping : 들어오는 요청 URL에 매핑되는 컨트롤러를 선택하고,선택된 핸들러(Handler)와 컨트롤러를 DispatcherServlet에 반환하고, DispatcherServlet이 컨트롤러의 비즈니스 로직 실행 작업을 HandlerAdapter에게 위임함
- HandlerAdapter : 컨트롤러의 비즈니스 로직 프로세스를 호출함
- 컨트롤러가 비즈니스 로직을 실행하고, 처리 결과를 모델에 설정한 후 논리적 이름을 HandlerAdapter에 반환함  
  \*\* 논리적 이름 : 컨트롤러가 View에 대해 참조하는 방식을 말함. 논리적 이름은 실제 View 파일(ex. test.html) 경로나 파일명과 직접적으로 일치하지 않고도 대신 View Resolver에 의해 해석되어 실제 뷰 리소스로 매핑됨.
- ViewResolver는 뷰 이름에 매핑된 뷰를 반환함
- 뷰는 모델 데이터를 렌더링하고 응답을 반환함.

위 이미지는 DispatcherServlet의 동작 과정인데, 실제 스프링 MVC패턴의 핵심 요소이다.
DispatcherServlet의 동작 방식은 MVC패턴을 원칙으로 따르며 스프링 MVC에서 웹 애플리케이션의 요청과 흐름을 관리하는데 중심적인 역할을 한다.

#### DispatcherServlet의 역할과 MVC

- 컨트롤러(Controller) 역할: DispatcherServlet은 스프링 MVC에서 프론트 컨트롤러(Front Controller) 패턴을 구현하고, 모든 웹 요청은 먼저 DispatcherServlet을 통과하는데, 이건 MVC 패턴의 컨트롤러 부분에 해당함

- 요청 라우팅(Request Routing): DispatcherServlet은 들어오는 요청을 분석하고 적절한 핸들러(Controller)에게 요청을 전달하고, 이 과정에서 HandlerMapping을 사용하여 요청 URL을 처리할 컨트롤러 메소드와 매핑함

- 모델과 뷰의 선택: 컨트롤러가 비즈니스 로직을 처리한 후, DispatcherServlet은 반환된 정보(모델)와 뷰 이름을 바탕으로 응답을 생성하는데, ViewResolver는 뷰 이름을 사용하여 실제 뷰를 결정하고, 뷰는 모델 데이터를 사용하여 최종적인 사용자 응답을 렌더링함.

### 🔎 MVC 패턴을 왜 써야 될까 ?

MVC패턴을 사용하는 이유에는 여러가지가 있다.

1. Model, View, Controller로 분리했기 때문에 독립적으로 관리되고 수정될 수 있어, 유지보수와 확장에 용이하다.
2. 모델은 독립적으로 사용하기 때문에 재사용성 및 유연성에 뛰어나다. 동일한 로직을 여러 인터페이스에 쉽게 적용이 가능하기 때문이다.
3. 테스트하기가 용이하다.

MVC패턴은 이러한 이점들로 인하여 오랫동안 인정받고 사용되어 왔다.

### 🤔 MVC2는 무엇인가 ?

지금은 많은 곳에서 표준으로 쓰고 있는 것이 MVC2패턴이다.
MVC2가 등장한 이유는 복잡성과 특성 때문이다. 원래의 MVC패턴은 데스크톱 애플리케이션 개발에 적합했지만, 이제는 개발에 대한 여러 요구 사항들을 충족해야는 경우가 많아지고 있어서 MVC패턴을 적합하게 발전시켜야 했다.

결론적으로 클라이언트와 서버 아키텍처를 조금 더 효율적으로 관리하면서, 유지보수/확장성/성능과 최적화를 하기 위해 기존에 있던 MVC패턴을 발전 시켰다.

MVC와 MVC2는 아래와 같은 차이가 있다.
![MVC1](/public/img/mvc1.png)

#### MVC

- User -> JSP(View/Controller): 사용자의 요청은 뷰를 통해 들어오며, 뷰는 컨트롤러의 기능을 일부 수행함
- Controller -> Model: 컨트롤러는 모델에 요청을 전달하여 비즈니스 로직을 처리함
- Model -> DB: 모델은 데이터베이스와의 상호 작용을 통해 데이터를 처리하고 결과를 컨트롤러에 반환함.

#### MVC2

- User -> Controller: 사용자의 모든 요청은 컨트롤러를 통해 처리함
- Controller -> Model: 컨트롤러는 모델에 데이터 처리를 요청함
- Model -> DB: 모델은 데이터베이스와 상호 작용하여 필요한 데이터를 처리하고 결과를 컨트롤러에 반환함
- Controller -> View: 컨트롤러는 처리된 데이터를 뷰에 전달하여 사용자에게 표시함

#### MVC와 MVC2의 단점

MVC의 장점은 뷰랑 컨트롤러가 밀접하게 연결되어 있어 소규모 프로젝트에서 유연하게 개발할 수 있고, 복잡한 설정이나 구성없이도 구현할 수 있다는 것이 장점이지만, 유지보수가 어렵고 (뷰와 컨트롤러 사이의 명확한 구분이 없음) 아무래도 확장성에 제한이 있어 큰 규모의 프로젝트나 복잡한 비즈니스 로직에는 사용하기 힘들다.

MVC2의 경우 역할이 명확하게 분리되어 있다보니, 유지보수와 확장성이 매우 뛰어나며, 재사용성/테스트/효율적인 데이터 관리 등 많은 장점이 있다. 단점은 초기 학습 곡선이 조금 가파르며, 구현 복잡성이 있다.
