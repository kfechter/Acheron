# Acheron
Utility to Create UEFI Windows installer USB on macOS

# How to Use
1. Install Requirements
   * XCode
   * Homebrew + wimlib
2. clone/download this repo
3. open project in xcode (eventually there may be signed releases, but I do not have a developer subscription)
4. Download the iso from microsoft [here](https://www.microsoft.com/en-us/software-download/windows10ISO)
5. erase the usb you want to use for the installer. GUID partition table, MS-DOS (FAT) format, single partition
6. make sure that this newly erased drive is mounted
7. run the application, select the downloaded iso and the mounted USB
    * you may have to change the signing certificate to your own local one. 
8. click "Create USB" Be patient, this takes a while and currently shows no progress. the UI will appear un-responsive because i am dumb and don't know threading.
9. when completed successfully, the tool will show a green message at the top and unmount the iso and drive.
10. boot your target machine from the USB.
