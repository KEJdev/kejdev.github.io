---
layout: post
title: Hibernate Architecture
date: 2023-12-23 09:00:00 +0300
category: Spring
---

### Hibernate

하이버네이트(Hibernate)는 이전 포스팅에서도 잠깐 언급했듯이 객체-관계 매핑(ORM) 라이브러리며, 주요 기능은 아래와 같다.

- 데이터베이스 독립성 : 다양한 데이터베이스와 호환되어, 개발자가 특정 데이터베이스 SQL문법에 종속되지 않도록 한다.
- 객체-관계 매핑(ORM) : 자바 객체를 데이터베이스 테이블에 매핑하고, 이들 간의 관계를 관리한다. 또한 이를 통해 복잡한 조인이나 변환 작업 없이 객체를 데이터베이스에 저장하고 검색할 수 있다.
- 쿼리 언어 : HQL(Hibernate Query Language)은 SQL과 유사하지만 객체 중심인데, 데이터베이스 구조보다는 애플리케이션의 도메인 모델에 초점을 맞춘다.
- 캐싱 : 성능 최적화를 위해 1차 캐시, 2차 캐시를 제공하여 자주 사용되는 데이터에 빠르게 접근할 수 있게 한다.
- 트랜잭션 관리 : 데이터베이스 트랜잭션을 관리하고, 객체의 상태 변화를 데이터베이스와 동기화하는데 도움을 준다.

### Hibernate Architecture

하이버네이트에는 여러 계층(Layer)가 있다. 이 계층들은 하이버네이트의 기능을 조직화하고, 서로 다른 부분들이 효율적으로 상호작용할 수 있도록 한다. 우선 전체적인 그림은 아래와 같다.

![hibernate-1](/public/img/comprehensive_hibernate_architecture.png)

이미지에 보이는 각 계층(Layer)은 아래와 같은 역할을 한다.

1. 애플리케이션 계층(Application Layer)

- 역할: 개발자가 작성하는 비즈니스 로직과 객체 모델을 포함한다
- 구성 요소:  
   - Transient Objects: 데이터베이스에 저장되지 않은 임시 객체들이다 - Persistent Objects: 데이터베이스에 저장되며 하이버네이트 세션에 의해 관리되는 영구 객체들이다.

2. 하이버네이트 코어 계층(Hibernate Core Layer)

- SessionFactory: - 싱글톤 패턴을 사용해 생성되며, 애플리케이션 전체 수명 동안 존재한다. - hibernate.cfg.xml을 통해 구성 설정을 로드하고, Session 인스턴스를 생성한다. - 데이터베이스 연결과 2차 레벨 캐시 설정을 관리한다.
- Session - 데이터베이스와의 단일 연결을 나타내며, 객체의 CRUD 작업을 수행한다. - 각 세션은 SessionFactory로부터 생성되고, 1차 레벨 캐시를 포함한다. - 트랜잭션, 쿼리, 기준(Criteria) 객체를 생성하는 팩토리 역할을 한다.
- TransactionFactory: 트랜잭션을 생성하고 관리하는 구성 요소임
- ConnectionProvider: 데이터베이스 연결을 관리하는 구성 요소임

3. 트랜잭션 계층(Transaction Layer)

- Transaction - 데이터베이스 작업의 원자성을 보장하며, 하나의 세션 안에서 여러 트랜잭션을 관리할 수 있다. - 작업 단위를 시작, 커밋 또는 롤백하는 기능을 수행한다.

4. JNDI, JDBC, JTA

- JNDI (Java Naming and Directory Interface): 리소스와 객체를 찾기 위한 디렉터리 서비스를 제공함
- JDBC (Java Database Connectivity): 자바 애플리케이션과 데이터베이스 사이의 통신을 위한 API임
- JTA (Java Transaction API): 분산 트랜잭션을 관리하기 위한 자바 API임

5. Database
   실제 데이터가 저장되는 데이터베이스를 나타낸다.

여기 아키텍처에서 애플리케이션 계층과 데이터베이스 계층은 사실 하이버네이트 자체의 내부 계층이라기 보다는 하이버네이트가 상호작용하는 외부 계층이고, 실제 하이버네이트 아키텍쳐 부분은 아래 그림과 같이 하늘색으로 색칠된 부분과 같다.

![hibernate-2](/public/img/comprehensive_hibernate_architecture2.png)

따라서, 하이버네이트의 내부 계층은 SessionFactory, Session, Transaction 등으로 구성되어 있고 이 내부 계층이 애플리케이션 계층과 데이터베이스 계층 사이에서 중요한 역할을 한다. 이 내부 계층들은 하이버네이트의 핵심기능과 연결성을 제공하고 애플리케이션 계층과 데이터베이스 계층을 원활하게 연결하는데 필요한 모든 처리를 담당한다.

<br>

---

이미지 출처:[https://docs.jboss.org/](https://docs.jboss.org/hibernate/core/3.5/reference/en/html/architecture.html)
