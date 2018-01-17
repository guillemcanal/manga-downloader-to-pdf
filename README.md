# Manga Downlader to PDFs

 Convert chapters folders containing images into a nice PDF

 ## Dependencies

 imagemagick (the `convert` and `identify` tools)

 ## Usage: 
 
 Downloaded chapters from a manga using manga-download.sh from https://github.com/briefbanane/manga-downloader
 
 Run `./convert.sh [DIRECTORY_PATH_CONTAINING_CHAPTERS_FOLDERS] [PDF_TITLE]`

 ### Example:

```bash
./manga-downloader.sh http://www.japscan.com/mangas/deadman-wonderland/
./convert.sh ./deadman-wonderland "Deadman Wonderland"
```
