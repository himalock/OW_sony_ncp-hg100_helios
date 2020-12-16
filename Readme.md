# OpenWrt Snapshot test patches

OpenWrtでの動作を試みる実験

LAN/WWAN/USB/WiFi OK (一部要ドライバ)<br>
Bluetooth/Z-Wave 動作不明（qcaはドライバはあるっぽいけど選べないのと使い方わからない）<br>
サウンドやマイク周りのドライバはKernelに無いので移植しないと認識不能

筐体のLEDはmcuの下に居るっぽい（78b8000.i2c/i2c-1/1-0015/led）<br>
タッチパネル部CY8Cはmcu経由でファーム上げて動作しているっぽい

drivers/misc/mcu-i2c.c 温度センサーやFan制御、筐体LED動かしているマイコン<br>
drivers/misc/helios-misc USBやLTEやBTのオンオフ、console/zwave切替等のGPIOスイッチドライバ

mcuはファームを読ませれば認識操作可能<br>
タッチパネル部CY8Cはバイナリ動かすと操作可能

ASoC周り(ヾﾉ･∀･`)ﾑﾘﾑﾘ
https://lore.kernel.org/alsa-devel/1468566426-19598-2-git-send-email-njaigane@codeaurora.org/

お手上げ∩(・ω・)∩

