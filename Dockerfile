FROM tensorflow/serving:latest

# Install tools
RUN apt-get update && apt-get install -y wget unzip python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip install gdown

# Buat folder model
RUN mkdir -p /models/serving_model

# Download & unzip model
RUN gdown --id 1ytAGIwkLl6miDjcAQ-PuGssTDeVt02mu -O /models/model.zip \
    && unzip /models/model.zip -d /models/serving_model \
    && rm /models/model.zip \
    && mv /models/serving_model/serving_model/* /models/serving_model/1


# Copy config
COPY ./config /model_config

# Env vars
ENV MODEL_NAME=serving_model
ENV MODEL_BASE_PATH=/models
ENV MONITORING_CONFIG="/model_config/prometheus.config"
ENV PORT=8501

# Entrypoint
RUN echo '#!/bin/bash\n\n\
env\n\
tensorflow_model_server --port=8500 --rest_api_port=${PORT} \
--model_name=${MODEL_NAME} --model_base_path=${MODEL_BASE_PATH}/${MODEL_NAME} \
--monitoring_config_file=${MONITORING_CONFIG} \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]

