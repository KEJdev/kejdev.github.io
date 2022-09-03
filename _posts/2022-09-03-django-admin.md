---
layout: post
title: Django - 관리자 페이지 구현하기
date: 2022-09-03 09:00:00 +0300
category : ToyProject
use_math : true
---   


이번 포스팅에서는 관리자 페이지 구현에 대해 다루어보겠습니다.   

## Django 관리자 페이지 

Django는 많은 기능을 제공하는데, 그 중 관리자 페이지도 기본적으로 제공됩니다.  
그렇기 때문에 많은 작업을 하실 필요는 없습니다.  

아래의 명령어를 실행해서 슈퍼유저를 생성합니다.  

```
python manage.py migrate 
python manage.py createsuperuser
```

Username, Email address, Password 입력까지 끝냈다면 http://127.0.0.1:8000/admin 으로 들어가면 아래와 같은 화면을 볼 수 있습니다.  

![django2](/public/img/django2.png){: width="60%" height="60%" }{: .center}

로그인하면 아래와 같은 화면을 볼 수 있으며 여기서 유저 추가, 유저 권한 부여도 가능합니다.  

![django3](/public/img/django3.png){: .center}


관리자 인증 문제가 있어서 다른 컴퓨터로 관리자 로그인이 안될 때가 있어서 `settings.py`에 아래 코드를 추가해줍니다.

```python
# settings.py
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
]
```

이제 어디서든 관리자 페이지에서 로그인이 가능합니다.  