FROM python:3.8-alpine
ENV PYTHONUNBUFFERED=1
RUN mkdir /code
COPY . /code/
RUN apk add --update --no-cache --virtual .tmp postgresql-dev build-base \
    musl python3-dev musl-dev gcc libc-dev linux-headers \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r /code/requirements.txt \
    && apk del .tmp \
    && apk --no-cache add libpq \
    && chmod 755 /code/docker-entrypoint.sh \
    && ln -s /code/docker-entrypoint.sh /
WORKDIR /code
EXPOSE 8000/tcp
VOLUME [ "/apps/polls/static" ]
ENTRYPOINT ["/code/docker-entrypoint.sh"]
CMD ["gunicorn"]
