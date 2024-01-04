---
layout: post
title: Hibernate Multi Tenancy
date: 2024-01-03 00:00:00 +0000
category : Spring
---

## Multi Tenancy

멀티 테넌시는 하나의 애플리케이션 인스턴스가 여러 고객이나 조직(테넌트)을 동시에 서비스할 수 있게 하는 아키텍처이다. 주로 **클라우드 애플리케이션, SaaS모델에서 중요하게 다루는 개념**이며, 리소스와 비용을 효율적으로 사용하기 위해 널리 채택되고 있다. 

<aside>
  <span class="icon">🥕</span> 
  <div class="content">
    멀티-테넌시(Multi-Tenancy) 개념을 적극 활용하는 대표적인 SaaS 프로그램은 Microsoft Office 365, AWS,Shopify 등이 있다.
  </div>
</aside>

멀티 테넌시 아키텍처는 각 테넌트의 데이터를 안전하게 격리하면서도, 하드웨어와 소프트웨어 리소스는 여러 테넌트 간에 최대한 많이 공유하여 운영 효율성을 높이는 것을 목표로한다. 따라서 데이터 분리, 리소스 공유 이 두가지 주요 원칙을 잘 알고 있어야 한다.

1. 데이터 분리 : 멀티-테넌시 환경에서는 각 테넌트(고객이나 조직)의 데이터는 서로 분리되어 있어야 한다. 보안과 프라이버시를 보장하기 위해서며, 각 테넌트는 자신의 데이터에만 접근할 수 있어야 하며 다른 테넌트의 데이터에는 접근할 수 없어야 한다.  

2. 리소스 공유 : 멀티-테넌시는 효율성과 경제성을 위해 서버, 스토리지, 네트워크와 같은 인프라 리소스를 여러 테넌트 간에 공유한다. 이 공유는 비용 절감과 관리의 용이성을 가져오며 클라우드 기반의 SaaS 서비스에서 특히 중요하다. 


<aside>
  <span class="icon">🥕</span> 
  <div class="content">
    대표적인 SaaS, Amazon Web Services (AWS)를 예로 들어보자. 
    <p>데이터 분리 : AWS에서 각 고객은 자신만의 가상 환경(예: Amazon EC2 인스턴스, S3 버킷)을 갖고, 이 가상 환경은 다른 고객과 완전히 분리되어 있어, 각 고객의 데이터는 안전하게 격리함</p>
    <p>리소스 공유 : AWS의 물리적 인프라 - 데이터 센터, 서버, 스토리지 시스템 등은 여러 고객에 의해 공유함</p>
  </div>
</aside>

멀티 테넌트 환경에서 데이터를 분리하는 3가지 주요 패턴이 있다. 

1. 테넌트를 데이터베이스 단위로 분리한다. (데이터베이스 단위 분리)
  * 각 테넌트(고객이나 조직)마다 별도의 데이터 베이스를 가진다.
  ![tenancy-1](/public/img/tenancy-1.png)
  * 예를 들어 테넌트 A,B,C가 있다면 각각에 대해 별도의 데이터베이스 A_DB, B_DB, C_DB가 생성되며 각 데이터 베이스는 완전 독립적이며 데이터 간의 격리가 완벽하다. 
  * 단점으로 보안과 격리에는 우수하지만, 데이터베이스를 각각 관리해야 하므로 관리 복잡성과 비용이 증가 할 수 있다.  
2. 테넌트를 스키마 단위로 분리한다. (단일 데이터베이스, 별도 스키마)
  * 하나의 데이터베이스 내에 여러 스키마를 생성하고, 각 테넌트에게 하나의 스키마를 할당한다.
  ![tenancy-2](/public/img/tenancy-2.png)
  * 각 테넌트의 데이터는 별도의 스키마에 저장되므로, 테넌트 간의 데이터는 물리적으로 분리된다.
  * 이 방법은 데이터베이스 단위 분리보다 관리가 쉬우나, 데이터베이스 자체가 공유되기 때문에 하나의 테넌트에서 트래픽이 몰릴 경우 다른 테넌트에 영향을 끼칠 수 있다. 
