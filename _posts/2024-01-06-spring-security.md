---
layout: post
title: Spring Security 주요 기능 
date: 2024-01-06 00:00:00 +0000
category : Spring
---

## Spring Security란? 

Spring Security는 Java 애플리케이션, 특히 Spring 프레임워크를 사용하는 웹 애플리케이션의 보안을 담당하는 프레임워크이다. 개발하면서 보안쪽은 시간을 많이 쏟아야하는 부분 중 하나인데, Spring Security는 복잡함을 줄여주고, 보안을 쉽고 강력하게 만들어주는 도구라고 할 수 있다. 

제공하는 주요 기능은 아래와 같다.

* 인증(Authentication)
* 권한 부여(Authorization)
* CSRF 보호
* 세션관리
* 외부 인증(LDAP, OAuth2 등) 
* 보안 헤더 관리
* 사용자 정의 보안 기능

### 인증(Authentication)과 권한 부여(Authorization)

* 인증(Authentication) : 인증은 사용자가 누구인지 확인하는 과정이라고 보면 된다. 즉 사용자의 신원을 검증하는 것이 목적인데, 일반적으로 사용자의 이름과 비밀번호를 입력하는 것이 인증에 해당된다. 추가적으로 이중 인증(2FA)이나 MFA 같은 방법도 있다. 

* 권한 부여(Authorization) : 권한부여는 인증된 사용자가 시스템 내에서 어떤 리소스에 접근하거나 어떤 작업을 수행할 수 있는지를 정의한다. 예를 들어 사용자가 로그인 후 특정 페이지에 접근하려고 할 때, 그 사용자가 해당 페이지에 접근할 수 있는 권한이 있는지 확인하는 것이 권한 부여(Authorization)에 해당된다.   

즉, 인증은 '사용자가 누구인가'를 확인하려는 것이고, 권한 부여는 '사용자가 무엇을 할 수 있는가'를 결정하는 것이다. 보통 인증은 시스템에 처음 접근할때 수행되고, 권한 부여는 인증된 사용자가 특정 리소스에 접근하려 할 때 수행된다. 


### CSRF

CSRF(Cross-Site Request Forgery)는 웹 애플리케이션의 보안을 위협하는 공격 유형 중 하나이다.  

<aside>
  <span class="icon">🥕</span> 
  <div class="content">
    <p>은행 웹 사이트에 로그인해서 온라인으로 금융업무를 보고 있다고 가정하자.</p>
    <p>동시에 다른 탭에서 이메일 확인하고 있었는데, 친구가 보낸 것처럼 보이는 링크가 있어서 클릭했다. 만약 악의적인 목적으로 만들어진 것이라면 내가 모르는 사이에 '돈을 송금하는' 요청을 보낼 수 있다. </p>
    <p>왜냐하면, 이미 은행 사이트에 로그인해 있기 때문에 그 브라우저는 그 요청을 정상적인 것으로 간주하고 나의 로그인 정보를 함께 전송할 수 있다. 이것이 CSRF 공격의 핵심이다.</p>
  </div>
</aside>

CSRF 공격의 특징으로는 다음과 같다.  

* 공격은 사용자가 자신도 모르게 이루어지기 때문에 사용자는 자신이 공격을 도와주고 있다는 사실을 인지하지 못한다.  
* 인증된 사용자의 세션을 이용하여 악의적인 행위를 한다.  
* 사용자가 의도하지 않은 행동(송금, 비밀번호 변경 등)을 하도록 요청을 위장하여 보낸다. 

#### CSRF 공격은 어떻게 방지할 수 있을까?  

1. CSRF 토큰 사용 : 서버는 폼을 제출할 때마다 고유한 토큰을 생성하여 사용자가 이 토큰을 함께 제출핟록 한다.  
2. 세션 확인 : 사용자의 세션을 확인하여 요청이 같은 출처에서 온 것인지 검증한다.  
3. 사용자 인터랙션 요구 : 중요한 작업을 수행하기 전에 사용자 인터랙션(비밀번호 재입력, 캡차 등)을 요구한다.  
 

