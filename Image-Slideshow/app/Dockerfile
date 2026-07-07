FROM cgr.dev/chainguard/python:latest-dev AS builder

USER root
WORKDIR /app

COPY /app/web-app /app
RUN chmod -R a+rX /app

RUN python -m venv /venv
RUN /venv/bin/pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

COPY --from=builder /venv /venv
COPY --from=builder /app /app

ENV PATH="/venv/bin:$PATH"

ENTRYPOINT ["python"]
CMD ["app.py"]