3. 모든 테넌트 데이터가 동일 테이블에 저장되고 tenant_id 컬럼 기준으로 데이터를 분리한다. (단일 데이터베이스, 공유 스키마)
  * 모든 테넌트의 데이터가 하나의 데이터베이스 스키마 내의 같은 테이블에 저장된다. 
  ![tenancy-3](/public/img/tenancy-3.png)
  * 각 데이터 행에는 테넌트를 식별할 수 있는 고유한 식별자(tenant_id)가 포함된다. 
  * 쿼리나 애플리케이션 레벨에서 이 tenant_id를 사용하여 각 테넌트의 데이터를 구분한다.
  * 가장 경제적이고 관리하기 쉽지만, 데이터 격리 수준이 가장 낮으며, 보안이 크게 중요한 경우에는 적합하지 않다. 
  * 멀티 테넌트 아키텍처에 의존하는 비즈니스 로직 작성을 할 수밖에 없다. (쿼리에서 WHERE절에 tenantId =? 와 같은 절을 항상 포함해야 함) 

<aside>
  <span class="icon">🥕</span> 
  <div class="content">
    대표적인 SaaS, Amazon Web Services (AWS)를 예로 들어보자. 
    <p>데이터 단위 분리 : 데이터 격리 수준이 가장 높지만, 비용과 관리의 복잡성이 증가하는 이 방법은 Amazon RDS가 대표적인 서비스이다.</p>
    <p>스키마 단위 분리 : 관리가 더 용이하고 비용 효율적이지만, 데이터베이스 단위 분리보다는 격리 수준이 약간 낮은 이 방법은 Amazon RDS의 PostgreSQL 또는 MySQL가 대표적인 서비스이다. </p>
    <p>단일 데이터베이스 : 데이터 관리의 효율성과 확장성이 뛰어나지만, 데이터 격리 수준은 상대적으로 낮은 이 방법은 Amazon DynamoDB가 대표적인 서비스이다. </p>
  </div>
</aside>

간단하게 예시 코드(단일 데이터베이스, 공유 스키마)를 보자. 이 코드는 각 HTTP 요청에 포함된 테넌트 식별자를 사용하여 현재 테넌트의 컨텍스트를 설정하고, 요청 처리가 완료된 후에 이를 제거하는 코드이다. 

```yaml
spring:
  jpa:
    hibernate:
      multiTenancy: DATABASE
      tenant_identifier_resolver: com.example.MyCurrentTenantIdentifierResolver
      multi_tenant_connection_provider: com.example.MyMultiTenantConnectionProvider
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL5Dialect
        show_sql: true
```

우선 파일에서 멀티-테넌시 관련 설정을 추가하고, 아래 코드처럼 스프링 시큐리티 컨텍스트 또는 요청 세션에서 테넌트 ID를 가져온다. 

```java
public class MyCurrentTenantIdentifierResolver implements CurrentTenantIdentifierResolver {

    @Override
    public String resolveCurrentTenantIdentifier() {
        // 현재 스레드에서 테넌트 ID를 가져옴
        return TenantContext.getCurrentTenant();
    }

    @Override
    public boolean validateExistingCurrentSessions() {
        return true;
    }
}
```

MultiTenantConnectionProvider 인터페이스를 구현하여 각 테넌트에 대한 데이터베이스 연결을 관리한다. 

```java
public class MyMultiTenantConnectionProvider implements MultiTenantConnectionProvider {

    @Override
    public Connection getAnyConnection() throws SQLException {
        // 데이터베이스 연결 반환
        return dataSource.getConnection();
    }

    @Override
    public void releaseAnyConnection(Connection connection) throws SQLException {
        connection.close();
    }

    @Override
    public Connection getConnection(String tenantIdentifier) throws SQLException {
        final Connection connection = getAnyConnection();
        // 테넌트 식별자를 사용하여 연결 설정
        connection.setSchema(tenantIdentifier);
        return connection;
    }

    @Override
    public void releaseConnection(String tenantIdentifier, Connection connection) throws SQLException {
        connection.setSchema(DEFAULT_TENANT);
        releaseAnyConnection(connection);
    }

    // 기타 ......
}

```

```java
@Component
public class TenantInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String tenantId = request.getHeader("X-TenantID");
        TenantContext.setCurrentTenant(tenantId);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        TenantContext.clear();
    }
}
```

그리고 아래 코드 처럼 인터셉터 등록하면, 각 요청이 처리되기 전에 테넌트 ID가 설정되며, 요청이 완료된 후에 해당 정보가 제거된다. 

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    TenantInterceptor tenantInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(tenantInterceptor);
    }
}

```

------
reference 

*  [https://jaimemin.tistory.com/2270](https://jaimemin.tistory.com/2270)
* 이미지 출처 : [https://callistaenterprise.se](https://callistaenterprise.se/blogg/teknik/2020/09/19/multi-tenancy-with-spring-boot-part1)