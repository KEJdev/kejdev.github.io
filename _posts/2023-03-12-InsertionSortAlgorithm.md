---
layout: post
title: 파이썬으로 구현하는 삽입 정렬(Insertion Sort)
date: 2023-03-12 09:00:00 +0300
category : Algorithm
use_math : true
---

## 🤚🏻 Insertion Sort(삽입 정렬)

삽입 정렬은 데이터 셋을 순회하면서 정렬이 필요한 요소를 뽑아내어 이를 다시 적당한 곳으로 삽입하는 방식이다. 

```python 
num_list = [0, 7, 5, 2, 8, 6, 1, 10, 3]

for list_idx in range(1, len(num_list)):
    element = num_list[list_idx]
    idx = list_idx - 1
    
    while idx >= 0 and num_list[idx] > element:
        num_list[idx+1] = num_list[idx] 
        idx -= 1
    num_list[idx+1] = element 
```

리스트의 두번째 요소부터 시작해서 그 이전의 요소들을 비교하는 파이썬 코드이며, 이전에 있던 정렬 알고리즘들과 다르게 삽입정렬 while문이 들어간다. (물론 while문 없어도 구현은 가능)  

하지만 while문을 사용하는 이유는 현재 위치에서 그 이전의 요소들을 전부 하나씩 비교하여 자신이 들어갈 위치를 찾아 삽입하기 때문에 대부분의 삽입 정렬에는 while문을 사용한다. 

#### 장점
* 구현이 간단하고 이해하기 쉬움
* 작은 데이터 세트에 대해 효율적인 알고리즘이며 데이터 세트가 이미 정렬되어 있을 경우에는 더욱 빠름
* Stable Sort이기 때문에 데이터가 동일한 값을 가지는 경우에도 순서가 바뀌지 않음

#### 단점
* 데이터 세트의 길이가 길어질수록 비효율적임
* 최악의 경우 데이터의 정렬이 역순으로 되어 있는 경우 모든 요소를 비교해야 하므로 $O(n^2)$의 시간복잡도를 가짐
* 제자리 정렬 아니기 때문에 추가적인 메모리 공간이 필요함s
