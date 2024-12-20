---
layout: post
title: 추상 클래스를 사용하는 이유 
date: 2024-10-29 00:00:00 +0900
category: Java 
---

추상 클래스는 상속과 객체지향 프로그래밍(OOP)에서 공통된 기능을 정의하고, **여러 자식 클래스가 확장하여 재사용할 수 있도록** 해주는 역활을 한다. 따라서 추상 클래스는 완전한 구현이 아닌 템플릿 역활(기본 틀)을 하며, **추상 메서드에서는 구현을 강제**하기 때문에 일관성 유지, 확장성 등에 대한 장점이 있다.      


### 추상 클래스 간단하게 구현하기

클래스 앞에 `abstract`를 붙이면 추상 클래스가 된다. 


```java
// 추상 클래스 
public abstract class Payment {
    // 추상 메서드 
	public abstract void processPayment();

    // 일반 메서드 
	public void receipt(){
		System.out.println("삐비비빅 ~ 영수증을 출력합니닷 !");
	}
}
```


Payment는 추상 클래스고, processPayment()는 `abstract` 키워드를 사용하여 추상 메서드를 만들었다. 보다시피 processPayment는 구현 없이 선언만 되어 있다.     

이렇게 되면 Payment를 상속 받는 클래스는 반드시 processPayment() 메서드를 받드시 구현해야한다. 만약 추상 클래스에서 선언된 추상 메서드를 재정의(Override)하지 않으면 컴파일 에러가 난다.   


추상 클래스는 상속 구조에서 부모 클래스로 사용되고 자식 클래스들이 공통으로 가져야 할 속성이나 기능을 정의한다. 추상 클래스에는 구현 없이 선언만 된 추상 메서드가 포함되기 때문에 추상 클래스 자체로 완전한 기능을 갖지 않는다. 이러한 불완전함 때문에 추상 클래스는 직접 인스턴스화 할 수 없다. 하지만 자식 클래스가 추상 메서드를 구현하면 객체를 생성하고 동작을 수행할 수 있다. 


```java
// 추상 클래스 
public abstract class Payment {
    protected String charge;

    // 부모 클래스의 생성자
    public Payment(String charge) {
        this.charge = charge;
    }

    // 추상 메서드: 각 결제 방식이 구현해야 함
    public abstract void processPayment();

    // 일반 메서드: 영수증 출력
    public void receipt() {
        System.out.println("삐비비빅 ~ " + charge + "원 짜리 영수증을 출력합니다!");
    }
}
```

추상 클래스를 정의하고 변수(charge)를 초기화 하는 생성자를 포함하도록 작성했고, 아래 자식 클래스에서 부모 클래스의 생성자를 호출하면 초기화 작업을 수행 할 수 있게 된다.  


```java
public class CreditCardPayment extends Payment {
    // 생성자: 부모 클래스의 생성자를 호출
    public CreditCardPayment(String charge) {
        super(charge);  // 부모 클래스의 생성자 호출
    }

    // 추상 메서드 구현
    @Override
    public void processPayment() {
        System.out.println("신용카드로 " + charge + "원 결제합니다.");
    }
}
```

### 왜 추상 클래스를 사용할까?  


추상화가 중요한 이유는 여러 가지가 있겠지만, 핵심은 **하이 레벨과 로우 레벨을 분리하여 플러그인처럼 교체 가능한 아키텍처를 구현할 수 있는 기반**을 마련하는 데 있다.

* high-level 은 비즈니스 로직이나 주요 작업 흐름을 관리하며 세부 기능을 직접 구현하지 않고 추상화된 인터페이스나 추상 클래스를 통해 기능을 호출하거나 전체적인 흐름을 제어한다.    

    <aside>
    <span class="icon">🥕</span> 
    <div class="content">
    <p>예를 들어 아래와 같이 결제를 진행하는 비즈니스 로직을 포함한 `OrderService` 클래스가 high-level에 해당되는데 `OrderService` 는 결제 방식에 관계 없이 결제를 처리하도록 "결제를 진행해라" 라는 요청만 한다.  </p>  
    </div>
    </aside>


```java
public class OrderService {
    private final Payment payment;

    public OrderService(Payment payment){
        this.payment = payment;
    }

    public void processOrder(){
        System.out.println("주문을 처리합니당");
        payment.processPayment();
    }
}
```  
    
* low-level 은 high level의 요청에 따라 실제 작업을 수행하고 구체적인 기능을 정의한다.  
    <aside>
    <span class="icon">🥕</span> 
    <div class="content">
    <p>예를 들어 `CreditCardPayme` 클래스가 Payment 추상 클래스를 상속받아서 processPayment라는 메서드를 구체적으로 구현하는데, 결제를 어떻게 처리할지를 상세하게 정의하기 때문에 Low level 클래스라고 할 수 있다.  </p>  
    </div>
    </aside>  
    
```java
// low-level 코드
public class CreditCardPayment extends Payment {
    @Override
    public void processPayment() {
        System.out.println("신용카드 결제를 처리합니다.");
    }
}
```


정리하자면 추상화를 사용하면 **하이 레벨 코드가 로우 레벨의 세부 사항에 의존하지 않고**, **추상 클래스나 인터페이스를 통해 필요한 동작을 정의할 수 있다.** 이로 인해 **로우 레벨 구현을 유연하게 교체**할 수 있고, 시스템의 확장성과 유지보수/강제성을 높일 수 있다.  

