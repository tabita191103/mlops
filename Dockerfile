FROM tensorflow/serving:latest

# Install wget, unzip, dan gdown
RUN apt-get update && apt-get install -y wget unzip python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip install gdown

# Buat folder model
RUN mkdir -p /models/serving_model

# Download zip model dari Google Drive
RUN gdown --id 1ytAGIwkLl6miDjcAQ-PuGssTDeVt02mu -O /models/model.zip \
    && unzip /models/model.zip -d /models/ \
    && rm /models/model.zip \
    && mv /models/output/serving_model/1 /models/serving_model/1 \
    && rm -rf /models/output

# Salin konfigurasi monitoring (opsional)
COPY ./config /model_config

# Set environment variables
ENV MODEL_NAME=serving_model
ENV MODEL_BASE_PATH=/models
ENV MONITORING_CONFIG="/model_config/prometheus.config"
ENV PORT=8501

# Entrypoint TensorFlow Serving
RUN echo '#!/bin/bash\n\n\
env\n\
tensorflow_model_server --port=8500 --rest_api_port=${PORT} \
--model_name=${MODEL_NAME} --model_base_path=${MODEL_BASE_PATH}/${MODEL_NAME} \
--monitoring_config_file=${MONITORING_CONFIG} \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]