### Session  
Spring Security에서 제공하는 주요 세션 관리 및 보안 기능은 아래와 같다.  

1. 로그인 시 자동으로 새로운 세션을 생성하여 이전 세션 ID를 무효화시킨다.  
2. 사용자가 동시에 여러 세션을 열지 못하도록 제어한다.  
3. 특정 기간 동안 활동이 없는 세션을 자동으로 만료시키는 기능을 제공한다.  
4. 언제 새로운 세션을 생성할지 제어할 수 있다.   
5. CSRF 토큰을 세션에 저장하고 관리하여, CSRF 공격으로부터 보호한다.  


### 외부 인증(LDAP, OAuth2 등) 

Spring Security는 외부 인증 시스템과의 통합을 지원하며, 다양한 인증 방법을 제공한다. 

* LDAP (Lightweight Directory Access Protocol)  
네트워크상에서 사용자와 그룹 같은 디렉토리 정보를 관리하기 위한 프로토콜이다. 사용자 인증, 정보 검색, 조직 구조 관리 등에 보통 많이 사용되는데 예를 들어 직원들의 로그인 정보, 이메일 주소, 부서 정보 등을 중앙 집중화하여 관리한다. 기업이나 대학과 같은 조직에서 주로 사용된다.  


* OAuth2   
OAuth2는 외부 서비스 제공자를 통한 인증 및 권한 부여를 위한 표준 프로토콜이다. 다른 서비스(카카오, 네이버, 페이스북 등)의 인증을 통해 로그인하고 접근할 수 있게 해준다. 다들 많이 알다시피 소셜 로그인이나 타 서비스에 대한 권한 부여에 사용된다.  


## Spring Security Architecture

![Spring Security Architecture](/public/img/SpringSecurityArchitecture.png)

위 사진은 로그인 인증처리 과정이다.

1. AuthenticationFilter (UsernamePasswordAuthenticationFilter)
초기 요청이 들어오면, 이 필터는 사용자의 자격 증명(사용자 이름과 비밀번호)을 추출한다.

2. UsernamePasswordAuthenticationToken 생성
추출된 자격 증명을 이용해 UsernamePasswordAuthenticationToken(Token)을 생성한다.

3. AuthenticationManager에게 Token 전달
생성된 Token은 AuthenticationManager에 전달되어, 이 Token이 올바른 사용자에게서 온 것인지 확인한다.

4. AuthenticationManager와 AuthenticationProvider
AuthenticationManager는 하나 이상의 AuthenticationProvider (이하 A-Provider)를 사용하여 Token을 검증한다. 

5. UserDetailsService 호출
A-Provider는 UserDetailsService 구현 클래스를 호출하여, 해당 사용자에 대한 상세 정보를 요청한다.

6. UserDetails 반환
UserDetailsService 구현 클래스는 데이터베이스에서 사용자 정보를 조회하여 UserDetails 객체를 반환한다. 

7. 인증 정보 대조 및 검증
A-Provider는 UserDetailsService에서 반환된 UserDetails와 클라이언트가 제공한 Token을 대조한다. 이 과정에서 사용자의 자격 증명이 유효한지 확인한다. 

8. SecurityContext에 인증 정보 저장
사용자가 유효하다고 판단되면, 인증 정보는 SecurityContext에 저장된다. 이는 인증된 사용자의 정보를 보관하는 곳이다. 

9. 인증 완료
이렇게 인증 과정을 성공적으로 마치면, 사용자는 시스템에 안전하게 인증된 것으로 간주한다.

10. 이후 접근 제어 및 권한 부여
인증이 완료된 후, 사용자의 요청은 접근 제어 및 권한 부여 과정을 거쳐 처리된다. 