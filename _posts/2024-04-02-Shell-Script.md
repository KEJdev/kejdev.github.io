---
layout: post
title: 쉘 스크립트(Shell Script)란 ?
date: 2024-04-02 09:00:00 +0900
category: ETC
---

## Shell Script

쉘 스트립트는 유닉스(Unix)및 유닉스 계열 운영체제(리눅스)의 쉘 환경에서 실행되는 스크립트 프로그래밍 언어이다. 보통 사용자와 운영 체제 사이의 인터페이스 역활을 하며, 사용자가 입력한 명령을 해석하여 컴퓨터에 전달한다. 쉘 스크립트는 명령어들을 파일에 저장하여 한 번에 실행할 수 있다. 이를 통해 반복적인 작업을 자동화하고 복잡한 작업을 간소화할 수 있다.

현재 스터디 하는 곳에서는 깃 브랜치 전략으로 Github flow 을 채택하여 사용하기 때문에 간단하게 아래와 같이 작성했다.

```
#!/bin/bash

# 현재 브런치 이름 가져오기
current_branch=$(git rev-parse --abbrev-ref HEAD)

# main 브랜치가 아닌 경우
if [ "$current_branch" != "main" ]; then
  # main 브랜치의 최신 상태를 가져오기
  git fetch origin main

  # 메인 브랜치와 현재 로컬 브랜치 간에 차이가 있는지 확인하기
  main_diff=$(git log HEAD..origin/main --oneline)
  if [ -z "$main_diff" ]; then
    echo "메인 브랜치에 새로운 변경사항이 없습니다."
  else
    echo "메인 브랜치에 새로운 변경사항이 있습니다. 역머지를 진행하겠습니다."

    # 현재 변경 사항 stash에 올려두기
    git stash push -m "Temporary stash before reverse merge $current_branch"

    # main 브랜치로 이동
    git checkout main

    # 원격에서 최신 변경사항을 가져오기
    git pull origin main

    # 다시 원래의 작업 브랜치로 이동
    git checkout $current_branch

    # main 브랜치 변경사항을 현재 브랜치로 머지
    git merge main

    # 임시로 보관했던 변경사항 다시 가져오기
    git stash pop

    echo "main 브랜치의 최신 변경 사항을 현재 브랜치 ${current_branch}로 병합되었습니다."
  fi
else
  echo "현재 main 브랜치에 있습니다. 역머지 작업을 진행하지 않겠습니다."
fi
```
