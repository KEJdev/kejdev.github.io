---
layout: post
title: "[오늘의 집 클론코딩] Spring Security UserDetails 구현하기"
date: 2024-02-06 00:00:00 +0000
category: Side Project
---

## Spring Security UserDetails  

Spring Security UserDetails는 Spring Security 프레임워크에서 사용자의 인증 정보와 권한 정보를 저장하는 인터페이스다. 사람마다 좀 다르긴 하지만 구현할때 UserDetails라고 부르기도 하고 UserPrincipal이라고 부르기도 한다. 나는 UserDetails라고 애기하려고 한다. 

<aside>
  <span class="icon">🥕</span> 
  <div class="content">
    <p>UserDetails 인터페이스를 구현해야하는 이유</p>
    <p>특정 요구사항에 맞는 사용자 정보 검증, 관리, 보안 등을 통합하여 관리할 수 있습니다. </p>
  </div>
</aside>

![Spring Security Architecture](/public/img/SpringSecurityArchitecture.png)

위에 있는 그럼은 이전 Spring Security관련 포스팅에서도 한번 봤던 그림이다. 그만큼 중요한 그림인데, 이번 User Details 구현할때 많은 도움이 되었기 때문에 그림 순서대로 구현해보자.  

<br>

### AuthenticationFilter

AuthenticationFilter는 초기 요청 시 사용자의 자격 증명(사용자 이름과 비밀번호)를 확인해야한다. 아래와 같이 기존에 있던 SecurityFillterChain 부분에 아래와 같이 한 줄을 추가한다.  

```java
@Bean
@Profile("local")
public SecurityFilterChain localSecurityFilterChain(HttpSecurity http,
                                                    UserRepository userRepository) throws Exception {
    http.httpBasic(AbstractHttpConfigurer::disable)
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement((sessionManagement) -> sessionManagement.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) 
            .authorizeHttpRequests((authorizeHttpRequests) ->
                    .requestMatchers(PERMIT_ALL).permitAll()
                    .anyRequest().permitAll()
            )
            // 이 부분 추가
            .addFilterBefore(new JwtAuthenticationFilter(jwtTokenUtil, jwtService, userDetailsService), UsernamePasswordAuthenticationFilter.class); 
    return addExceptionHandling(http).build();
}
```

<br>

### UsernamePasswordAuthenticationToken

UsernamePasswordAuthenticationToken는 Spring Security에서 유저 이름과 비밀번호로 인증을 수행하는데 사용되는 클레스이다. 유저가 제공한 이름과 비밀번호를 입력받고 이 정보를 UsernamePasswordAuthenticationToken 객체로 만들어 Spring Security에게 전달하여 JWT토큰을 발급하는 등의 작업을 수행한다.  


```java
public Authentication authenticate(Authentication authentication) throws AuthenticationException {
    String userNickName = authentication.getName();
    String userPassword = authentication.getCredentials().toString();

    UserDetails userDetails = userDetailService.loadUserByUsername(userNickName);

    if (userDetails instanceof UserPrincipal){
        UserPrincipal userPrincipal = (UserPrincipal) userDetails;

        if (userPrincipal.getProviderType() == ProviderType.ORIGIN && !passwordEncoder.matches(userPassword, userDetails.getPassword())){
            throw new BadCredentialsException("비밀번호가일치하지 않습니다");
        }
    }

    return new UsernamePasswordAuthenticationToken(userDetails, userPassword, userDetails.getAuthorities());

}
```

현재 코드는 소셜 로그인(카카오, 네이버)과 자체 회원가입 둘다 구현되어 있다. 따라서 소셜 로그인의 경우 직접적으로 패스워드를 저장하는 것이 아니라서 괜찮지만, 자체 로그인의 경우 패스워드를 관리해야 되기 때문에 ProviderType이 자체 회원가입을 경우에 비밀번호 일치 여부를 확인 할 필요가 있었다. 

<br>


### AuthenticationManager  

AuthenticationManager는 생성된 Token이 올바른 유저에서 온 것이 아닌지를 확인하는 부분이다. 나는 아래와 같이 AuthenticationManagerBuilder를 사용하여 유저 로그인, 인증을 처리했다. 


```java
public void configure (AuthenticationManagerBuilder auth) throws Exception {
    auth.authenticationProvider(userAuthenticationProvider);
}
```

<br>


### AuthenticationManager와 AuthenticationProvider

AuthenticationManager는 위에서 한번 언급했듯 인증을 처리하는 역활을 하는데, 클라이언트로부터 받은 인증 정보를 검증하고 이를 기반으로 사용자가 누구인지를 확인하는 실제 인증 작업은 AuthenticationProvider에서 수행된다. 인증된 결과 처리는 다시 AuthenticationManager에게 반환하여 인증을 완료한다. 

