FROM python:3.7

WORKDIR /app

COPY flask-app/requirements.txt .
RUN pip install -r requirements.txt

COPY flask-app/ .

EXPOSE 5000
CMD ["python", "app.py"]
