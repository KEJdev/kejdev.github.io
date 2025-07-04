---
layout: post
title: 간단한 줄 알았던, 알림 시스템 구조 둘러보기
date: 2025-07-01 00:00:00 +0900
category: ETC
---

흔히 생각하는 알림은 일정 시간마다 체크하거나 조건이 맞으면 알림을 주는 시스템이라고 생각하기 쉽다. 그래서 대부분 스케줄러나 배치 처리로 구현한다고 생각할 수 있다.  
하지만 알림의 목적은 "어떤 조건을 만족하는 이벤트가 발생했을 때, 사용자가 빠르게 인지하도록 알림을 주는 것"이다.  
이 목적을 만족시키려면 "얼마나 빠르게 조건을 감지하고, 알림을 줄 수 있느냐?"가 중요하다. 
그래서 알림 시스템은 단순히 모바일 푸시 알림(mobile push notification)에 한정되지 않는다. 
오늘은 알림을 전달하는 채널(수단)에 대해서 이야기를 하려고 한다. 대표적으로 알림은 모바일 푸시 알림/ SMS 메시지/ 이메일 3가지로 분류할 수 있다.   

* 모바일 푸시 알림 
    * 앱 설치된 사용자에게 푸시 전송
* SMS 메시지 
    * 문자 메시지 
* 이메일 
    * 이메일 수신함


### 알림 시스템 설계 시, 실시간성을 고려하는 이유
단순히 "하루에 한 번 체크해서 보내는 알림" 이라면 배치로도 충분하다. 하지만 다음과 같은 상황이라면 실시간 처리가 필요하다.  

* 로그인 실패 5회 또는 다른 지역에서 로그인 발생 시 → 보안 알림
* 서버 CPU 사용률이 90%를 넘었을 때 → 즉시 알림 
* 특정 임계값을 넘눈 순간 → 순간 알림

이럴 땐, 이벤트 기반(Event-driven) 아키텍처, 메시지 큐, 스트림 처리 등을 도입하게 된다.  그래서 알림의 목적과 민감도에 따라 적절한 선택이 필요하다.  

* 배치 처리 (Batch)  
    * 주기적으로 데이터를 모아서 한꺼번에 처리한다.
        <aside>
        <span class="icon">🥕</span> 
        <div class="content">
        <p>예를 들면, 매일 밤 12시에 조건에 맞는 유저에게 알림 발송한다.</p>
        </div>
        </aside>
* 연성 실시간 (Soft Real-Time)
    * 가능한 알림을 빨리 전달하되(실시간), 시스템에 높은 부하가 걸렸을 때, 약간의 지연을 허용하는 시스템을 말한다.
        <aside>
        <span class="icon">🥕</span> 
        <div class="content">
        <p>예를 들면, 1~5분 안에 이벤트 감지 후 알림 발송한다.</p>
        </div>
        </aside>
* 실시간 처리 (Real Time)  
    * 데이터가 도착하자마자 조건 확인 및 알림 처리
        <aside>
        <span class="icon">🥕</span> 
        <div class="content">
        <p>예를 들면, 거래 이상 징후 발생 시 즉시 알림된다.</p>
        </div>
        </aside>


### 알림 메커니즘 

1. iOS 푸시 알림   
iOS에서 푸시 알림을 보내기 위해서는 세 가지 컴포넌트가 필요하다.   

    * 알림 제공자(Provider)
        *  말 그대로 알림을 만들어서 보내는 주체를 말한다. 보통 서버(API 서버, 백엔드 서버)가 이 역활을 담당한다. 알림 제공자는 "새로운 메시지가 도착했어요!" 라는 알림 내용을 만들고, 이 알림을 Apple의 푸시 서버(APNS)에 전달한다.  
    * APNS(Apple Push Notification)  
        * APNS는 Apple이 운영하는 공식 푸시 알림 전송 서버이다. 모든 iOS 푸시 알림은 이 APNS를 거쳐서 iPhone에 도착하게 된다. 알림 제공자가 보내온 알림을 받아서, 등록된 iOS기기 (토큰 기반)로 정확하게 전달한다.  
        * APNS는 일종의 우체국 역활이라고 생각하면 된다. 알림 제공자가 보낸 "편지(알림)"을 받아서 아이폰이라는 "수신자"에게 정확하게 전달한다.  
    * iOS 단말  
        * 알림을 받는 주체는 사용자 iOS 기기이다. 기기는 사전에 APNS에 등록되어 디바이스 토큰이라는 고유 ID를 갖고 있고, 이 토큰을 기준으로 해당 기기로 푸시 알림을 전송한다.  

    그래서 iOS 푸시 알림을 전체적으로 정리하면 아래와 같다.
    <aside>
    <span class="icon">🥕</span> 
    <div class="content">
    <p>예시 상황</p>
    <p>사용자가 인스타그램에서 댓글을 달았다면 어떻게 알림이 울릴까?</p>
    <p>1. 알림 제공자(인스타 서버)가 "댓글이 달렸어요!" 라는 메시지를 생성한다.</p>
    <p>2. 이 메시지를 APNS에 전달한다. </p>
    <p>3. APNS는 해당 사용자 iPhone에 푸시 알림을 전송한다.</p>
    <p>4. 사용자는 실시간으로 알림을 받는다. </p>
    </div>
    </aside>

