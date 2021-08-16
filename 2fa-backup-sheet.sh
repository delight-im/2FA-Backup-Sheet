#!/bin/bash

# Exit immediately when statements or commands (outside of tests and conditions) fail (with a non-zero exit status)
set -e

# Fail on references to unset variables or parameters
set -u

# Make pipelines fail if any command within (i.e. not just the last one) fails
set -o pipefail

# Don't return literal expressions with asterisks if a glob doesn't match but instead make the glob fail
shopt -s failglob

canvasWidth=$((210 * 300 * 393701/10000000)) # mm * dpi * inch/mm
canvasHeight=$((297 * 300 * 393701/10000000)) # mm * dpi * inch/mm
backgroundColor="white"
paddingTop=$((20 * 300 * 393701/10000000)) # mm * dpi * inch/mm
paddingBottom=$((20 * 300 * 393701/10000000)) # mm * dpi * inch/mm
textTitle=${1:-}
textSubtitle=${3:-}
textDate=${4:-"$(date +'%Y-%m-%d')"}
textRecoveryCodes=${2:-}
pathKeyUriQrCode=${5:-}
linesTitle=$(echo "$textTitle" | sed 's/\\n/\n/g' | wc -l)
linesSubtitle=$(echo "$textSubtitle" | sed 's/\\n/\n/g' | wc -l)
linesDate=$(echo "$textDate" | sed 's/\\n/\n/g' | wc -l)
linesRecoveryCodes=$(echo "$textRecoveryCodes" | sed 's/\\n/\n/g' | wc -l)

if [ -n "$textTitle" ]; then hasTitle=1; else hasTitle=0; fi
if [ -n "$textSubtitle" ]; then hasSubtitle=1; else hasSubtitle=0; fi
if [ -n "$textDate" ]; then hasDate=1; else hasDate=0; fi
if [ -n "$textRecoveryCodes" ]; then hasRecoveryCodes=1; else hasRecoveryCodes=0; fi
if [ -n "$pathKeyUriQrCode" ]; then hasKeyUriQrCode=1; else hasKeyUriQrCode=0; fi

qrCodeSize=$((canvasWidth * 2/5))
fontPathRegular=${6:-"/usr/share/fonts/truetype/ubuntu/UbuntuMono-R.ttf"}

if [ -z "${6:-}" ]; then
	fontPathBold=${7:-"/usr/share/fonts/truetype/ubuntu/UbuntuMono-B.ttf"}
else
	fontPathBold=${7:-${fontPathRegular}}
fi

fontScale=${8:-"100"}
fontSizeTitle=$((160 * fontScale/100))
fontSizeSubtitle=$((112 * fontScale/100))
fontSizeDate=$((112 * fontScale/100))

if [ "$hasKeyUriQrCode" -eq 1 ]; then
	fontSizeRecoveryCodes=$((72 * fontScale/100))
else
	fontSizeRecoveryCodes=$((96 * fontScale/100))
fi

upperHeight=$((canvasHeight * 1/2 - qrCodeSize * 1/2))

if [ "$hasTitle" -eq 1 ] || [ "$hasSubtitle" -eq 1 ] || [ "$hasDate" -eq 1 ]; then
	upperSpacing=$(((upperHeight - paddingTop - fontSizeTitle - fontSizeSubtitle - fontSizeDate) / (hasTitle + hasSubtitle + hasDate)))
else
	upperSpacing=0
fi

lowerHeight=$((canvasHeight * 1/2 - qrCodeSize * 1/2))

if [ "$hasRecoveryCodes" -eq 1 ]; then
	lowerSpacing=$(((lowerHeight - paddingBottom - fontSizeRecoveryCodes * linesRecoveryCodes * hasRecoveryCodes) / hasRecoveryCodes))
else
	lowerSpacing=0
fi

positionVerticalTitle=$paddingTop
positionVerticalSubtitle=$((paddingTop + (fontSizeTitle + upperSpacing) * hasTitle))
positionVerticalDate=$((paddingTop + (fontSizeTitle + upperSpacing) * hasTitle + (fontSizeSubtitle + upperSpacing) * hasSubtitle))
positionVerticalRecoveryCodes=$((upperHeight + qrCodeSize + lowerSpacing))
outputFilename=${9:-"2fa-backup-$(date +'%Y%m%dT%H%M%S').png"}
outputFileBasename="${outputFilename%.*}"
outputFileExtension="${outputFilename##*.}"

