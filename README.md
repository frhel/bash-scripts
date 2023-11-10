# bash-scripts
A collection of Bash scripts I'm writing for various things I might find useful

## img_opt.sh - Image optimization

A simple script that crawls a directory and uses Imagemagick to optimize images for web by setting DPI to 72, changing size and lowering quality. There is a ton of stuff yet to be done with it, but for now it's in a usable state for simple drop-in optimizations.
 - Does not follow symlinks by default.
 - Creates a folder called original_bak in every folder where an image has been altered, retaining the original so it can be used later for restoring (am planning to add a way to clean the backups out, and choose a different folder name.)
 - Always resizes and sets quality. Am planning to make it possible to pick only one and also to convert between formats
 - Offers to replace whitespaces in filenames with underscores to make them usable.

Usage: img_opt.sh [options] - use ./img_opt.sh if the script is not in your PATH and isn't executable  
Options:  
**-h** Show help message  
**-R** Recurse into subdirectories.  
**-w** Set the maximum width of the images  
**-q** Set the quality percentage of the images (defaults to 60%)  
**-t** Set the types of images to optimize (defaults to jpg, png and webp)  
**-d** Set the starting directory (defaults to current directory)  
**-r** Restore images to their original state  

Example: img_opt.sh (asks for width and quality, optimizes all images in the current directory but doesn't crawl through subdirectories)  
Example: img_opt.sh -Rw 1920 -q 60 -t jpg png -d ./static/img (optimizes all jpg and png images in ./static/img/ and its subdirectories with a maximum width of 1920px and a quality of 60%)  
Example: img_opt.sh -r (restores all images in the current directory)  
Example: img_opt.sh -Rrd ./img (recursively restores all images in the "img" subdirectory and its subfolders)  
