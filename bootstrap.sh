#!/usr/bin/env bash
echo "iOS cross compiler installer for Linux"
echo "Made by guacaplushy"

workdir=$(mktemp -d)
outdir=$(mktemp -d)
finaldir=$HOME/.ios_cc_toolchain
rm -rf $finaldir
mkdir -p $finaldir
mkdir -p $finaldir/bin

echo "[*] Installing dependencies"
sudo apt install libplist-dev cmake clang build-essential unzip -y > /dev/null

# sdk download
echo "[*] Downloading & extracting SDK"
mkdir $workdir/SDK
wget -q https://github.com/xybp888/iOS-SDKs/releases/download/iOS-SDKs/iPhoneOS16.1.sdk.zip -O $workdir/iPhoneOS16.1.sdk.zip
unzip -o $workdir/iPhoneOS16.1.sdk.zip -d $workdir/iPhoneOS16.1.sdk > /dev/null
echo "[*] Repacking SDK"
tar caf $workdir/iPhoneOS16.1.sdk.tar.xz $workdir/iPhoneOS16.1.sdk > /dev/null
rm -rf $workdir/iPhoneOS16.1.sdk.zip $workdir/iPhoneOS16.1.sdk

echo "[*] Installing wrappers"
echo "clang -target aarch64-apple-ios -miphoneos-version-min=15.0 -arch arm64 -arch arm64e -fuse-ld=lld -isysroot $finaldir/SDK/iPhoneOS.sdk \$@" > $outdir/bin/aarch64-apple-ios-clang
echo "ldid -s \$(echo \"\$@\" | grep "\-o" | awk '{split($0, fArr, "-o "); split(fArr[2], sArr, " "); print sArr[2]}'\)" >> $outdir/bin/aarch64-apple-ios-clang
echo "clang++ -target aarch64-apple-ios -miphoneos-version-min=15.0 -arch arm64 -arch arm64e -fuse-ld=lld -stdlib=libc++ -isysroot $finaldir/SDK/iPhoneOS.sdk \$@" > $outdir/bin/aarch64-apple-ios-clang++
echo "echo \"\$@\" | grep "\-o" | awk '{split($0, fArr, "-o "); split(fArr[2], sArr, " "); print sArr[2]}'" >> $outdir/bin/aarch64-apple-ios-clang++

echo "[*] Cloning cctools"
git clone --recursive https://github.com/guacaplushy/cctools-port $workdir/cctools > /dev/null

cd $workdir/cctools/usage_examples/ios_toolchain
echo "[*] Compiling cctools"
./build.sh $workdir/iPhoneOS16.1.sdk.tar.xz arm64 > /dev/null
mv target/* $outdir
echo "[*] Compiling ldid"
git clone https://github.com/ProcursusTeam/ldid $workdir/ldid > /dev/null
cd $workdir/ldid
make -j2 > /dev/null
DESTDIR=$outdir make install > /dev/null 
echo "[*] Finishing up"
rm -rf $workdir
mv $outdir/* $finaldir
rm -rf $outdir
echo "export PATH=$finaldir/bin:\$PATH" >> $HOME/.bashrc
echo "[*] Done! If your shell is not bash, you must add $finaldir to your PATH in your shell's rc file."
