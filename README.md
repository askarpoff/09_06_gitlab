# Домашнее задание к занятию 12 «GitLab»

## Основная часть

### DevOps

В репозитории содержится код проекта на Python. Проект — RESTful API сервис. Ваша задача — автоматизировать сборку образа с выполнением python-скрипта:

1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated).
2. Python версии не ниже 3.7.
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`.
4. Создана директория `/python_api`.
5. Скрипт из репозитория размещён в /python_api.
6. Точка вызова: запуск скрипта.
7. Если сборка происходит на ветке `master`: должен подняться pod kubernetes на основе образа `python-api`, иначе этот шаг нужно пропустить.

## Ответ
```dockerfile
FROM centos/python-38-centos7:latest
RUN pip3 install --upgrade pip
RUN pip3 install flask flask-jsonpify flask-restful
RUN mkdir python_api
COPY python-api.py /python_api/python-api.py

WORKDIR /python_api

CMD ["python3", "python-api.py"]
```
![image](https://user-images.githubusercontent.com/108946489/229235868-53394af6-6024-4b53-a688-29b64f7dab1f.png)
```
stages:
  - build
  - deploy

build:
  stage: build
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_TLS_CERTDIR: ""
    DOCKER_HOST: tcp://localhost:2375/
  image: cr.yandex/yc/metadata-token-docker-helper:0.2
  services:
    - docker:19.03.1-dind
  script:
    - docker build . -t cr.yandex/crp12k10e4kg16h30ac7/python-api:gitlab-$CI_COMMIT_SHORT_SHA
    - docker push cr.yandex/crp12k10e4kg16h30ac7/python-api:gitlab-$CI_COMMIT_SHORT_SHA

deploy:
  image: gcr.io/cloud-builders/kubectl:latest
  stage: deploy
  script:
    - kubectl config set-cluster k8s --server="https://158.160.28.27" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
    - sed -i "s/__VERSION__/gitlab-$CI_COMMIT_SHORT_SHA/" k8s.yaml
    - kubectl apply -f k8s.yaml
  only:
    - master
```
![image](https://user-images.githubusercontent.com/108946489/229236520-6ab942c0-1c0b-412e-88fb-71d147a3909e.png)

### Product Owner

Вашему проекту нужна бизнесовая доработка: нужно поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:

1. Какой метод необходимо исправить.
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`.
3. Issue поставить label: feature.
## Ответ
![image](https://user-images.githubusercontent.com/108946489/229269953-0ea996c7-b76a-4bd6-adf2-69ec8e9a83d0.png)

### Developer

Пришёл новый Issue на доработку, вам нужно:

1. Создать отдельную ветку, связанную с этим Issue.
2. Внести изменения по тексту из задания.
3. Подготовить Merge Request, влить необходимые изменения в `master`, проверить, что сборка прошла успешно.
## Ответ
![image](https://user-images.githubusercontent.com/108946489/229270046-1321a553-cdef-4e74-b9aa-8525e16aa4e5.png)
![image](https://user-images.githubusercontent.com/108946489/229270133-f0f89f25-4e47-49eb-be1a-480b85cb1168.png)


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:

1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность.
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый.
## Ответ
![image](https://user-images.githubusercontent.com/108946489/229271165-f1cfe391-86a6-4544-9660-cad63f0c1108.png)
![image](https://user-images.githubusercontent.com/108946489/229271707-ccb7469e-4704-49bb-96bf-58aad60a9c87.png)
![image](https://user-images.githubusercontent.com/108946489/229271644-d8cf7f9b-e1e3-4d33-a7bf-001893ea3bb5.png)

![image](https://user-images.githubusercontent.com/108946489/229271884-9c516acd-b281-4b58-bd4a-045c7cb9a79e.png)


## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

- файл gitlab-ci.yml;
- Dockerfile; 
- лог успешного выполнения пайплайна;
- решённый Issue.
