#!/bin/bash
function generateIcon(){
BASE_IMAGE_NAME=$1
TARGET_PATH="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
BASE_IMAGE_PATH=$(find ${SRCROOT} -name ${BASE_IMAGE_NAME})
WIDTH=$(identify -format %w ${BASE_IMAGE_PATH})
convert debugRibbon.png -resize $WIDTHx$WIDTH resizeBetaRibbon.png
FONT_SIZE=$(echo "$WIDTH * .15" | bc -l)
convert ${BASE_IMAGE_PATH} -fill white -font Times-Bold -pointsize ${FONT_SIZE} -gravity south -annotate 0 "1.2.2" temp.png
composite resizeBetaRibbon.png temp.png ${TARGET_PATH}$1
rm temp.png
}
generateIcon "AppIcon20x20@2x.png"
generateIcon "AppIcon20x20@3x.png"
generateIcon "AppIcon29x29@2x.png"
generateIcon "AppIcon29x29@3x.png"
generateIcon "AppIcon40x40@2x.png"
generateIcon "AppIcon40x40@3x.png"
generateIcon "AppIcon60x60@2x.png"
generateIcon "AppIcon60x60@3x.png"
