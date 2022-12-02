FROM ubuntu:22.10
MAINTAINER amanoese
ARG CORES=12

RUN apt-get update && apt-get install -y \
  git build-essential python3-pip bc wget unzip\
  g++ autoconf automake libtool pkg-config \
  libpng-dev libjpeg8-dev libtiff5-dev zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev
RUN pip install pillow

WORKDIR /var/
RUN git clone --depth 1 https://github.com/tesseract-ocr/tesstrain.git
RUN git clone --depth 1 https://github.com/tesseract-ocr/tessdata_best.git

WORKDIR /var/tesstrain
RUN make leptonica tesseract CORES=$CORES

RUN make tesseract-langdata
RUN mv /var/tessdata_best/*.traineddata ./usr/share/tessdata

## example learning
RUN unzip ocrd-testset.zip -d data/ocrd-ground-truth
RUN make training MODEL_NAME=ocrd START_MODEL=frk MAX_ITERATIONS=100 > plot/TESSTRAIN.LOG
RUN ./usr/bin/tesseract --tessdata-dir ./data --list-langs
RUN ./usr/bin/tesseract -l ocrd --tessdata-dir ./data data/ocrd-ground-truth/alexis_ruhe01_1852_0018_022.tif stdout

RUN tar -zcf data_backup.tar.gz ./data/*
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD bash
