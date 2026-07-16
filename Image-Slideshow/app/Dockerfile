FROM cgr.dev/chainguard/python:latest-dev AS builder

USER root
WORKDIR /app

RUN python -m venv venv
COPY /app/web-app/requirements.txt /app/requirements.txt
ENV PATH="/app/venv/bin:$PATH"
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest

USER 65532
WORKDIR /app

COPY --chown=65532:65532 /app/web-app /app
COPY --from=builder --chown=65532:65532 /app/venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "app.py"]
