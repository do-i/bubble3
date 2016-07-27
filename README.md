# Bubble 3
### Setup Raspberry Pi with Rappbian Jessie Lite (headless mode)
#### Step 1: Run raspbianizer3.sh
- Specify the correct device path to the fresh SD card (e.g. /dev/sdd, /dev/sde, or /dev/sdx)
- Check that the SD card does not have partitions
- Example:
```sh
curl -skL "https://raw.githubusercontent.com/do-i/bubble/master/raspbianizer3.sh" | sudo bash -s /dev/sdx"
```

#### Step 2: Boot-up Raspberry Pi3 using SD card & SSH
- Take out the CD card from your computer and put it in the Raspberry Pi
- Check that the Cat 5 cable connects between your router and the Raspberry Pi
- Ensure the USB holding your data is connected to the Pi before powering up

#### Step 3: Install & Configure
```sh
curl -skL "https://raw.githubusercontent.com/do-i/bubble3/master/bin/install.sh" | sudo bash
```
- Note: A great [instructional article](https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostpad/ "Title") on this step can be found at

#### Step 4: Check for Errors & Reboot
- Check for any errors. If everything looks good, then run the following command:
```sh
sudo reboot
```

#### Step 5: Connect
- Connect your device to BrightLink SSIDotyth, Password: raspberry
- Open your web browser on 192.168.8.64 or [http://bubble](http://bubble "title")
- Note: An article on [Pi Router](https://ronnyvdbr.github.io/r "title") (totally unrelated but interesting nonetheless)
