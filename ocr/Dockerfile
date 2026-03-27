FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    imagemagick \
    ghostscript \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ImageMagick ships with a restrictive policy that blocks PDF reads.
# Patch it so magick can convert PDFs via Ghostscript.
RUN sed -i 's/<policy domain="coder" rights="none" pattern="PDF"/<policy domain="coder" rights="read|write" pattern="PDF"/' \
    /etc/ImageMagick-6/policy.xml 2>/dev/null || true

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5001
CMD ["python", "app.py"]
