# Bubble 3
### Setup Raspberry Pi with Raspbian Jessie Lite (headless mode)
#### Step 1: Run raspbianizer.sh
- Specify the correct device path to the fresh SD card (e.g. /dev/sdd, /dev/sde, or /dev/sdx)
- Specify SSID_CLIENT where there is an internet connection is available
- Specify PASS_CLIENT Passphrase for the SSID_CLIENT
- Example:
```sh
export BRANCH=v1.0.0 && export SSID_CLIENT="homenet" && export PASS_CLIENT="homenetpass" && curl -skL "https://raw.githubusercontent.com/do-i/bubble3/${BRANCH}/bin/raspbianizer.sh" | sudo -E bash -s /dev/sdx
```

#### Step 2: Boot-up Raspberry Pi3 using SD card & SSH
- Take out the SD card from your computer and put it in Raspberry Pi3
- Check that an ethernet cable(Cat 5) connects between Raspberry Pi3 and the router(has Internet access)
- Ensure that the USB flash drive holding your data is connected to the Pi3 before powering up
```sh
ssh pi@<IP Address>
```

#### Step 3: Install & Configure
```sh
export BRANCH=v1.0.0 && export UPDATE=YES && UPGRADE=YES && curl -skL "https://raw.githubusercontent.com/do-i/bubble3/${BRANCH}/bin/install.sh" | bash
```
- Note: Thanks for a [great instructional article](https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostapd) for WiFi configuration.
- Override Options
  - WIFI SSID (alphanumeric 1-32 characters)
  ```sh
  export SSID=MyBubble
  ```
  - WPA Passphrase (alphanumeric 8-63 characters)
  ```sh
  export PASS=MySecretPassPhrase2016
  ```

#### Step 4: Check for Errors & Reboot
- Check for any errors. If everything looks good, then run the following command:
```sh
sudo reboot
```

#### Step 5: Connect
- Disconnect ethernet cable from Raspberry Pi3
- Connect your device(s) to WiFi Access Point (If you did not override SSID and PASS in Step 3, here are default values.)
  - SSID: SimpleBubble
  - PASS: raspberry
- Open your web browser on [http://bubble](http://bubble "bubble") or [IP address](http://2.4.6.16)
