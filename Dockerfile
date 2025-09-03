FROM tensorflow/serving:latest

# Install wget, unzip, dan gdown
RUN apt-get update && apt-get install -y wget unzip python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip install gdown

# Siapkan folder model
RUN mkdir -p /models/phising-email-model

# Download zip model dari Google Drive, unzip, lalu hapus zip-nya
RUN gdown --id 1ytAGIwkLl6miDjcAQ-PuGssTDeVt02mu -O /models/phising-email-model/model.zip \
    && unzip /models/phising-email-model/model.zip -d /models/phising-email-model \
    && rm /models/phising-email-model/model.zip

# Salin konfigurasi monitoring jika ada
COPY ./config /model_config

# Set environment variables untuk TensorFlow Serving
ENV MODEL_NAME=phising-email-model
ENV MODEL_BASE_PATH=/models
ENV MONITORING_CONFIG="/model_config/prometheus.config"
ENV PORT=8501

# Buat entrypoint custom untuk menjalankan TensorFlow Serving
RUN echo '#!/bin/bash\n\n\
env\n\
tensorflow_model_server --port=8500 --rest_api_port=${PORT} \
--model_name=${MODEL_NAME} --model_base_path=${MODEL_BASE_PATH}/${MODEL_NAME} \
--monitoring_config_file=${MONITORING_CONFIG} \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]
