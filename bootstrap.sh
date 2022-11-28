#!/usr/bin/env bash

workdir=$(mktemp -d)
outdir=$(mktemp -d)
finaldir=$HOME/.ios_cc_toolchain

# sdk download
mkdir $workdir/SDK
wget https://github.com/xybp888/iOS-SDKs/releases/download/iOS-SDKs/iPhoneOS16.1.sdk.zip -O $workdir/iPhoneOS16.1.sdk.zip
unzip $workdir/iPhoneOS16.1.sdk.zip -o -d $outdir/SDK
rm -rf $workdir/iPhoneOS16.1.sdk.zip


echo "clang -target aarch64-apple-ios15 -miphoneos-version-min=15.0 -arch arm64 -arch arm64e -fuse-ld=lld -isysroot $finaldir/SDK/iPhoneOS.sdk \$@" > $outdir/aarch64-apple-ios15-clang
echo "ldid -s \$(echo \"\$@\" | grep "\-o" | awk '{split($0, fArr, "-o "); split(fArr[2], sArr, " "); print sArr[2]}'\)" >> $outdir/aarch64-apple-ios15-clang
echo "clang++ -target aarch64-apple-ios15 -miphoneos-version-min=15.0 -arch arm64 -arch arm64e -fuse-ld=lld -stdlib=libc++ -isysroot $finaldir/SDK/iPhoneOS.sdk \$@" > $outdir/aarch64-apple-ios15-clang++
echo "echo \"\$@\" | grep "\-o" | awk '{split($0, fArr, "-o "); split(fArr[2], sArr, " "); print sArr[2]}'" >> $outdir/aarch64-apple-ios15-clang++

git clone --recursive https://github.com/guacaplushy/cctools-port $workdir/cctools

cd $workdir/cctools/usage_examples/ios_toolchain
./build.sh $outdir/SDK arm64
mv target $outdir
mv $outdir $finaldir
find $outdir -type f -print0 -exec sudo ln -s {} /usr/local/bin/{} \;
