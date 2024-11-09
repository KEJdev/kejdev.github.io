---
layout: post
title: "[오늘의 집 클론코딩] 간편 회원가입, 자체 회원가입 Table 만들기"
date: 2024-01-13 00:00:00 +0000
category: SideProject
---


현재 하고 있는 [스터디](https://github.com/MeowDevelopers)에서 오늘의 집 클론 코딩을 진행하고 있다. 원래는 사이드 프로젝트를 진행하려고 했으나 아직까지 뚜렷하게 "이 주제로 프로젝트 진행하자!" 하는 주제가 없어 클론 코딩을 먼저 하면서 사이드 프로젝트 주제를 잡아가기로 했다.( 어차피 회원가입이나 시큐리티 등 기본 뼈대는 만들어야 되서..)

클론 코딩이라고 하지만, "단순한 기능을 따라 만들겠다." 라기 보다는 해당 기능을 왜 이렇게 기획했고 의도했고 구현했는지에 대해 분석하면서 구축하고 있다.

## 오늘의 집 회원가입 페이지

![today-house-1](/public/img/today-house-1.png)

오늘의 집 회원가입은 위 이미지와 같이 되어 있다.  
이미지를 보면 알겠지만 간편 회원가입(소셜 로그인)과 자체 회원가입을 지원하는 형태이다. 오늘의 집을 사용해본 사람이라면 알겠지만, 오늘의 집의 회원가입 정책은 아래와 같이 확인되었다.

1. 소셜 로그인 3개(카카오, 페이스북, 네이버)와 자체 회원가입은 이메일만 다르다면, 1명 유저당 여러개의 계정을 만들 수 있다.
2. 자체 회원가입은 다른 이메일을 쓰면 중복 계정을 보유할 수 있다.
3. 기존 계정이 있다면 "기존 계정으로 로그인"으로 유도 하거나 "다른 방식으로 가입"으로 처리한다.

### 트레이드오프

오늘의 집의 회원가입 정책을 보면 장단점이 분명하게 보인다. 아래와 같이 유저 시나리오가 있다고 가정해보자.

1. 유저가 물건을 구매하기 위해 카카오 간편 회원가입을 진행한다.
2. 가구를 구매한다.
3. 포인트가 쌓인다.
4. 시간이 좀 흐르고 다시 가구를 구매하러 로그인을 시도한다.
5. 유저가 카카오 간편가입한 부분이 생각이 안나 네이버 간편 가입을 누른다.
6. 유저는 카카오와 네이버 2개의 중복 계정이 생긴다.
7. 유저는 의문점을 가진다. 내가 이전에 가입한 가구내역이랑 포인트는 어디있을까?
8. 유저는 문의를 남겨서 가구 내역과 포인트를 문의한다.
9. 상담사 리소스를 써가며 유저에게 답변과 함께 계정이 중복인걸로 확인된다고 알려준다.

많은 사용자들이 자신의 계정 정보를 잊어버리는 경우가 많고, 이와 관련하여 문의를 해오는 경우가 잦다. 중복 계정 기능을 도입하면 사용자 편의성이 증가할 수 있지만, 이로 인해 상담 직원이 추가적인 리소스를 투입해야 하는 트레이드오프가 존재한다. 또한 이러한 문의나 유저의 시간 투자는 서비스 이용에 대한 부정적인 영향을 주기 때문에 적절한 조치가 필요하다.

중복 가입을 방지하고 가입 수단을 여러개 넣으러면 어떻게 해야될까 ?  
주로 사용하는 방법은 전화번호 인증이 있다. CI값은 고유하기 때문에 사용할 수 있겠지만, CI값을 획득하는 절차가 유저 편의성을 해치기 때문에 좋은 방식이 맞는가에 대해 생각해보게 된다.

## 유저 테이블

현재 구현된 유저 테이블v1은 아래와 같다.

```sql
DROP TABLE IF EXISTS user;
CREATE TABLE user
(
	user_id 		bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '아이디',
	user_email 		varchar(100) NULL UNIQUE COMMENT '이메일',
	user_profile            longtext NULL COMMENT '유저 프로필 이미지',
	user_password  		varchar(255) NULL COMMENT '패스워드',
	user_type               varchar(30) NOT NULL default 'user' COMMENT '사용자 타입(사용자, 관리자)',
	user_nickname 		varchar(30) NOT NULL UNIQUE COMMENT '유저 닉네임',
	provider_type           varchar(30) NOT NULL COMMENT '로그인 타입(KAKAO, NAVER, Facebook, Origin)',
	provider_key            varchar(255) NOT NULL UNIQUE COMMENT '로그인 타입에 따른 식별값',
	created_at 		datetime NOT NULL COMMENT '유저 회원가입 생성일',
	modified_at             datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '유저 정보 수정일',
	user_last_login_date    datetime NOT NULL COMMENT '유저 마지막 로그인 일자',
	deleted                 boolean NOT NULL default false COMMENT '회원탈퇴 여부',
	dormancy	        boolean NOT NULL default false COMMENT '유저 휴면 여부',
	INDEX idx_email (user_email) COMMENT '유저 이메일 인덱싱',
	INDEX idx_nickname (user_nickname) COMMENT '유저 닉네임 인덱싱',
	INDEX idx_provider_key (provider_key) COMMENT '유저 식별값'
) ENGINE = InnoDB
DEFAULT CHARSET = utf8mb4
COMMENT = '유저 테이블';
```

아직 넣어야 할 부분도 많고 일단 자체 회원가입 기준으로 만들었기 때문에 개발하면서 수정은 많이 할 것 같다. 참고로 user email부분은 지금 내가 소셜 로그인 동의항목에서 현재 강제로 이메일을 받을 수 없는 상황이기에 null 허용으로 수정했다. ㅠㅠ

### User Domain

```java
package com.example.be_study.service.user.domain;

import com.example.be_study.service.base.AbstractBaseUserDeleteEntity;
import com.example.be_study.service.user.enums.ProviderType;
import com.example.be_study.service.user.enums.UserType;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@Entity
@Table(name = "user")
@NoArgsConstructor
public class User extends AbstractBaseUserDeleteEntity {
    @AttributeOverride(name = "id", column = @Column(name = "user_id"))

    @Column(name = "user_profile", nullable = true)
    private String userProfile;

    @Column(name = "user_email", nullable = true)
    private String userEmail;

    @Column(name = "user_password", nullable = true)
    private String userPassword;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_type", nullable = false)
    private UserType userType;

    @Column(name = "user_nickname", nullable = false)
    private String userNickName;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider_type", nullable = false)
    private ProviderType providerType;

    @Column(name = "provider_key", nullable = false)
    private String providerKey;

    @Column(name = "user_last_login_date", nullable = false)
    private String userLastLoginDate;

    @Column(name = "dormancy", nullable = false, columnDefinition = "boolean default false")
    private Boolean dormancy;


    @Builder
    public User(String userProfile,
                String userEmail,
                String userPassword,
                UserType userType,
                String userNickName,
                ProviderType providerType,
                String providerKey,
                String userLastLoginDate,
                Boolean dormancy
    ) {
        this.userProfile = userProfile;
        this.userEmail = userEmail;
        this.userPassword = userPassword;
        this.userType = userType;
        this.userNickName = userNickName;
        this.providerType = providerType;
        this.providerKey = providerKey;
        this.userLastLoginDate = userLastLoginDate;
        this.dormancy = dormancy;
    }

    public static User ofKakao() {
        return User.builder()
                .build();

    }

    public static User ofOrigin() {
        return User.builder()
                .build();

    }

}
```
