---
layout: post
title: GitHub Actions으로 AWS CI/CD 구축하면서 만났던 에러 정리
date: 2024-09-26 00:00:00 +0900
category: ETC 
---


이번 백엔드 스터디를 진행하면서 AWS CI/CD를 구축하게 되었다. 금방 끝날꺼라 생각했던 구축이 금방 끝나지 않아서 당황스러웠다 ...
문제가 되었던 것은 스터디 초창기에 다같이 Git Repo 만들면서 prod setting은 전혀 고려하지 않아서 그랬던거 같다.  

<br>

기존에 Github Action, ECR, EC2 등 스터디를 진행하면서 만든 것들이 있어서 우선 메인 브랜치를 EC2에 배포했는데, 아래와 같은 에러가 났다. 

<br>

> [2024-09-17 09:43:09] [ERROR] [main] --- [TomcatStarter-60] - Error starting Tomcat context. Exception: org.springframework.beans.factory.UnsatisfiedDependencyException. Message: Error creating bean with name 'jwtAuthenticationFilter': Unsatisfied dependency expressed through field 'jwtTokenUtil': Error creating bean with name 'jwtTokenUtil' defined in URL [jar:nested:/app.jar/!BOOT-INF/classes/!/com/meowdev/echo/common/jwt/JwtTokenUtil.class]: Unsatisfied dependency expressed through constructor parameter 0: Error creating bean with name 'jwtProperties': Invocation of init method failed

<br>

로그를 보면 Jwt 관련해서 빈 생성 시 문제가 났다고 이야기하고 있다. 분명 application.yml에 아래와 같이 설정을 올바르게 했는데 왜 저런 에러가 나는걸까?  

<br>

> jwt:  
  access-token-key: ${ACCESS_TOKEN_KEY}  
  refresh-token-key: ${REFRESH_TOKEN_KEY}  

<br>

### 문제 찾기  

테스트로 application.yml에 환경변수 대신 직접 토큰값을 넣었는데 같은 에러가 발생했다. 의문을 갖고 JwtProperties.java에 직접 주입을 했더니 다른 에러가 나오긴 하지만, jwt 관련 에러는 더이상 뜨지 않았다.  
이상함을 느껴 다음으로 나온 에러를 살펴보니 application.yml에 있는 또 다른 환경 변수를 못 찾고 있는 것을 발견했다. 

<br>

근본적인 원인은 Github Action 일것이다. ECR에 배포는 정상적으로 잘 되었고, EC2에서 spring이 런타임 에러가 나는걸 보아하니 Git Action 과정 중에 에러는 나지 않았지만 무언가 문제가 생긴 것! 나는 테스트를 위해 많은 커밋을 날렸고 덕분에 application.yml을 읽지 못하는 원인을 발견했다. 

<br>

![github-action-1](/public/img/github-action-1.png)

<br>

내가 해결해야 될 것은 "Error: Could not parse file ~~" 에러였는데 내용은 아래와 같다.  

<br>

> Error: Could not parse file: ./application.yml
JSON parse error: SyntaxError: No number after minus sign in JSON at position 1
XML parse error: Error: Incomplete documentYAML parse error: YAMLException: expected a single document in the stream, but found more


<br> 

### 해결

<br> 

뭔가 에러가 이상하지 않는가! 눈치 100단이라면 바로 알겠지만... 그렇다! application.yml의 위치가 이상하다. 초창기 정말 스터디용으로 만들었던 프로젝트였기 때문에 누군가 application.yml을 그냥 루트에 생성해놨는데 이것이 문제가 되었다. 생각해보자. **application.yml의 위치는 어디로 해야 애플리케이션 기동시 읽을까?**   
잊지말자. application.yml은 src/main/resources에 넣어두기...약속..! ^0^*

<br> 

이왕 이렇게 된 김에 application.yml / application-local.yml / application-prod.yml 이렇게 파일을 구분해서 src/main/resources에 넣고 다시 배포했더니 잘된다.  

<br> 

다음 문제는 사실 문제 측에도 속하지 않지만 ... 메모리 문제였다.  

<br> 

```
services:
  spring:
    image : ######.dkr.ecr.ap-northeast-2.amazonaws.com/######:latest

  mysql:
    image: mysql

  redis:
    image: ######

```

<br> 

위에는 현재 사용 중인 도커 컴포즈의 일부인데, 현재 프리티어로 무료로 쓸수 있는 t2.micro 인스턴스를 사용하다보니 인스턴스가 터진다. ec2는 멈췄고 ec2 재시작을 2~3번 했던거 같다. 실제 서비스를 위해 나중에는 t2.micro말고 다른 인스턴스로 갈아타야되지만 아직 1차 개발도 완료 못한 상황에서 돈이 추가로 더 나오는 인스턴스로 바꾸고 싶지는 않았다. 고민 끝에 Swap Memory 메모리를 늘렸다.   

<br> 

>sh-5.2$ free -h   
               total        used        free      shared  buff/cache   available  
