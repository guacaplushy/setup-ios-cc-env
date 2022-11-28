#!/usr/bin/env bash

workdir=$(mktemp -d)
outdir=$(mktemp -d)
finaldir=$HOME/.ios_cc_toolchain
mkdir -p $finaldir
mkdir -p $finaldir/bin

# sdk download
mkdir $workdir/SDK
wget https://github.com/xybp888/iOS-SDKs/releases/download/iOS-SDKs/iPhoneOS16.1.sdk.zip -O $workdir/iPhoneOS16.1.sdk.zip
unzip -o $workdir/iPhoneOS16.1.sdk.zip -d $workdir/iPhoneOS16.1.sdk
tar caf $workdir/iPhoneOS16.1.sdk.tar.xz $workdir/iPhoneOS16.1.sdk
rm -rf $workdir/iPhoneOS16.1.sdk.zip $workdir/iPhoneOS16.1.sdk


echo "clang -target aarch64-apple-ios -miphoneos-version-min=15.0 -arch arm64 -arch arm64e -fuse-ld=lld -isysroot $finaldir/SDK/iPhoneOS.sdk \$@" > $outdir/bin/aarch64-apple-ios-clang
echo "ldid -s \$(echo \"\$@\" | grep "\-o" | awk '{split($0, fArr, "-o "); split(fArr[2], sArr, " "); print sArr[2]}'\)" >> $outdir/bin/aarch64-apple-ios-clang
echo "clang++ -target aarch64-apple-ios -miphoneos-version-min=15.0 -arch arm64 -arch arm64e -fuse-ld=lld -stdlib=libc++ -isysroot $finaldir/SDK/iPhoneOS.sdk \$@" > $outdir/bin/aarch64-apple-ios-clang++
echo "echo \"\$@\" | grep "\-o" | awk '{split($0, fArr, "-o "); split(fArr[2], sArr, " "); print sArr[2]}'" >> $outdir/bin/aarch64-apple-ios-clang++

git clone --recursive https://github.com/guacaplushy/cctools-port $workdir/cctools

cd $workdir/cctools/usage_examples/ios_toolchain
./build.sh $workdir/iPhoneOS16.1.sdk.tar.xz arm64
mv target/* $outdir
rm -rf $workdir
mv $outdir/* $finaldir
rm -rf $outdir
find $finaldir/bin -type f -print0 -exec sudo ln -s {} /usr/local/bin/$(basename {}) \;
