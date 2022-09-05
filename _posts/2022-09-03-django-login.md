---
layout: post
title: Django - 로그인 페이지 구현하기
date: 2022-09-04 00:00:00 +0300
category : ToyProject
use_math : true
---   
 
우선 최종적으로 구현된 로그인 페이지는 아래와 같습니다.   

![django4](/public/img/django4.png){: .center}

로그인 페이지에서 값 입력 후 `Login`을 누르면 `Home`으로 넘어가는 부분을 구현 해보도록 하겠습니다.  기본적으로 장고에서 로그인 기능을 제공해주기 때문에 로그인 폼을 가져오고 CSS를 입혀보겠습니다. 


## Settings

우선 [Django 라이브러리](https://django-crispy-forms.readthedocs.io/en/latest/template_packs.html#template-packs)를 설치합니다.

```
pip install django-crispy-forms
```

설치 후 아래와 같이 파일을 수정합니다.

```python
# settings.py

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'crispy_forms', # 추가 
    'accounts.apps.AccountsConfig', # 앱 추가 
]
```

## Login html

아래와 같이 `login.html` 을 만들었습니다.

```html
<link rel="stylesheet" href="static/css/style.css">
<div class="wrapper">
  <div class="form">
    <div class="title">
      Login
    </div>
    <form method="post">
      <div class="input_wrap">
        <span class="error_msg">Incorrect username or password. Please try again</span>
          {"%" csrf_token "%"}
          {"{"login_form"}"}
      </div>
      <button class="btn disabled input_wrap" style="padding: 15px" type="submit" >Login</button>
    </form>
      <p class="text-center">Don't have an account? <a href="/register">Create an account</a>.</p>
  </div>
</div>
```

위 코드에서 `{"%" csrf_token "%"}, {"{"login_form"}"}`에서 따옴표는 제거하고 사용해주세요.  
참고로 저는아래와 같은 파일구조로 되어 있습니다.

![django5](/public/img/django5.png){: .center}


## Login URL

전 첫 화면에 무조건 로그인 화면이 나오기를 바라기 때문에 아래와 같이 URL을 만들었습니다.

```python
from django.urls import path
from . import views

app_name = "accounts" 

urlpatterns = [
    path("", views.login_request, name="login"), # 로그인 페이지
    path("home/", views.home_request, name="home"), # 홈 화면 페이지 
    path("register/", views.register_request, name="register"), # 회원가입 페이지
]
```

## Login Form

`views.py`에 아래와 같이 코드를 추가합니다. 

```python
from django.shortcuts import render, redirect
from django.contrib.auth import login, authenticate
from django.contrib import messages
from django.contrib.auth.forms import AuthenticationForm


# 홈 화면 
def home_request(request):
    return render(request=request, template_name="main/home.html")

# 로그인 화면 
def login_request(request):
    if request.method == "POST":
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                messages.info(request, f"You are now logged in as {username}.")
                return redirect("/home")
            else:
                messages.error(request,"Invalid username or password.")
        else:
            messages.error(request,"Invalid username or password.")
    form = AuthenticationForm()
    return render(request=request, template_name="main/login.html", context={"login_form":form})
```

저는 로그인 성공되면 홈 화면이 나올 수 있도록 `redirect('/home')`으로 작성하였습니다.   

## Login CSS   

로그인 CSS는 아래와 같고, 만약에 아래의 CSS가 적용이 되지 않는다면, 경로 확인 부탁드려요~! 

```css
@import url('https://fonts.googleapis.com/css2?family=Jost:wght@400;700&display=swap');

*{
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Jost', sans-serif;
	outline: none;
	color: #000000;
}

body{
	background: linear-gradient(to right, #f4b661, #f16160);
}

.wrapper{
	min-height: 100vh;
	display: flex;
	justify-content: center;
	align-items: center;
}

.form{
	width: 425px;
	height: auto;
	background: #fff;
	padding: 35px 50px;
	border-radius: 2px;
}

.form .title{
	text-align: center;
	margin-bottom: 20px;
	font-weight: 700;
	font-size: 24px;
}

.form .input_wrap{
	margin-bottom: 20px;
	width: 325px;
	position: relative;
}

.form .input_wrap:last-child{
	margin-bottom: 0;
}

.form .input_wrap label{
	display: block;
	margin-bottom: 5px;
}

.form .input_wrap input{
	padding: 15px;
	width: 100%;
	border: 1px solid #bdc1c6;
	font-size: 16px;
	border-radius: 3px;
}

.form .input_wrap .input{
	background: #f5f4f4;
	padding-right: 35px;
}


.form .input_wrap .input:focus{
	border-color: #1dbf73;
}

.form .input_wrap .input_field{
	position: relative;
}

.form .input_wrap .btn{
	text-transform: uppercase;
	letter-spacing: 3px;
	color: #fff;
}

.form .input_wrap .btn.disabled{
	background: #F0F0F0;
}

.form .input_wrap .btn.enabled{
	background: #1dbf73;
	cursor: pointer;
}

.form .input_wrap .error_msg{
	font-size: 15px;
	margin-bottom: 5px;
	color: #f74040;
	display: none;
}
```

이제 로그인 화면이 완성되었고, 다음에는 회원가입 기능을 추가해보도록 하겠습니다. 
