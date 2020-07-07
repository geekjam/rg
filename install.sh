#!/bin/sh
set -e
VERSION='12.1.1'
URL_HEAD='https://github.com/BurntSushi/ripgrep/releases/download/'
if [ "$china" = '1' ]; then
	URL_HEAD='https://github.wanvi.net/https:/github.com/BurntSushi/ripgrep/releases/download/'
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

FILE_NAME="ripgrep-12.1.1-x86_64-unknown-linux-musl"

un="$(uname -s)"
if [  "$un" = 'Darwin' ]; then
	FILE_NAME="ripgrep-$VERSION-x86_64-apple-darwin"
fi
un=$(uname -m)
case $un in
	aarch64) un="arm" ;;
	armv5*) un="arm" ;;
	armv6*) un="arm" ;;
	armv7*) un="arm" ;;
esac
if [  "$un" = 'arm' ]; then
	FILE_NAME="ripgrep-$VERSION-arm-unknown-linux-gnueabihf"
fi

is_command() {
  command -v "$1" >/dev/null
}

http_download_curl() {
	local_file=$1
	source_url=$2
	header=$3
	echo $local_file
	echo $source_url
	echo $header
	if [ -z "$header" ]; then
		code=$(curl -w '%{http_code}' -L -o "$local_file" "$source_url")
	else
		code=$(curl -w '%{http_code}' -L -H "$header" -o "$local_file" "$source_url")
	fi
	if [ "$code" != "200" ]; then
		echo "http_download_curl received HTTP status $code"
		return 1
	fi
	return 0
}
http_download_wget() {
	local_file=$1
	source_url=$2
	header=$3
	if [ -z "$header" ]; then
		wget -O "$local_file" "$source_url"
	else
		wget --header "$header" -O "$local_file" "$source_url"
	fi
}
http_download() {
	echo "http_download $2"
	if is_command wget; then
		http_download_wget "$@"
		return
	elif is_command curl; then
		http_download_curl "$@"
		return
	fi
	echo "http_download unable to find wget or curl"
	return 1
}

untar() {
  tarball=$1
  case "${tarball}" in
    *.tar.gz | *.tgz) tar --no-same-owner -xzf "${tarball}" ;;
    *.tar) tar --no-same-owner -xf "${tarball}" ;;
    *.zip) unzip "${tarball}" ;;
    *)
      echo "untar unknown archive format for ${tarball}"
      return 1
      ;;
  esac
}

unix_like_install() {
	filename=$1
	tmpdir=$(mktemp -d)
	url="$URL_HEAD/$VERSION/$filename.tar.gz"
	echo 'Installing for linux..'
	http_download "${tmpdir}/${filename}.tar.gz" "${url}"
	(cd "${tmpdir}" && untar "${filename}.tar.gz")
	mv "${tmpdir}/${filename}/rg" bin/rg
	chmod a+x "bin/rg"
	rm -rf "${tmpdir}"
}

unix_like_install $FILE_NAME
echo "Complete."