```java
public class UserAuthenticationProvider implements AuthenticationProvider {

    private final UserDetailService userDetailService;

    private final PasswordEncoder passwordEncoder;

    public UserAuthenticationProvider(@Lazy PasswordEncoder passwordEncoder, UserDetailService userDetailService){
        this.passwordEncoder = passwordEncoder;
        this.userDetailService = userDetailService;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String userNickName = authentication.getName();
        String userPassword = authentication.getCredentials().toString();

        UserDetails userDetails = userDetailService.loadUserByUsername(userNickName);

        if (userDetails instanceof UserPrincipal){
            UserPrincipal userPrincipal = (UserPrincipal) userDetails;

            if (userPrincipal.getProviderType() == ProviderType.ORIGIN && !passwordEncoder.matches(userPassword, userDetails.getPassword())){
                throw new BadCredentialsException("비밀번호가일치하지 않습니다");
            }
        }

        return new UsernamePasswordAuthenticationToken(userDetails, userPassword, userDetails.getAuthorities());

    }

    @Override
    public boolean supports(Class<?> authentication) {
        return UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
    }
}
```

<br>


### UserDetailsService 

UserDetailsService는 해당 유저의 정보를 데이터베이스나 다른 저장소에서 검색해서 Spring Security에게 제공한다. 

```java
@Service
public class UserDetailService implements UserDetailsService {
    //
    .... 생략
    //

    @Override
    public UserDetails loadUserByUsername(String userNickName) throws UsernameNotFoundException{
        User user = userRepository.findByUserNickName(userNickName)
                .orElseThrow(()-> new UsernameNotFoundException("User not found with userNickName: " + userNickName));
        Collection<GrantedAuthority> authorities = Collections.emptyList();
        return new UserPrincipal(user.getId(), user.getUserNickName(), user.getUserEmail(), authorities, providerType);
    }

    public UserPrincipal loadUserById(Long userId) throws UsernameNotFoundException{
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new UsernameNotFoundException("User not found with userNickName: "));
        Collection<GrantedAuthority> authorities = Collections.emptyList();
        return new UserPrincipal(user.getId(), user.getUserNickName(), user.getUserEmail(), authorities, providerType);
    }
}
```

<br>


### UserDetails  

UserDetails는 사용자 인증 시 필요한 사용자의 상세 정보를 로드하는 클래스이다.  UserDetailsService가 데이터베이스에서 사용자 정보를 조회한 후 조회된 사용자 정보를 바탕으로 UserDetails는객체는 유저의 인증정보(사용자명, 비밀번호, 권한 등)을 반환한다. 

```java
public class UserPrincipal implements UserDetails {
    private Long userId;
    private String userNickName;
    private String userEmail;
    private Collection<? extends GrantedAuthority> authorities;
    private ProviderType providerType;

    public UserPrincipal(Long userId, String userNickName, String userEmail, Collection<? extends GrantedAuthority> authorities, ProviderType providerType) {
        this.userId = userId;
        this.userNickName = userNickName;
        this.userEmail = userEmail;
        this.authorities = authorities;
        this.providerType = providerType;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return null;
    }

    @Override
    public String getUsername() {
        return null;
    }

    @Override
    public boolean isAccountNonExpired() {
        return false;
    }

    @Override
    public boolean isAccountNonLocked() {
        return false;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return false;
    }

    @Override
    public boolean isEnabled() {
        return false;
    }

    public Long getUserId(){
        return userId;
    }

    public String getUserEmail(){
        return userEmail;
    }

    public String getUserNickName(){
        return userNickName;
    }

    public ProviderType getProviderType(){
        return providerType;
    }
}
```

<br>



### SecurityContext & Authentication

아래의 Authentication 인터페이스는 인증 정보 대조 및 검증" 뿐만 아니라 "SecurityContext에 인증 정보 저장", "인증 완료", 그리고 "이후 접근 제어 및 권한 부여"에 사용된다. 

```java
public interface Authentication extends Principal, Serializable {
    // 현재 사용자의 권한 목록을 가져옴
    Collection<? extends GrantedAuthority> getAuthorities();

    Object getDetails();

    // Principal 객체를 가져옴
    Object getPrincipal();

    // 인증 여부를 가져옴
    boolean isAuthenticated();

    // 인증 여부를 설정함
    void setAuthenticated(boolean isAuthenticated) throws IllegalArgumentException;

}
```
 
* 유저가 제공한 인증 정보(유저 이름과 비밀번호)는 AuthenticationProvider에서 처리되고, 이 과정에서 Authentication 객체가 생성되고 유저의 정보가 검증된다. getPrincipal과 getAuthorities이 유저의 식별 정보와 권한을 확인하는데 사용된다.  
*  isAuthenticated는 인증된 유저의 정보를 참조하는데 사용된다.  


