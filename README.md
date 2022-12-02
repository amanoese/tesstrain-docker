tesstrain-docker
===

Tessract OCR 4で再学習・追加学習手順させたい場合に必要なライブラリや学習元になるデータを良い感じに配置したDockerコンテナです。
難しい依存問題を考えずすぐに学習を始めることができるはずです。

Tessract-ocr: https://github.com/tesseract-ocr/tesseract
tesstrain: https://github.com/tesseract-ocr/tesstrain

## Usage

### 1. dockerコンテナをビルドします。
```bash
$ docker build -t tesstrain .
```

### 2. dockerコンテナを起動しBashを実行します。
```bash
$ docker run -v $PWD/data:/var/tesstrain/data -it tesstrain bash
```

### 3. ocrdのモデルを学習します。
/var/tesstrain/data/ocrd-ground-truth内に配置されているサンプルファイルで学習します。
学習済みのfrk(フランス語)のデータ(/var/tesstrain/data/usr/share/tessdata/frk.traineddata)に対して、追加で学習を行います

```bash
$ make training MODEL_NAME=ocrd START_MODEL=frk MAX_ITERATIONS=100 > plot/ocrd.log
```
output
```text
oaded file data/ocrd/checkpoints/ocrd_checkpoint, unpacking...
Successfully restored trainer from data/ocrd/checkpoints/ocrd_checkpoint
Loaded 1/1 lines (1-1) of document data/ocrd-ground-truth/frapan_bittersuess_1891_0103_007.lstmf
...
Loaded 1/1 lines (1-1) of document data/ocrd-ground-truth/poersch_gewerkschaftsbewegung_1897_0020_021.lstmf
At iteration 73/100/100, Mean rms=1.165%, delta=2.339%, char train=6.625%, word train=17.285%, skip ratio=0%,  wrote checkpoint.

Finished! Error rate = 6.625
```
Finishedが表示されれば学習は終了です。

### 4. 追加学習を行い新規に作成したocrdのモデルがtesseractコマンドで認識できるか確認します。

```bash
$ ./usr/bin/tesseract --tessdata-dir ./data --list-langs
```
output
```text
List of available languages (2):
ocrd
ocrd/ocrd
```

### 5. 作成したocrdのモデルがtesseractコマンドで仕様できるか確認します。

```bash
$ ./usr/bin/tesseract -l ocrd --tessdata-dir ./data data/ocrd-ground-truth/alexis_ruhe01_1852_0018_022.tif stdout 2>/dev/null
```
output
```text
ich denke. Aber was die ſelige Frau Geheimräthun
```

上記の例では学習に使用したデータを検証用に利用しているため、
認識精度を確かめる例としては不十分ですが、
学習を正しく行えファイルが正しく生成されている確認を行うことができます。

## 0からモデルを生成したい場合

makeでのSTART_MODELを省略することで可能なようです？
```
$ make training MODEL_NAME=ocrd =frk MAX_ITERATIONS=100
```

## 学習データ生成と学習の参考

```bash
$ cat training.txt|\
  awk 'BEGIN{split("ふい字 おひさまフォント まきばフォント",B," ")}{print "convert -font $(fc-match --format=%{file} "A""B[NR%3+1]A") -pointsize 36 label:"A$0A" out/"NR".png"}' A="'"|\
  parallel
$ mv out/ data/mydata-ground-truth
$ make training MODEL_NAME=mydata START_MODEL=jpn MAX_ITERATIONS=100 > plot/mydata.log
```

