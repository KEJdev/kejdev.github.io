---
layout: post
title: Python classmethod vs staticmethod 차이점과 사용방법
date: 2023-04-05 09:00:00 +0300
category : Python
---

staticmethod 와 classmethod는 파이썬에서 함수를 정의할떄 사용되는 데코레이터 중 하나이다.

### staticmethod

Class method에 **@staticmethod 데코레이터를 사용**하면 정적 메소드가 된다. 
정적 메소드는 클래스의 인스턴스를 생성하지 않아도 호출할 수 있는 메소드며, 정적 메소드를 호출할때는 클래스명.메소드명() 형식으로 호출할 수 있다.

```python
class MyClass:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    @staticmethod
    def my_static_method():
        print("This is a static method")

MyClass.my_static_method()  # 출력: This is a static method**
```

### classmethod

Class method에 **@classmethod 데코레이터를 사용**하면 클래스 메소드로 만들어준다. 
정적메소드와 마찬가지로 인스턴스를 생성하지 않아도 호출할 수 있으며 클래스 메소드를 호출할때는 클래스명.메소드명() 형식으로 호출할 수 있다.

```python
class MyClass:
    class_var = "Hello, world!"
    
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    @classmethod
    def my_class_method(cls):
        print(cls.class_var)

MyClass.my_class_method()  # 출력: Hello, world!
```


### staticmethod와 classmethod 차이점

classmethod는 호출할 때는 **클래스 자체를 첫 번째 인수(cls)로 받아온다.**
cls를 받아들여 클래스 레벨에서 작업을 수행하고, 클래스 변수를 조작하거나 새로운 인스턴스를 만들때 사용된다.

staticmethod는 클래스나 인스턴스와 상관없이 **독립적으로 작동되는 메소드**이며 클래스에서 정의된 일반 함수와 동일하지만, self를 사용할 수 없는데 그 이유는 **인스턴스에 대한 참조**가 없기 때문이다. 

```python
class MyClass:
    class_var = 0
    
    @classmethod
    def class_method(cls):
        cls.class_var += 1
        print("class_var:", cls.class_var)
        
    @staticmethod
    def static_method():
        # Cannot access class_var here
        pass
        
obj = MyClass()
obj.class_method()  # class_var: 1
MyClass.class_method()  # class_var: 2
MyClass.static_method()
```


### staticmethod와 classmethod 언제 사용하나?

정적 메소드는 주로 유틸리성 함수를 위한 용도로 사용된다. 항상 같은 출력을 반환하는 순수함수들을 말한다.  

유틸리티 함수의 경우 따로 모듈로 빼서 작성해도 되지 않을까? 하는 의문점이 들었는데, 정답은 없다. 모듈로 빼서 작성하는 것이 편하다면 그렇게 작성해도 되고 클래스와 연관이 깊어서 클래스 내에 위치 시키고 싶다면 그렇게 해도 된다. 

클래스 메소드의 경우 생성자를 wrapping하는 용도로 사용하거나 클래스 속성에 접근하여 변경하는 방식으로 이용할 수 있다.