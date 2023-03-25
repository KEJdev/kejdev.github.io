---
layout: post
title: 파이썬으로 구현하는 쉘 정렬(Shell Sort)
date: 2023-03-12 09:00:00 +0300
category : Algorithm
use_math : true
---

## 🥕 Shell Sort (쉘 정렬)

쉘 정렬은 삽입 정렬을 보완하여 만들어진 정렬 알고리즘이다. 배열을 일정한 간격(Gap)으로 분할한 후, 각 부분 리스트를 삽입 정렬을 이용하여 정렬하고 다시 간격을 줄여가면서 정렬를 반복한다. 

```python
def shell_sort(arr):
    n = len(arr)
    gap = 1
    while gap < n // 3:
        gap = gap * 3 + 1  # Sedgewick gap sequence

    while gap >= 1:
        for i in range(gap, n):
            temp = arr[i]
            j = i
            while j >= gap and arr[j - gap] > temp:
                arr[j] = arr[j - gap]
                j -= gap
            arr[j] = temp
        gap //= 3
    return arr 
```

간격이 1이 될때까지 while 루프를 반복하면서 일정한 가격만큼 떨어져 있는 요소끼리 비교하여 삽입 정렬을 수행한다. gap을 나누는 작업으로 간격을 점점 줄여나가며, 최종적으로 전체 배열이 정렬된다.


#### 장점 
* 삽입정렬보다 속도가 빠르다. 
* 안정 정렬(Stable Sort)이기 때문에 동일한 값에 대해 원래의 상대적인 순서로 유지
* 간격을 다양하게 선택하여 다양한 성능을 얻을 수 있음

#### 단점 
* 간격 선택에 따라 성능이 크게 달라지기 때문에 적절한 간격을 선택하지 않는다면 성능이 급격하게 저하될 수 있음
* 안정성을 보장하기 위해 불필요한 비교 연산이 필요할 수 있음
* 구현하기 상대적으로 복잡함 




