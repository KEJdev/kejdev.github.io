---
layout: post
title: Django - 프로젝트 생성하기
date: 2022-09-03 08:00:00 +0300
category : ETC
use_math : true
---   
 
이번 포스팅에서는 장고 프로젝트를 생성해보도록 하겠습니다. 


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
    '' # 앱이 있으면 이름 추가 
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
python ./LabelingTools/manage.py runserver
```

저는 앞으로 `python manage.py runserver` 라는 명령어 대신 `call run.bat`을 입력하면 장고가 실행됩니다.  

![django1](/public/img/django1.png){: width="60%" height="60%" }{: .center}


