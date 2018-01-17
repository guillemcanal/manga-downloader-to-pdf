#!/bin/bash

#
# Convert chapters folders containing images into a nice PDF
#
# Dependencies:  
# imagemagick (the convert and identify tools)
#
# Usage: 
# - Downloaded chapters from a manga using manga-download.sh from https://github.com/briefbanane/manga-downloader
# - ./this_script.sh [DIRECTORY_PATH_CONTAINING_CHAPTERS_FOLDERS] [PDF_TITLE]
#
# Example:
# ./manga-downloader.sh http://www.japscan.com/mangas/deadman-wonderland/
# ./this_script.sh ./deadman-wonderland "Deadman Wonderland"
#

shopt -s extglob

# Trap interrupts and exit instead of continuing the loop
trap "echo Exited!; exit;" SIGINT SIGTERM

clear_last_line() {
    tput cuu 1 && tput el
}

# split double pages (when the width is larger than the height basically)
split_double_pages() {
	echo "[info] splitting double pages... (it will take a while)"
	echo

	local CHAPTERS_DIR="$1"
	local TOTAL="$(ls ${CHAPTERS_DIR}/*/page-*.jpg | wc -l)"
	local COUNT=0
	
	TOTAL=$(($TOTAL+0))
	
	for FILE in ${CHAPTERS_DIR}/*/page-*.jpg; do
		COUNT=$(($COUNT+1))

		local DIRNAME=$(dirname $FILE)
		local FILENAME="${FILE##*/}"
		local BASENAME="${FILENAME%%.*}"
		local SIZES=$(identify -format "%[fx:w] %[fx:h]" $FILE)
		local WIDTH=$(($(echo $SIZES | awk '{ print $1}') + 0))
		local HEIGHT=$(($(echo $SIZES | awk '{ print $2}') + 0))

		clear_last_line
		if [ $WIDTH -gt $HEIGHT ];then
			echo "${COUNT}/${TOTAL} : splitting $FILE"
			convert $FILE -crop 50%x100% +repage ${DIRNAME}/${BASENAME}-%d.jpg
			mv "${DIRNAME}/${BASENAME}.jpg" "${DIRNAME}/${BASENAME}.jpg.bak" 
		else
			echo "${COUNT}/${TOTAL} : skipping $FILE"
		fi
	done
}

convert_to_pdf() {
	echo "[info] creating PDFs..."
	echo

	local CHAPTERS_DIR="$1"
	local PDF_TITLE="$2"
	local TOTAL="$(ls ${CHAPTERS_DIR} | wc -l)"
	local COUNT=0

	TOTAL=$(($TOTAL+0))

	for DIR in ${CHAPTERS_DIR}/*;do
		if [ ! -d "$DIR" ];then
			continue
		fi
		
		COUNT=$(($COUNT+1))

		local SANITIZED_TITLE="$(echo ${PDF_TITLE} | tr -cd '[[:alnum:]]._- ')"
		local SANITIZED_CHAPTER="$(echo ${DIR##*/} | tr -cd '[[:alnum:]]._- ')"
		local TITLE="$SANITIZED_TITLE $SANITIZED_CHAPTER.pdf"
		
		clear_last_line
		echo "${COUNT}/${TOTAL} : creating $TITLE"

		# @TODO Allow the user to provide a custom pixel density and a custom size
		convert "${DIR}/page-*.jpg" -quality 95 -density 226 -scale 1404x1872 -filter Lanczos -background white -gravity center -extent 1404x1872 "$TITLE"
	done
}

main() {
	# @TODO Validate variables
	local CHAPTERS_DIR="$1"
	local PDF_TITLE="$2"

	# @TODO allow the user to skip splitting double pages
	split_double_pages "$CHAPTERS_DIR"
	
	convert_to_pdf "$CHAPTERS_DIR" "$PDF_TITLE"	 
}

main "$@"
