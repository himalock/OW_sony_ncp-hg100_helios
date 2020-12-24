## OpenWrt Snapshot test patches

OpenWrtでの動作を試みる実験

LAN/WWAN/USB/WiFi OK (一部要ドライバ)
Bluetooth/Z-Wave 動作不明（使い方わからない）

サウンドやマイク周りのドライバはKernelに無いので移植しないと認識不能

筐体のLEDはmcuの下に居る（78b8000.i2c/i2c-1/1-0015/led）
筐体mcu、タッチパネル部CY8Cそれぞれファームの有効化をすれば動作してくれるっぽい

drivers/misc/mcu-i2c.c 温度センサーやFan制御、筐体LED動かしているマイコン
drivers/misc/helios-misc USBやLTEやBTのオンオフ、console/zwave切替等のGPIOスイッチドライバ

mcuはファームを読ませれば認識操作可能
タッチパネル部CY8Cはバイナリ動かすと操作可能

ASoC周り(ヾﾉ･∀･`)ﾑﾘﾑﾘ

https://lore.kernel.org/alsa-devel/1468566426-19598-2-git-send-email-njaigane@codeaurora.org/

お手上げ∩(・ω・)∩

