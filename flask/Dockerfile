FROM python:alpine
COPY requirements.txt .
COPY main.py .
RUN pip3 install -r requirements.txt && pip3 install --upgrade pip
CMD ["gunicorn","-w 4", "-b", "0.0.0.0:8000", "main:app"]
