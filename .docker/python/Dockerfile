FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    pkg-config \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY killboard.py entrypoint.sh ./
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]