FROM python:3.8-buster

LABEL maintainer="Oulahraoui Ayoub aoulahra@gmail.com"

WORKDIR /

COPY student_age.py requirements.txt /

RUN apt update -y && apt install python3-dev libsasl2-dev libldap2-dev libssl-dev -y && \
    pip3 install -r /requirements.txt

VOLUME /data

EXPOSE 5000

CMD ["python3", "./student_age.py"]
