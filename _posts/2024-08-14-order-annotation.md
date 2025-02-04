---
layout: post
title: 자바 필터 패턴 및 @Order 어노테이션 사용 방법
date: 2024-08-14 00:00:00 +0900
category: Spring
---

## Design Pattern

디자인 패턴은 직접적으로 문제를 해결하는 코드라기보다는 문제를 해결할 수 있는 방법론이라고 할 수 있다. 소프트웨어 개발에서 반복적으로 등장하는 문제를 해결하기 위한 노하우를 축적하여 체계적으로 정리한 것을 말하며, 디자인 패턴은 특정 언어에 종속되지 않는 것이 특징이다.

디자인 패턴은 크게 3가지로 나눌 수 있으며 생성 패턴(Creational Patterns), 구조 패턴(Structural Patterns), 행위 패턴(Behavioral Patterns)이 있다.  
그 중 필터 패턴은 구조 패턴(Structural Patterns)으로 분류되며, 구조 패턴은 객체나 클래스를 조합하여 더 큰 구조를 만드는 방법에 중점을 둔다.

### 필터 패턴(Filter Pattern)

필터 패턴은 객체 집합을 필터링하는데 사용하는 디자인 패턴이다. 조건에 따라 객체들을 선별하거나 연속적으로 여러 필터를 적용하여 최종적으로 원하는 객체들을 추출할 때 사용한다. 주로 데이터 스트림 처리나 조건에 따라 객체를 필터링하는 상황에서 사용된다.

### 필터 패턴이 구조 패턴에 속하는 이유

필터 패턴은 보통 여러 개의 필터를 조합하여 조건을 점진적으로 적용해 나가는 방식이다. 객체(필터)들이 특정 조건을 만족하는지 평가하면서 구조적으로 결합되어 작동한다. 또한 필터 패턴을 사용하면 새로운 필터를 추가하여 기존의 시스템을 변경하지 않고도 기능을 확장할 수 있다.

## @Order 이란 ?

@Order 어노테이션은 주로 빈의 우선 순위를 설정할 때 주로 사용된다. 이 어노테이션을 사용하여 여러 빈이 같은 인터페이션를 구현하거나 같은 타입의 빈이 있을 때, 어떤 빈이 먼저 처리되어야 하는지를 정할 수 있다.

```java
@Order(1)
class FirstService ...{

}

@Order(2)
class SecondService ...{

}
```

값이 작을 수록 높은 우선순위를 의미하기 때문에 Order(1)은 Order(2)보다 먼저 처리된다.

## 필터 패턴과 Order 어노테이션

필터 패턴과 @Order 어노테이션을 함께 사용하면 필터를 순차적으로 적용해야하는 상황에서 각 필터의 실행 순서를 명확히 지정할 수 있다.

커머스로 예를 들어 기본 할인, 쿠폰 적용, 카드사 할인, 특정 이벤트 할인, 배송 타입별 상품 등 다양한 조건이 있다고 가정하자. 각 필터가 서로 상호작용하고 특정 조건에 따라 동적으로 적용되어야 하기 때문에 각 필터의 적용 순서가 중요하다. 카드사 할인과 쿠폰 할인이 중복되지 않도록 하거나 유저가 중간에 카드사나 상품 목록등 변경하면 적용 가능한 필터들이 동적으로 조정되어야 한다.

또한 @Order 어노테이션은 기본적으로 필터나 빈의 우선순위를 지정해주는 역활만 하기 때문에 중복 할인과 같은 우선순위를 제어하는 것은 단순히 필터 실행 순서만으로 해결되지는 않는다. 중복 할인 제어는 비즈니스 로직을 통해서 처리되어야 하고, 각 필터 내부에서 특정 할인 조건을 검증하고 다른 할인과의 중복 적용여부를 판단해야 한다. 예를 들면 아래와 같다.

1. 유저가 가진 쿠폰을 적용하려고 시도한다.
2. 특정 쿠폰이 적용된다면, 플래그를 설정하여 이 쿠폰이 적용되었음을 표시한다.
3. 이후 필터(카드사 할인 필터)가 실행될 때 쿠폰 필터가 적용된 경우 중복할인 여부를 체크하고 필요에 따라 할인을 적용하지 않거나 다른 로직을 수행한다.

### Order 값이 중복이 되는 경우

만약 @Order 값이 중복되는 경우에는 어떻게 될까 ? 이렇게 동일한 우선순위를 가진 필터나 빈이 존재하게 된다면 아래와 같이 처리된다.

1. 동일한 @Order 값을 가진 필터나 빈이 존재할 경우, 스프링은 기본적으로 코드나 빈이 정의된 순서에 따라 처리한다.
2. 순서가 명확히 정의되지 않은 경우, 처리 순서는 비결정적이며, 동일한 @Order 값을 가진 빈이나 필터는 비결정적인(랜덤) 순서로 실행될 수 있다.
3. XML이나 Config에 명시된 순서가 있다면, 그 순서에 따라 우선순위를 가진다.
4. 동일한 @Order 값을 가진 빈들이 여러 개 존재하고 명시적인 순서가 없다면, 스프링은 일반적으로 빈 이름의 알파벳 순서에 따라 처리한다.
