FROM centos/python-38-centos7:latest
RUN pip3 install --upgrade pip
RUN pip3 install flask flask-jsonpify flask-restful
RUN mkdir python_api
COPY python-api.py /python_api/python-api.py

WORKDIR /python_api

CMD ["python3", "python-api.py"]
