FROM python:slim-bullseye

WORKDIR /app

COPY /app /app

RUN pip3 install -r web-app/requirements.txt

EXPOSE 8080

ENTRYPOINT ["python3"]
CMD ["web-app/app.py"]