if [ "$#" -lt 2 ]; then
	echo 'Usage:'
	echo '  $ bash ./2fa-backup-sheet.sh <TITLE> <RECOVERY_CODES> [<SUBTITLE> [<DATE> [<OTP_KEY_URI_QR_PATH> [<FONT_PATH_REGULAR> [<FONT_PATH_BOLD> [<FONT_SCALE> [<OUTPUT_FILE_PATH>]]]]]]]'
	echo ''
	echo '  # e.g.'
	echo ''
	# shellcheck disable=SC2028
	echo '  # bash ./2fa-backup-sheet.sh "Google" "2589 0449\n5908 3492\n8491 4533\n2560 0808"'
	echo '  # or'
	# shellcheck disable=SC2028
	echo '  # bash ./2fa-backup-sheet.sh "Twitter" "3234 8651\n5962 8640\n2490 2239\n2873 6327\n5730 5927\n4371 8506\n9858 8718\n3884 9458\n9110 6833\n8815 4916" "john.doe@example.com" "" "key-uri-qr-code-screenshot.png" "RobotoMono-Regular.ttf" "RobotoMono-Bold.ttf" "75" "backup-sheet-twitter.png"'
	exit 1
fi

if [ "$linesTitle" -gt 1 ]; then
	echo ' ! You cannot use more than 1 line of text in the title'
	exit 2
fi

if [ "$linesSubtitle" -gt 1 ]; then
	echo ' ! You cannot use more than 1 line of text in the subtitle'
	exit 3
fi

if [ "$linesDate" -gt 1 ]; then
	echo ' ! You cannot use more than 1 line of text for the date'
	exit 4
fi

if [ "$linesRecoveryCodes" -gt 10 ]; then
	echo ' ! You cannot use more than 10 lines of text for the recovery codes'
	exit 5
fi

if [ ! -r "$fontPathRegular" ]; then
	echo ' ! Could not read path for regular font'
	exit 6
fi

if [ ! -r "$fontPathBold" ]; then
	echo ' ! Could not read path for bold font'
	exit 7
fi

if [ "$hasKeyUriQrCode" -eq 1 ]; then
	# Remove areas surrounding QR code itself
	convert "$pathKeyUriQrCode" -bordercolor white -border 1x1 -white-threshold 50% -transparent white -trim +repage "${outputFileBasename}.2cdcd308.${outputFileExtension}"
	# Resize the QR code to the desired size
	convert "${outputFileBasename}.2cdcd308.${outputFileExtension}" -resize "${qrCodeSize}x${qrCodeSize}" "${outputFileBasename}.3f9de271.${outputFileExtension}"
	# Remove temporary file
	rm "${outputFileBasename}.2cdcd308.${outputFileExtension}"
	# Place the QR code at the center of the overall canvas
	convert "${outputFileBasename}.3f9de271.${outputFileExtension}" -gravity center -background "$backgroundColor" -extent "${canvasWidth}x${canvasHeight}" "${outputFileBasename}.f576a167.${outputFileExtension}"
	# Remove temporary file
	rm "${outputFileBasename}.3f9de271.${outputFileExtension}"
else
	convert -size "${canvasWidth}x${canvasHeight}" canvas:"$backgroundColor" "${outputFileBasename}.f576a167.${outputFileExtension}"
fi

# Write the title to the canvas
convert "${outputFileBasename}.f576a167.${outputFileExtension}" -gravity north -font "$fontPathBold" -pointsize "$fontSizeTitle" -annotate "+0+${positionVerticalTitle}" "$textTitle" "${outputFileBasename}.8822c7ef.${outputFileExtension}"
# Remove temporary file
rm "${outputFileBasename}.f576a167.${outputFileExtension}"
# Write the subtitle to the canvas
convert "${outputFileBasename}.8822c7ef.${outputFileExtension}" -gravity north -font "$fontPathRegular" -pointsize "$fontSizeSubtitle" -annotate "+0+${positionVerticalSubtitle}" "$textSubtitle" "${outputFileBasename}.25a0da4b.${outputFileExtension}"
# Remove temporary file
rm "${outputFileBasename}.8822c7ef.${outputFileExtension}"
# Write the date to the canvas
convert "${outputFileBasename}.25a0da4b.${outputFileExtension}" -gravity north -font "$fontPathRegular" -pointsize "$fontSizeDate" -annotate "+0+${positionVerticalDate}" "$textDate" "${outputFileBasename}.6a23dc41.${outputFileExtension}"
# Remove temporary file
rm "${outputFileBasename}.25a0da4b.${outputFileExtension}"
# Write the recovery codes to the canvas
convert "${outputFileBasename}.6a23dc41.${outputFileExtension}" -gravity north -font "$fontPathRegular" -pointsize "$fontSizeRecoveryCodes" -annotate "+0+${positionVerticalRecoveryCodes}" "$textRecoveryCodes" "${outputFileBasename}.345599c2.${outputFileExtension}"
# Remove temporary file
rm "${outputFileBasename}.6a23dc41.${outputFileExtension}"
# Move the result so that the output file has the desired filename
mv "${outputFileBasename}.345599c2.${outputFileExtension}" "$outputFilename"

echo 'Written to:'
echo "  $outputFilename"

exit 0