Mem:           949Mi       224Mi       398Mi        17Mi       326Mi       566Mi   
Swap:            9Gi       470Mi       9.5Gi

<br> 

AWS EC2 t2.micro 기본 스펙은 1G Ram, 8G Storage인데 무료로 사용할 수 있는 Storage는 30G라서 10G정도 늘려줬더니 아주 잘돌아간다. ㅎㅎ! 

<br> 

메모리를 늘려서 아주 잘 돌아갔는데 다음엔 DB 에러다. 

<br> 

> The last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server.
        at com.mysql.cj.jdbc.exceptions.SQLError.createCommunicationsException(SQLError.java:175)
        at com.mysql.cj.jdbc.exceptions.SQLExceptionsMapping.translateException(SQLExceptionsMapping.java:64)
        at com.mysql.cj.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:819)
        at com.mysql.cj.jdbc.ConnectionImpl.<init>(ConnectionImpl.java:440)
        at com.mysql.cj.jdbc.ConnectionImpl.getInstance(ConnectionImpl.java:239)
        at com.mysql.cj.jdbc.NonRegisteringDriver.connect(NonRegisteringDriver.java:188)
        at com.zaxxer.hikari.util.DriverDataSource.getConnection(DriverDataSource.java:138)
        at com.zaxxer.hikari.pool.PoolBase.newConnection(PoolBase.java:359)
        at com.zaxxer.hikari.pool.PoolBase.newPoolEntry(PoolBase.java:201)
        at com.zaxxer.hikari.pool.HikariPool.createPoolEntry(HikariPool.java:470)
        at com.zaxxer.hikari.pool.HikariPool.checkFailFast(HikariPool.java:561)
        at com.zaxxer.hikari.pool.HikariPool.<init>(HikariPool.java:100)
        at com.zaxxer.hikari.HikariDataSource.getConnection(HikariDataSource.java:112)
        at org.quartz.utils.HikariCpPoolingConnectionProvider.getConnection(HikariCpPoolingConnectionProvider.java:180)  

<br> 

해당 에러와 관련해서 검색하면 많은 에러 해결법들이 나오는데, 결론적으로는 나에게는 해당되지 않는 해결법들 이였다.ㅠㅠ   

### 문제 찾기  

<br> 

스프링 컨테이너에서 MySQL 컨테이너를 핑으로 찍고, 반대로도 핑 찍었는데 이상이 없었다. 통신에 문제가 없음을 확인 했고 다음으로 로그를 하나씩 파헤쳤다. 중간에보면 SQL 에러라고 뜨는데 원인이 정말 SQL에러가 맞긴했다. **MySQL5.7과 MySQL8.0의 차이가 뭘까요?** MySQL 8.0부터는 데이터의 정확성이나 무결성을 보장하기 위해 엄격해졌다. 그래서 이전 버전에서 허용했던 쿼리나 설정들이 8.0에서는 오류를 발생시킬 수 있다. 

<br>

### 해결

<br> 

> database-platform: org.hibernate.dialect.MySQL8Dialect  
    hibernate:  
      ddl-auto: validate  

<br> 

application.yml에서 ddl-auto를 위처럼 수정/실행하면 아래의 로그처럼 어떤 테이블에서 어떤 컬럼이 문제인지 친절하게 로그로 뱉어줘서 ...  빠르게 찾을 수 있다. 

<br> 

> Schema-validation: wrong column type encountered in column [policy_type] in table [policy_agree];   
found [varchar (Types#VARCHAR)], but expecting [enum ('required_is_over_fourteen','required_terms_of_service',
'required_personal_info_process','option_personal_info_marketing','option_event_mail_or_sms') (Types#ENUM)]

<br> 

근데도 에러가 나길래 중간 로그를 잘 보니 "quartz"라는 단어가 보였다. 

<br> 

> [ERROR] [QuartzScheduler_QuartzScheduler-8aa1fba235c51726634208572_MisfireHandler] --- [JobStoreTX-4017] - MisfireHandler: Error handling misfires: Failed to obtain DB connection from data source 'echo': com.mysql.cj.jdbc.exceptions.CommunicationsException: Communications link failure
The last packet sent successfully to the server was 0 milliseconds ago. The driver has notreceived any packets from the server.
org.quartz.JobPersistenceException: Failed to obtain DB connection from data source 'echo': com.mysql.cj.jdbc.exceptions.CommunicationsException: Communications link failure
The last packet sent successfully to the server was 0 milliseconds ago. The driver has notreceived any packets from the server.
        at org.quartz.impl.jdbcjobstore.JobStoreSupport.getConnection(JobStoreSupport.java:

<br> 

기억이 가물가물해서 quartz도 뭐 설정했던가... 하고 찾아보니 quartz.properties 파일이 있었고 여기서도 로컬 설정으로 되어 있길래 quartz-local.properties / quartz-prod.properties 등으로 수정하고 변경했다.

<br> 


이외에도 방화벽 설정이나 다른 설정 문제들 등, 다른 에러들이 더 있었던거 같은데 기억에 남는 에러는 이것뿐이라 이렇게 정리해본다. 



