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



## とりあえずなOpenWrtインストール手順

### 警告

作業に伴い如何なる事故などが起きましても、一切の責任を取りません。自己責任にて行ってください。  
できる限り事前に/dev/mmcblk郡のバックアップをとってください。  
公式からファーム公開されてません。 事前にバックアップが無いと戻せないと思っておいてください。  
拾えても暗号化されています。  
また、ubootが破損されると復旧不能です、覚悟のある方だけご利用ください。（EDL方法不明）

### tftpブート

本体ボタンからのtftpブートは発見されてません。シリアル接続から行う必要があります。（誰か見つけて…)

PC側のIPを192.168.132.100にセットしてtftpサーバーを用意します。  
MANOMA側のubootより、次のようなコマンドでファイルを読ませてinitramfsでの起動がまず必要です。  
QSDKからのsysupgradeは対応していません。  
電源投入後、ubootで停止したときに何かキーを押すとコンソールに入れます。  
コンソール入ったら次のコマンドでtftpブートします。  
ファイル名は環境に応じて変更してください。

```
(IPQ40xx) # tftpboot 0x84000000 openwrt-ipq40xx-generic-sony_ncp-hg100-initramfs-fit-uImage.itb
(IPQ40xx) # bootm
```

ブート完了後はコンソール、またはLuCI上よりsysupgradeファイルでインストール完了します。  
なお強制的にBOOTCONFIGを変更しHLOS_1とrootfs_1を使うようになります。  
rootfs_dataは自動マウントされません。使いたい場合はblockdでextroot等どうぞ。  

### 復旧方法

recovery置いときました。

シェル上で実行すると、弄ってない方のパーティション0で起動するように戻せます。
なお初期パーティションに戻る場合本体アップデート（青点滅）がかかるので、  
電源を抜かないように注意してください。

```
sh recovery
```

