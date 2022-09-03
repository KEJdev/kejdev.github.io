---
layout: post
title: Django - 프로젝트 생성 및 관리자 페이지 구현하기
date: 2022-09-03 09:00:00 +0300
category : ToyProject
use_math : true
---   

이번 토이 프로젝트는 Django기반의 라벨링툴을 개발하려고 합니다.  
우선 기초 공사부터 시작하겠습니다!! 이번 포스팅에서는 관리자 페이지 구현에 대해 다루어보겠습니다.   


## Django 프로젝트 생성  

장고가 설치되어 있지 않다면 아래 명령어로 설치해주세요.  

```
python -m pip install Django
```

프로젝트는 아래와 같이 생성합니다.

```
django-admin startproject LabelingTools
```

저는 `LabelingTools` 이라는 이름으로 프로젝트를 생성했습니다. 

### Django Setting 

처음에 세팅해야 하는 부분은 아래와 같습니다. 

```python
#settings.py
INSTALLED_APPS = [
    'django.contrib.admin',  
    'django.contrib.auth', 
    '' # 앱 이름 추가 
]

...

# LANGUAGE_CODE = 'en-us'
LANGUAGE_CODE = 'ko' # 한글로 보고싶으면 언어설정 해주기
```

프로젝트가 제대로 동작하는지 확인하려면 `manage.py` 파일이 있는 위치에서 아래와 같이 명령어로 실행합니다.

```
python manage.py runserver
```

![django1-1](/public/img/django1-1.png){: .center}

기본 포트는 8000번이지만, 포트를 변경하고 싶다면 아래와 같이 수정하여 사용할 수 있습니다.

```
python manage.py runserver 8080 
# 또는 
python manage.py runserver 0:8080 
```

추가로 매번 `python manage.py runserver`를 치는 것이 불편하여 bat파일을 작성해줍니다. 

```
@echo off
echo ===============Run Django===================
python ./labeling/manage.py runserver
```

저는 앞으로 `python manage.py runserver` 라는 명령어 대신 `call run.bat`을 입력하면 장고가 실행됩니다.  

![django1](/public/img/django1.png){: width="60%" height="60%" }{: .center}


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


가끔 관리자 인증 문제가 있어서 다른 컴퓨터로 pull 받고 실행이 안될 때가 있어서 `settings.py`에 아래 코드를 추가해줍니다.

```python
# settings.py
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
]
```

이제 어디서든 관리자 페이지에서 로그인이 가능합니다.  