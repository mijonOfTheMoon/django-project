FROM python:3.8-alpine3.20 AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk add --update --no-cache --virtual .build-deps \
    build-base \
    python3-dev \
    libpq-dev \
    jpeg-dev \
    zlib-dev
RUN pip install --upgrade pip

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.8-alpine3.20

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app
RUN apk add --update --no-cache libpq-dev
COPY --from=base /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=base /usr/local/bin/ /usr/local/bin/
COPY . .

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "portfolio.wsgi:application"]