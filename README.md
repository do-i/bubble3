# Bubble 3
### Setup Raspberry Pi with Raspbian Jessie Lite (headless mode)
#### Step 1: Run raspbianizer3.sh
- Specify the correct device path to the fresh SD card (e.g. /dev/sdd, /dev/sde, or /dev/sdx)
- Check that the SD card does not have partitions
- Example:
```sh
export BRANCH=<branch name> && curl -skL "https://raw.githubusercontent.com/do-i/bubble3/${BRANCH}/bin/raspbianizer.sh" | sudo bash -s /dev/sdx
```

#### Step 2: Boot-up Raspberry Pi3 using SD card & SSH
- Take out the SD card from your computer and put it in the Raspberry Pi
- Check that the Cat 5 cable connects between your router and the Raspberry Pi
- Ensure the USB holding your data is connected to the Pi before powering up

#### Step 3: Install & Configure
```sh
export BRANCH=<branch name> && curl -skL "https://raw.githubusercontent.com/do-i/bubble3/${BRANCH}/bin/install.sh" | bash
```
- Note: A great [instructional article](https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostpad/ "Title") on this step can be found at

#### Step 4: Check for Errors & Reboot
- Check for any errors. If everything looks good, then run the following command:
```sh
sudo reboot
```

#### Step 5: Connect
- Connect your device to WiFi Access Point
  - SSID: BrightLink
  - PASS: raspberry
- Open your web browser on  [http://bubble](http://bubble "bubble")
