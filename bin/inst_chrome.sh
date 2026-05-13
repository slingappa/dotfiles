CHROME_VERSION=132.0.6834.159
wget --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb \
	&& sudo apt install -y /tmp/chrome.deb \
	&& sudo rm /tmp/chrome.deb
