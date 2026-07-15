FROM cgr.dev/chainguard/python:latest-dev AS builder

USER root
WORKDIR /app

RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"
COPY /app/web-app/requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

COPY /app/web-app /app
COPY --from=builder /app/venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "app.py"]
