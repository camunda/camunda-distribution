FROM python:3.13-alpine
ENV PYTHONUNBUFFERED=1

ARG PRODUCT_CODE
ARG PRODUCT_ID
ARG ISSUER_FOOTPRINT
ENV PROD_CODE=$PRODUCT_CODE
ENV PROD_ID=$PRODUCT_ID
ENV ISSUER_FT=$ISSUER_FOOTPRINT

COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt
RUN mkdir -p app
COPY checkoutLicense.py /app/checkoutLicense.py
WORKDIR /app
EXPOSE 8000
CMD ["python","checkoutLicense.py"]
