#!/bin/bash
echo "Copying app skeleton... 🦴"
cp -r app_bundler/SyphonWeb.app.skeleton/ ./SyphonWeb.app

echo "Compiling binary... ⚙️"
swift build --arch arm64 --arch x86_64 --configuration release

echo "Copying binary and frameworks... 📦"
cp .build/apple/Products/Release/SyphonWeb ./SyphonWeb.app/Contents/MacOS
cp -r .build/apple/Products/Release/Syphon.framework/ ./SyphonWeb.app/Contents/Frameworks/Syphon.framework/

echo "Patching runtime path... 🔨"
install_name_tool -change @rpath/Syphon.framework/Versions/A/Syphon @executable_path/../Frameworks/Syphon.framework/Versions/A/Syphon ./SyphonWeb.app/Contents/MacOS/SyphonWeb

echo "Cleaning up... 🧹"
rm ./SyphonWeb.app/Contents/MacOS/.gitkeep 
rm ./SyphonWeb.app/Contents/Frameworks/.gitkeep 

echo "Done! ✅"