---
layout: post
title: Spring Quartz + Slack 신규 유저 통계 수집 및 슬랙 연동하기
date: 2024-05-15 00:00:00 +0900
category: Spring
---

저번 포스팅에서 간단하게 [Quartz](https://kejdev.github.io/spring/2024/05/04/Spring-Quartz/html)가 무엇인지 알아보았는데, 이번에는 아래와 같은 기능을 구현하려고 한다.

- 매일 자정, 신규 유저 수와 전체 유저 수를 user metrics 테이블 저장
- 저장 후 슬랙으로 알람 보내는 기능 구현

참고로, 쿼츠 스케줄러는 아래의 구조와 같이 흘러간다.

![quartz-spring-1](/public/img/quartz-spring-1.jpg)

<center>
  이미지 출처 - <a href="https://blog.advenoh.pe.kr/spring/Quartz-Job-Scheduler%EB%9E%80/">[Quartz-1] Quartz Job Scheduler란?</a>
</center>

### User Metrics Tabel

User Tabel과는 별개로 신규 유저와 전체 유저 수를 담을 수 있는 간단한 테이블을 생성했다. 이제 이 테이블은 매일 자정 쿼츠가 실행되면서 통계치가 조금씩 쌓일 것이다.

```sql
DROP TABLE IF EXISTS user_metrics;
CREATE TABLE user_metrics (
    id              BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '기본 키',
    new_users       BIGINT NOT NULL DEFAULT 0 COMMENT '신규 가입자 수',
    total_users     BIGINT NOT NULL DEFAULT 0 COMMENT '전체 유저 수',
    created_at      datetime NOT NULL COMMENT '메트릭 생성 일자',
    modified_at     datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '메트릭 수정 일자'
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COMMENT='유저 통계 테이블';
```

그리고 아래와 같이 엔티티를 구성한다.

```java
public class UserMetric extends AbstractBaseEntity {

	@Column(name = "new_users", nullable = true)
	private Long newUsers;

	@Column(name = "total_users", nullable = true)
	private Long totalUsers;

	@Builder
	public UserMetric(Long newUsers, Long totalUsers) {
		this.newUsers = newUsers;
		this.totalUsers = totalUsers;
	}

	public static UserMetric of(Long newUsers, Long totalUsers, LocalDateTime createdAt) {
		UserMetric userMetric = new UserMetric();
		userMetric.setNewUsers(newUsers);
		userMetric.setTotalUsers(totalUsers);
		userMetric.setCreatedAt(createdAt);
		return userMetric;
	}
}
```

### User Metrics Repository

리포지토리는 아래와 같이 구성했다.

```java
public interface UserMetricRepository extends JpaRepository<UserMetric, Long> {
	UserMetric findTopByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
	UserMetric findTopByOrderByCreatedAtDesc();
}
```

UserMetric findTopByOrderByCreatedAtDesc();만 있어도 되지만, 유저 통계 테이블에 같은 데이터가 쌓이면 큰일이니... 수집하려는 날짜에 데이터가 있는지를 확인하기 위해 findTopByCreatedAtBetween을 추가했다.

### quartz gradle

implementation 'org.springframework.boot:spring-boot-starter-quartz

### quartz.properties

쿼츠 설정은 아래와 같이 했다. 스레드 설정, 커넥션타임 등을 설정할 수 있다.

```
# scheduler
org.quartz.scheduler.instanceName=QuartzScheduler
org.quartz.scheduler.instanceId=AUTO
org.quartz.threadPool.class=org.quartz.simpl.SimpleThreadPool
org.quartz.threadPool.threadCount=20
# JobStore
org.quartz.jobStore.class=org.quartz.impl.jdbcjobstore.JobStoreTX
org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.StdJDBCDelegate
org.quartz.jobStore.tablePrefix=QRTZ_ # 쿼츠 테이블 이름 앞 부분
org.quartz.jobStore.isClustered=true
org.quartz.jobStore.misfireThreshold=1000
org.quartz.jobStore.clusterCheckinInterval=20000
org.quartz.context.key.QuartzTopic=QuartzPorperties
org.quartz.jobStore.dataSource=test # 여기 이름 수정하면, 아래 dataSource 이름 수정 필요
# dataSource
org.quartz.dataSource.test.provider=hikaricp
org.quartz.dataSource.test.maximumPoolSize=30
org.quartz.dataSource.test.minimumIdle=5
org.quartz.dataSource.test.idleTimeout=30000
org.quartz.dataSource.test.connectionTimeout=30000
org.quartz.dataSource.test.validationTimeout=5000
org.quartz.dataSource.test.maxLifetime=1800000
org.quartz.dataSource.test.driver=com.mysql.cj.jdbc.Driver # 데이터베이스 연결하기 위한 설정
org.quartz.dataSource.test.URL=jdbc:mysql://127.0.0.1:3306/test?useSSL=false& allowPublicKeyRetrieval=true # mysql로 연결할 예정
org.quartz.dataSource.test.user=test
org.quartz.dataSource.test.password=qwer
org.quartz.dataSource.test.maxConnections=30
```

이렇게 설정하면 쿼츠 설정은 다 끝나고 실행하면 Quartz Scheduler v.2.3.2 created. ~~ 이렇게 로그가 찍히면 정상적으로 실행하고 있는거다. 실행되면서 쿼츠 테이블도 원래 자동으로 생성하는걸 설정할 수 있는데, 난 그냥 수동으로 테이블을 생성했다.  
[스키마](https://github.com/quartz-scheduler/quartz/blob/main/quartz/src/main/resources/org/quartz/impl/jdbcjobstore/tables_mysql_innodb.sql)는 여기서 다운받아서 쓰면 된다. 쿼츠 테이블은 있어야 쿼츠 Job, 트리거 상태 등을 기록 할수 있기 때문에 생성해야 된다.

![quartz-table](/public/img/quartz-table.png)

테이블이 잘 들어가면 준비는 끝났다.

### QuartzJobListener

QuartzJobListener는 Job의 실행 전후와 실행 중단 등의 이벤트를 처리할 수 있어, Job의 실행 상태를 모니터링하고 필요한 작업을 자동으로 수행한다. 또한 Job의 상태를 로그로 남기거나, 특정 조건에 따라 추가 작업을 수행하는 등의 유연한 처리가 가능하다.

```java
@Slf4j
public class QuartzJobListener implements JobListener {

	@Override
	public String getName() {
		return "QuartzJobListener";
	}

	@Override
	public void jobToBeExecuted(JobExecutionContext context) {
		log.info("Job is about to be executed: {}", context.getJobDetail().getKey());
	}

	@Override
	public void jobExecutionVetoed(JobExecutionContext context) {
		log.info("Job execution was vetoed: {}", context.getJobDetail().getKey());
	}

	@Override
	public void jobWasExecuted(JobExecutionContext context, JobExecutionException jobException) {
		if (ObjectUtils.isEmpty(jobException)) {
			log.info("Job execution resulted in exception: {}", context.getJobDetail().getKey(), jobException);
		} else {
			log.info("Job was executed successfully: {}", context.getJobDetail().getKey());
		}
	}
}
```

- **getName()**: 리스너의 이름을 반환하며, 리스너를 구분하는 데 사용된다.
- **jobToBeExecuted(JobExecutionContext context)**: Job이 실행되기 전에 호출한다. 여기서 Job이 실행되기 전의 상태를 기록하거나 준비 작업을 수행한다.
- **jobExecutionVetoed(JobExecutionContext context)** Job이 중단되었을 때 호출한다. 주로 트리거의 조건을 만족하지 못하거나 다른 이유로 Job이 실행되지 않을 때 호출된다.
- **jobWasExecuted(JobExecutionContext context, JobExecutionException jobException)**: Job이 실행된 후에 호출된다. Job의 결과를 기록하거나 후속 작업을 수행할 수 있다. 만약 Job 실행 중 예외가 발생했다면 jobException을 통해 그 예외를 처리할 수 있다.

### QuartzTriggerListener

TriggerListener는 트리거의 상태 변경 이벤트를 모니터링하고 처리하는 역할을 하는데, 쉽게 말하면 트리거가 실행될 때 / 실행되지 못했을 때 / 실행이 완료되었을 때 등의 이벤트를 처리하여 로그를 남기거나 추가 작업을 수행한다.

```java
@Slf4j
public class QuartzTriggerListener implements TriggerListener {
	@Override
	public String getName() {
		return this.getClass().getName();
	}

	@Override
	public void triggerFired(Trigger trigger, JobExecutionContext context) {
		log.info("Trigger 실행");
	}

	@Override
	public boolean vetoJobExecution(Trigger trigger, JobExecutionContext context) {
		return false;
	}

	@Override
	public void triggerMisfired(Trigger trigger) {
		log.warn("Trigger misfired: {}", trigger.getKey());
	}

	@Override
	public void triggerComplete(Trigger trigger, JobExecutionContext context,
		Trigger.CompletedExecutionInstruction triggerInstructionCode) {
		log.info("Trigger complete: {}", trigger.getKey());
	}
}
```

- **getName()**: 리스너의 이름을 반환한다. 이 이름은 리스너를 구분하는 데 사용된다.
- **triggerFired(Trigger trigger, JobExecutionContext context)**: 트리거가 실행될 때 호출된다. 트리거가 정상적으로 실행되었음을 로그로 기록하거나 추가 작업을 수행할 수 있다.
- **vetoJobExecution(Trigger trigger, JobExecutionContext context)**: 트리거가 실행되지 않도록 중단되었을 때 호출된다. true를 반환하면 Job 실행을 중단할 수 있다.
- **triggerMisfired(Trigger trigger)**: 트리거가 실행되지 못했을 때 호출된다. 예를 들어, 트리거의 실행 시간이 지났지만 실행되지 않았을 때 호출된다.
- **triggerComplete(Trigger trigger, JobExecutionContext context, CompletedExecutionInstruction triggerInstructionCode)**: 트리거가 작업을 완료한 후에 호출된다. 트리거의 실행이 완료되었음을 기록하거나 후속 작업을 수행할 수 있다.

### Quartz Job

이제 "신규 유저 수와 전체 유저 수를 user metrics 테이블 저장" 하는 로직을 구현하자.

```java
@Slf4j
@Component
@PersistJobDataAfterExecution
@DisallowConcurrentExecution
public class QuartzJob implements Job {
	@Autowired
	private UserRepository userRepository;
	@Autowired
	private UserMetricRepository userMetricRepository;
	@Autowired
	private SlackNotificationService slackNotificationService; // 슬랙 알림

    // 수행해야는 실제 작업은 execute 메서드에 구현해야 한다.
	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		try {
			updateDailyUserMetrics(context);
		} catch (Exception e) {
			JobExecutionException jobException = new JobExecutionException(e);
			jobException.setUnscheduleAllTriggers(true);
			throw new JobExecutionException(e);
		}
	}

	private void updateDailyUserMetrics(JobExecutionContext context) {
		JobDataMap dataMap = context.getJobDetail().getJobDataMap();
		String dateString = dataMap.getString("date");

		if (ObjectUtils.isEmpty(dateString)) {
			throw new IllegalArgumentException("Date is required in JobDataMap");
		}

		LocalDate date = LocalDate.parse(dateString);
		LocalDateTime startOfDay = date.atStartOfDay();
		LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();

		Long newUserToday = userRepository.countNewUsersByDate(startOfDay, endOfDay);
		UserMetric lastMetric = userMetricRepository.findTopByOrderByCreatedAtDesc();
		Long totalUsersYesterday = (lastMetric != null) ? lastMetric.getTotalUsers() : 0;
		Long totalUserToday = totalUsersYesterday + newUserToday;

		UserMetric existingMetric = userMetricRepository.findTopByCreatedAtBetween(startOfDay, endOfDay);
		if (ObjectUtils.isEmpty(existingMetric)) {
			slackNotificationService.sendDailyUserMetrics(date, newUserToday, totalUserToday);
			return;
		}

		UserMetric userMetric = UserMetric.of(newUserToday, totalUserToday, LocalDateTime.now());
		userMetricRepository.save(userMetric);

		slackNotificationService.sendDailyUserMetrics(date, newUserToday, totalUserToday);
	}
}
```

주석으로도 잠깐 적어두긴 했지만, **쿼츠를 구현할때 수행해야는 실제 작업은 execute 메서드에 구현**해야 한다. 또한 Quartz가 Job 인스턴스를 직접 생성하기 때문에 생성자를 통해 의존성을 주입하는 방식은 작동하지 않는다. Quartz가 Job 인스턴스를 생성할 때 Spring의 컨텍스트를 사용하지 않기 때문에 Autowired를 사용해야 작동한다.

### Quartz Service

```java
@Slf4j
@Configuration
@RequiredArgsConstructor
public class QuartzService {
	private final Scheduler scheduler;

	@PostConstruct
	public void init() throws SchedulerException {
		scheduler.clear();
		scheduler.getListenerManager().addJobListener(new QuartzJobListener());
		scheduler.getListenerManager().addTriggerListener(new QuartzTriggerListener());

		Map<String, Object> paramsMap = new HashMap<>();
		paramsMap.put("executeCount", 1);
		paramsMap.put("date", LocalDate.now().toString());

		addJob(QuartzJob.class, "UserMetricSendQuartzJob", "유저 회원가입 통계 Job 입니다.", paramsMap, "0 0 0 * * ?");

		if (!scheduler.isStarted()) {
			scheduler.start();
		}
	}

	public void addJob(Class<? extends Job> jobClass, String jobName, String jobDescription,
		Map<String, Object> jobDataMap, String cronExpression) throws SchedulerException {
		JobDetail jobDetail = buildJobDetail(jobClass, jobName, jobDescription, jobDataMap);
		Trigger trigger = buildCronTrigger(cronExpression, jobName + "Trigger");

		if (scheduler.checkExists(jobDetail.getKey())) {
			log.error("업데이트 할 Job : {}", jobDetail.getKey());
			scheduler.deleteJob(jobDetail.getKey());
		} else {
			log.error("새로운 Job 추가 : {}", jobDetail.getKey());
		}
		scheduler.scheduleJob(jobDetail, trigger);

	}

	private JobDetail buildJobDetail(Class<? extends Job> job, String name, String desc,
		Map<String, Object> paramsMap) {
		JobDataMap jobDataMap = new JobDataMap();
		jobDataMap.putAll(paramsMap);

		return JobBuilder.newJob(job)
			.withIdentity(name)
			.withDescription(desc)
			.usingJobData(jobDataMap)
			.build();
	}

	private Trigger buildCronTrigger(String cronExp, String triggerName) {
		return TriggerBuilder.newTrigger()
			.withIdentity(triggerName, "NewUserMetric")
			.withSchedule(CronScheduleBuilder.cronSchedule(cronExp))
			.build();
	}
}
```

- **buildJobDetail** : buildJobDetail 메서드는 Job 이름, Job 설명 , Job에 데이터를 전달한다.
- **buildCronTrigger** : buildCronTrigger 메서드는 크론 표현식을 기반으로 Trigger를 생성한다. (_코드에는 매일 자정으로 크론식을 표현했지만, 테스트할때는 크론식을 "0 _ \* \* \* ?" 으로 수정하면 1분마다 쿼츠가 실행된다.)
- **addJob** : addJob 메서드는 쿼츠 스케줄러에 새로운 Job을 추가하거나 기존의 Job을 업데이트하는 메서드다.

이제 실행하면 아래와 같이 도는 모습을 볼 수 있다.

![quartz-run](/public/img/quartz-run.png)

이제 잘 돌아가는 모습을 봤으니, 슬랙과 연동해보자.

### Slack 연동하기

이미 슬랙 토큰을 발급 받았다는 가정하에 글을 쓰기 때문에 따로 토큰 발급하는 법에 대해서는 다루지 않는다.

### application

```
slack:
  token: xoxb-000000000-00000000000-00000000000
  channel:
    welcome: '#signup-noti'
```

위와 같이 application.yml에 채널명과 토큰을 입력한다. 나는 기존에 있던 유저 회원가입 알림 채널에 매일 자정 통계치를 뿌려도 될거 같아서 #signup-noti 슬랙 채널에 설정하기로 했다.

### Slack gradle

implementation 'org.springframework.boot:spring-boot-starter-quartz

### Slack Service

아래와 같이 슬랙 알람 부분을 구현하면 된다.

```java
@Slf4j
@Service
public class SlackNotificationService {

	@Value(value = "${slack.token}")
	private String token;
	@Value(value = "${slack.channel.welcome}")
	private String welcomeChannel;

	public void sendDailyUserMetrics(LocalDate date, Long newUsers, Long totalUsers) {
		ChatPostMessageRequest request = getSlackMetricsType(date, newUsers, totalUsers);
		sendNotification(request);
	}

	private void sendNotification(
		ChatPostMessageRequest request
	) {
		try {
			ChatPostMessageResponse response = Slack.getInstance().methods(token).chatPostMessage(request);
			SlackResponseErrorUtils.slackNotificationErrorValidate(request, response);

			//TODO response 검증 이후에도 문제가 없을때 공통 코드 필요한경우 작성할 것
		} catch (IOException e) {
			throw new RuntimeException(e + "슬랙 전송에 실패하였습니다. - IOException");
		} catch (SlackApiException e) {
			throw new RuntimeException(e + "슬랙 API 사용에 실패하였습니다. - SlackApiException");
		}
	}

	private ChatPostMessageRequest getSlackMetricsType(LocalDate date, Long newUsers, Long totalUsers) {
		List<TextObject> metricsTextBlock = new ArrayList<>();

		metricsTextBlock.add(
			markdownText(markdownBoldText("날짜:") + "\n" + markdownHighlightText(date.toString())));
		metricsTextBlock.add(
			markdownText(markdownBoldText("신규 유저 수:") + "\n" + markdownHighlightText(newUsers.toString())));
		metricsTextBlock.add(
			markdownText(markdownBoldText("전체 유저 수:") + "\n" + markdownHighlightText(totalUsers.toString())));

		return ChatPostMessageRequest.builder()
			.channel(welcomeChannel)
			.blocks(Blocks.asBlocks(
				Blocks.header(header -> header.text(plainText("Daily User Metrics"))),
				Blocks.divider(),
				Blocks.section(section -> section.fields(metricsTextBlock))
			))
			.build();
	}

	private String markdownBoldText(String text) {
		return "*" + text + "*";
	}

	private String markdownHighlightText(String text) {
		return "`" + text + "`";
	}
}
```

그리고 아까 구현했던 실제 실행하는 로직(Quartz Job)에 아래와 같이 추가하면 된다.

```java
    private SlackNotificationService slackNotificationService;

    // 생략
    private void updateDailyUserMetrics(JobExecutionContext context) {
		// 생략

		slackNotificationService.sendDailyUserMetrics(date, newUserToday, totalUserToday);
    }
```

이렇게 슬랙까지 설정했으면 다시 쿼츠를 실행하게 되면 아래와 같이 알람이 슬랙으로 전송되는 것을 볼 수 있다.

![quartz-slack](/public/img/quartz-slack.png)
