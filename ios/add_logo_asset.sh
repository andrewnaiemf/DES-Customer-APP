#!/bin/bash

# Create Assets catalog if not exists
mkdir -p "Runner/Assets.xcassets/logoicon.imageset"

# Copy SVG to assets (as PDF for vector support)
cp "../assets/svg/logoicon.svg" "Runner/Assets.xcassets/logoicon.imageset/logoicon.svg"

# Create Contents.json
cat > "Runner/Assets.xcassets/logoicon.imageset/Contents.json" << 'INNER_EOF'
{
  "images" : [
    {
      "filename" : "logoicon.svg",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}
INNER_EOF

echo "✅ Logo asset added successfully!"
echo "📍 Location: Runner/Assets.xcassets/logoicon.imageset/"