2. 안드로이드 푸시 알림  
안드로이드 푸시 알림도 비슷한 절차로 전송된다. APNS 대신 FCM(Firebase Cloud Messageing)을 사용한다는 점만 다르다.  

3. 이메일  
이메일은 단순히 "보내는 역활"만 하는게 아니라, 전송 후의 데이터까지 분석할 수 있다. 

* 이메일 발송자 (Email Provider)
    * 보통 서비스 단에서 유저들에게 전송하는 서비스를 말한다. 
        <aside>
        <span class="icon">🥕</span> 
        <div class="content">
        <p>예를 들어, 유저가 회원가입을 완료했을 때, "가입을 축하합니다" 이메일을 보내는 주체다. </p>
        </div>
        </aside>
* 이메일 전송 플랫폼 (SendGrid, Mailchimp 등)
전송뿐만 아니라 전송 성공률과 발송 결과를 추적하는 기능을 제공하는 플랫폼들이 있다. 
    * 이메일이 받는 사람의 스팸함이 아닌, 받은 편지함으로 도착하도록 최적화 작업을 진행한다. 
    * 이메일이 제대로 도착했는지, 이메일을 열었는지, 반송되었는지를 추적할 수 있다. 

### 알림을 보낼 때, 필요한 개인정보 

알림을 보내려면, 모바일 단말 토큰, 전화번호, 이메일 주소 등 정보가 필요하다. 보통 앱을 설치하거나 계정을 등록하게 되면, 서버는 해당 사용자 정보를 수집하여 데이터 베이스에 저장한다. 


### 데이터 손실 방지 

알림 전송 시스템에서 가장 중요한 것 중 하나는 어떤 상황에서도 알림이 소실되면 안된다는 것이다. 알림이 지연되거나 순서가 틀려도 괜찮은 경우가 많지만, 사라지면 매우 곤란하다. 그래서 전송에 실패할 경우 모니터링을 통해 재시도 하는 매커니즘을 추가해야 한다.    

그리고 같은 알림이 여러번 반복되는 것도 어느정도 방지를 해야하기 때문에 중복 전송 방지 매커니즘이 필요하다. 하지만 분산 시스템의 특성상 가끔은 같은 알림이 중복되어 전송이 일어나긴 하지만, 그 빈도를 줄이는 것이 중요하다. 왜냐하면 사용자가 알림 기능을 아예 꺼 버릴 수도 있기 때문에 주의해야 한다. 


### 푸시 알림과 이메일 알림, 왜 속도 차이가 날까?

푸시 알림은 "푸시 기반"으로 동작한다.   
* 앱 서버(Firebase, APNS 등)가 **즉시 전송 요청**을 보내는데, 이게 가능한 이유는 사용자의 기기에서 항상 대기 중이기 때문에 즉각적으로 알림을 수신할 수 있기 때문이다.    

<aside>
<span class="icon">🥕</span> 
<div class="content">
<p>알림을 받는 기기가 실시간 연결 상태(소켓 or 알림 채널)로 대기하고 있기 때문에 빠르다. 예를 들면 카톡, 앱 이벤트 등이 있다.</p>
</div>
</aside>

반대로 이메일 알림은 "풀링(Polling) 기반"으로 동작한다.  
* 메일은 직접 메일 서버에 접속해서 "새 메일 있나요?"라고 주기적으로 확인하는 방식이기 때문에 푸쉬 방식보다는 느리다. 


### 기기별 알림이 다르게 울리는 이유는 무엇일까 ?  

알림은 동기화를 시도하지만, 기기별로 정책이 다르다. 예를 들어, 휴대폰에서 알림을 먼저 읽으면 워치에서 안울린다던가 하는 것이 있다. 또한 우선순위 설정 기능도 있는데, 예를들어 아이폰이 잠겨 있으면 워치로 먼저 알림을 전송하는 식이 있다. 


### 갤럭시와 아이폰, 서로 알림 속도가 다른 이유는 무엇일까?  

안드로이드는 자체 푸시 서버를 사용하기 때문에 시스템에서 비교적 느슨하게 관리한다. 반면에 iOS는 반드시 APNS를 거쳐야하고, 알림 권한, 집중 모드, 워치 연동까지 관여하기 때문에 같은 카톡 알림인데도 iOS에서는 더 늦게 울리는 경우가 있다.  

