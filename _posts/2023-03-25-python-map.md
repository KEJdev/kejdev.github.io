---
layout: post
title: 파이썬 map() 함수의 활용 방법과 예제 코드
date: 2023-03-25 09:00:00 +0300
category: Python
---

파이썬의 `map`함수는 파이썬 내장 함수 중 하나로 리스트, 튜플 등 반복 가능한(iterable)를 입력받아, 해당 객체의 모든 요소에 대해 특정 함수를 적용한 결과를 새로운 리스트로 반환하는 함수이다.

가장 기본적인 형태로 자주 쓰이는 `map`는 아래와 같다.

```python
numbers = [1,2,3,4,5]
print(list(map(str, numbers))) # ['1', '2', '3', '4', '5']

string_it = ["processing", "strings", "with", "map"]
list(map(str.upper, string_it))
```

파이썬의 `map`함수는 여러 인자를 받을 수 있는데, 첫번째 인자는 자료형, 함수를 받을 수 있고,
두번째 인자부터는 반복가능한 iterable를 받는다.

```python
map(function, iterable[, iterable1, iterable2,..., iterableN])
```

`map` 함수를 조금 더 이해하기 위해 리스트에 있는 모든 숫자를 제곱하여 리스트로 반환하는 코드를 작성했다.
`map`함수를 쓰지 않고 for문만을 사용한다고 하면 아래와 같이 작성할 수 있다.

```python
numbers = [1,2,3,4,5]
squared = []

for num in numbers:
    squared.append(num ** 2)
print(squared) # [1, 4, 9, 16, 25]
```

위 코드를 `map`함수를 이용하여 코드를 작성한다고 하면, 아래와 같이 작성할 수 있다.

```python
def square(numbers):
    return numbers ** 2

numbers = [1,2,3,4,5]
squared = map(square, numbers)
print(list(squared)) # [1, 4, 9, 16, 25]
```

`square` 함수는 숫자를 인자로 받아서 제곱값을 반환하는 함수이다.  
`map(square, numbers)` 코드는 `square`함수를 `numbers` 리스트 각 요소에 적용하여 새로운 값을 반환하는 제너레이터 객체를 생성한다.
마지막으로 `list(squared)`는 `squared`를 리스트로 변환하고 출력한다.

### 여러개의 리스트를 map 함수에 적용하기

여러개의 리스트를 인자로 넣고 싶다면 아래와 같이 `lambda` 함수를 사용할 수 있다.

```python
numbers1 = [1, 2, 3, 4, 5]
numbers2 = [6, 7, 8, 9, 10]

squared = map(lambda x, y: x ** y, numbers1, numbers2)
print(list(squared)) # [1, 128, 6561, 262144, 9765625]
```

또는 함수를 이렇게도 사용가능하다.

```python
first_it = [1, 2, 3]
second_it = [4, 5, 6, 7]

list(map(pow, first_it, second_it)) # [1, 32, 729]
```

### filter함수와 map 함수 함께 사용하기

map함수는 filter함수와 짝궁으로 많이 사용하는데 아래와 같이 사용할 수 있다.

```python
def is_positive(num):
    return num >= 1

num_list = [0,1,2,3,0]
list(map(str, filter(is_positive, num_list))) # ['1', '2', '3']
```

### 🤔 what map object ?

`map`함수를 쓰다보면 아래와 같은 값을 많이 볼 수 있다.

```python
def square(numbers):
    return numbers ** 2

numbers = [1,2,3,4,5]
print(map(square, numbers)) # <map at 0x107c6d670>
```

`map`함수 사용 후 단순히 print를 찍어보면 객체로 떨어지는데 이건 왜 그런걸까? `map`이 객체를 반환하는 이유는 2가지가 있다.
첫번째는 지연평가(lazy evaluation)과 제너레이터(generator)를 사용하여 메모리를 효율적으로 사용하기 때문이다.

즉, `map`함수가 호출되면 `map` 객체가 생성되지만 실제로 함수가 실행되는 것은 `map` 객체를 이용하는 다른 함수가 호출될때까지 미뤄진다.
예를 들면 다음과 같이 `map`을 호출하여 사용하는 경우를 보자.

```python
squares = map(lambda x: x**2, [1, 2, 3, 4, 5])
```

이때 `squares`라는 `map`객체를 생성하지만, 실제로 `lambda` 함수가 싱실행되는 것은 `squares`객체를 이용하는 다른 함수가 호출될때까진 미뤄진다.

```python
print(list(squares))
```

따라서 위 코드 `squares`객체를 리스트로 변환하는 순간 `lambda`함수가 실행되어 각 요소의 제곱이 계산된다.
이렇게 하면, 메모리를 절약할 수 있고, 성능을 향상시킬 수 있다.
또한, `map` 객체는 `iterable`이므로, 필요할 때 순회하며 값을 계산할 수 있다. 또한 `filter`함수도 `map` 함수와 마찬가지로 지연평가를 지원한다.
