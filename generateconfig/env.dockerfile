# syntax=docker/dockerfile:1
FROM python:3.11-alpine
WORKDIR /code
RUN pip install requests==2.32.2
ENTRYPOINT ["python", "/code/generateconfig/env.py"]
