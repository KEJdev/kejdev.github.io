---
layout: post
title: Spring Quartz 재사용 가능한 스케줄링 구조 만들기 
date: 2024-11-02 00:00:00 +0900
category: Spring
---


이전 포스팅에 [Quartz 구현](https://kejdev.github.io/spring/2024/05/15/SpringQuartzStatistics.html) 관련 글을 쓰긴했는데, 재사용을 염두하지 않고 구현했던거라 이번에 스케줄링 작업 몇개 추가하면서 코드를 조금 수정했다.     

<br>  

### QuartzService 

<br>  

기존에 있던 QuartzService를 추상 클래스로 만들어 상속 받을 수 있도록 했다. 이렇게 되면 이제 각 도메인이나 필요한 곳에서 가져다 사용할 수 있다. 

<br>  

```java  
public abstract class QuartzBaseService {

	private final Scheduler scheduler;

	public QuartzBaseService(Scheduler scheduler) {
		this.scheduler = scheduler;
		init();
	}

        // 추상 메서드
	public abstract void initJob();

	private void init() {
		try {
			scheduler.clear();
			scheduler.getListenerManager().addJobListener(new QuartzJobListener());
			scheduler.getListenerManager().addTriggerListener(new QuartzTriggerListener());

			initJob();

			if (!scheduler.isStarted()) {
				scheduler.start();
			}

		} catch (Exception e) {
			log.error("Quartz 스케줄러 초기화 중 오류 발생", e);
		}
	}

	public void addJob(Class<? extends Job> jobClass, String jobName, String jobDescription,
		Map<String, Object> jobDataMap, String cronExpression) {
		try {
			JobDetail jobDetail = buildJobDetail(jobClass, jobName, jobDescription, jobDataMap);
			Trigger trigger = buildCronTrigger(cronExpression, jobName + "Trigger");

			if (scheduler.checkExists(jobDetail.getKey())) {
				scheduler.deleteJob(jobDetail.getKey());
			}
			scheduler.scheduleJob(jobDetail, trigger);
		} catch (SchedulerException e) {
			log.error("잡 스케줄링 중 SchedulerException 발생: {}", jobName, e);
		}
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
}
```

<br>


그리고 스케줄링 해야 하는 곳에서 initJob()을 구현하면 되는데, 이제는 여러 작업을 관리해야 하다보니 enum으로 만드는게 다른 팀원들과 일할 때도 편할 거 같아 enum으로 작업 내용을 정리햇다. 


<br> 

```java 

public enum UserAccountQuartzInfo {
	USER_ACCOUNT_DELETE(
		"UserAccountDeleteJob",
		"회원탈퇴 후 5년이 지난 유저 Hard Delete",
		"0 0 * * * ",
		UserAccountDeleteJob.class
	);

	private final String quartzJabName;
	private final String quartzJabDescription;
	private final String quartzJabCron;
	private final Class<? extends Job> jobClass;

	UserAccountQuartzInfo(String quartzJabName, String quartzJabDescription, String quartzJabCron,
		Class<? extends Job> jobClass) {
		this.quartzJabName = quartzJabName;
		this.quartzJabDescription = quartzJabDescription;
		this.quartzJabCron = quartzJabCron;
		this.jobClass = jobClass;
	}

	public String getQuartzJabName() {
		return quartzJabName;
	}

	public String getQuartzJabDescription() {
		return quartzJabDescription;
	}

	public String getQuartzJabCron() {
		return quartzJabCron;
	}

	public Class<? extends Job> getJobClass() {
		return jobClass;
	}
}
```


<br> 

enum으로 만들었으면 아래와 같이 initJob을 구현하면 Quartz 구현이 끝난다.  

<br> 

```java
public class UserAccountDeleteQuartzService extends QuartzBaseService {

	public UserAccountDeleteQuartzService(Scheduler scheduler) {
		super(scheduler);
	}

	@Override
	public void initJob() {
		Map<String, Object> paramsMap = new HashMap<>();

		addJob(UserAccountQuartzInfo.USER_ACCOUNT_DELETE.getJobClass(),
			UserAccountQuartzInfo.USER_ACCOUNT_DELETE.getQuartzJabName(),
			UserAccountQuartzInfo.USER_ACCOUNT_DELETE.getQuartzJabDescription(),
			paramsMap,
			UserAccountQuartzInfo.USER_ACCOUNT_DELETE.getQuartzJabCron());
	}

}
```

<br>  


이렇게 한번 기본 틀을 만들면 이제 어느 도메인에서도 쉽게 상속 받아서 initJob만 구현하면 되기 때문에 여러 작업을 관리하기 편하다. 
