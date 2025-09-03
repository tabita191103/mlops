FROM tensorflow/serving:latest

RUN apt-get update && apt-get install -y python3-pip unzip && rm -rf /var/lib/apt/lists/*
RUN pip install gdown

RUN mkdir -p /models/phising-email-model

RUN gdown --id 1AbCdEfGhIjKlMnOpQRsTuVWxyz -O /models/phising-email-model/model.zip \
    && unzip /models/phising-email-model/model.zip -d /models/phising-email-model \
    && rm /models/phising-email-model/model.zip

COPY ./config /model_config

ENV MODEL_NAME=phising-email-model
ENV MODEL_BASE_PATH=/models
ENV MONITORING_CONFIG="/model_config/prometheus.config"
ENV PORT=8501

RUN echo '#!/bin/bash \n\n\
tensorflow_model_server --port=8500 --rest_api_port=${PORT} \
--model_name=${MODEL_NAME} --model_base_path=${MODEL_BASE_PATH}/${MODEL_NAME} \
--monitoring_config_file=${MONITORING_CONFIG} \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]
