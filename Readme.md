## OpenWrt Snapshot test patches

OpenWrtでの動作を試みる実験

LAN/WWAN/USB/WiFi OK （USBは要各種ドライバ）  
Bluetooth/Z-Wave 動作不明（使い方わからない）

サウンドやマイク周りのドライバはKernelに無いので移植しないと認識不能

筐体のLEDはmcuの下に居る（/sys/class/i2c-dev/i2c-1/device/1-0015/led）  
筐体mcu、タッチパネル部CY8Cそれぞれファームの有効化をすれば動作してくれるっぽい

drivers/misc/mcu-i2c.c 温度センサーやFan制御、筐体LED動かしているマイコン  
drivers/misc/helios-misc USBやLTEやBTのオンオフ、console/zwave切替等のGPIOスイッチドライバ

mcuはドライバを読ませれば認識操作可能  
タッチパネル部CY8Cはi2cのアドレス有効化で操作可能

ASoC周り(ヾﾉ･∀･`)ﾑﾘﾑﾘ

https://lore.kernel.org/alsa-devel/1468566426-19598-2-git-send-email-njaigane@codeaurora.org/

お手上げ∩(・ω・)∩

