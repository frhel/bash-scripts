
#!/bin/bash

# Define some color variables
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
PURPLE='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
GREY='\033[0;90m'
NC='\033[0m' # No Color

# Use imagemagick to optimize jpeg and png images recursively through all subdirectories
# under the current directory.

# Create a backup directory where all the original images will be stored
BACKUPS_DIR_NAME="original_bak"

# Read arguments from command line
while getopts "hRw:q:t:d:r" opt; do
  case $opt in
    h)
      echo -e "${NC}Usage: img_opt.sh [options] - use ./img_opt.sh if the script is not in your PATH and isn't executable${NC}"
      echo -e "${NC}Options:${NC}"
      echo -e "${NC}-h${NC}  Show this help message and exit"
      echo -e "${NC}-R${NC}  Crawls through all subdirectories and restores all images to their original state"
      echo -e "${NC}-w${NC}  Set the maximum width of the images (default: 1920)"
      echo -e "${NC}-q${NC}  Set the quality percentage of the images (default: 60)"
      echo -e "${NC}-t${NC}  Set the types of images to optimize (default: jpg png webp)"
      echo -e "${NC}-d${NC}  Set the directory to optimize images in (default: current directory)"
      echo -e "${NC}-r${NC}  Restore images to their original state"
      echo -e "${NC}Examples:${NC}"
      echo -e "${NC}Example: img_opt.sh${NC} (asks for width and quality, optimizes all images in the current directory but doesn't crawl through subdirectories)"
      echo -e "${NC}Example: img_opt.sh -Rw 1920 -q 60 -t jpg png -d ./static/img${NC} (optimizes all jpg and png images in ./static/img/ and its subdirectories with a maximum width of 1920px and a quality of 60%)"
      echo -e "${NC}Example: img_opt.sh -r${NC} (restores all images in the current directory)"
      echo -e "${NC}Example: img_opt.sh -Rr${NC} (restores all images in the current directory and its subdirectories)"
      exit 0
      ;;
    R)
      RECURSIVE="y"
      ;;
    w)
      MAX_WIDTH=$OPTARG
      ;;
    q)
      QUALITY=$OPTARG
      ;;
    t)
      TYPES=($OPTARG)
      ;;
    d)
      TARGET_PATH=$OPTARG
      ;;
    r)
      RESTORE="y"
      ;;
    \?)
      echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
      exit 1
      ;;
    :)
      echo -e "${RED}Option -$OPTARG requires an argument.${NC}" >&2
      exit 1
      ;;
  esac
done

# Check if we are restoring images and let the user know
if [ "$RESTORE" == "y" ]; then
  echo -e "${YELLOW}Restoring images...${NC}"
fi

if [ "$RESTORE" != "y" ]; then
  # If no arguments are given, ask for them
  if [ -z "$MAX_WIDTH" ]; then
    # Ask for width value
    printf "${CYAN}Enter the maximum width of the images (default: 1920): ${NC}"
    read MAX_WIDTH
  fi
  
  if [ -z "$QUALITY" ]; then
    # Ask for quality percentage
    printf "${CYAN}Enter the quality percentage of the images (default: 60): ${NC}"
    read QUALITY
  fi
fi


# Set value defaults if no arguments are given
if [ -z "$MAX_WIDTH" ]; then
  MAX_WIDTH=1920
fi
if [ -z "$QUALITY" ]; then
  QUALITY=60
fi
if [ -z "$TARGET_PATH" ]; then
  TARGET_PATH="."  
fi
if [ -z "$TYPES" ]; then
  TYPES=("jpg" "png" "webp")
fi
MAX_DPI=72



# Check if imagemagick is installed and ask the user if they want to install it if it isn't
if ! [ -x "$(command -v convert)" ]; then
  echo -e "${RED}Dependency: Imagemagick is not installed.${NC}" >&2
  printf "${CYAN}Do you want to install it? (y/n) "
  read install
fi

# Try to install imagemagick if the user wants to
if [ "$install" == "y" ]; then
  if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update
    sudo apt-get install imagemagick
  else
    echo -e "${RED}Could not install imagemagick.${NC}" >&2
    exit 1
  fi
fi

# Function to optimize all images in a directory
# Takes two arguments:
# $1: The directory to optimize images in
# $2: The directory to store backups in
function optimize_images {
  local backup_path=$2;
  if ! [ -d $backup_path ]; then mkdir $backup_path; fi

  # Check if the directory has image files
  local file_types=()
  for type in "${TYPES[@]}"; do
    if [ "$(find $1 -maxdepth 1 -type f -name "*.$type" | wc -l)" -gt 0 ]; then
      file_types+=($type)
    fi
  done
  if ! [ ${#file_types[@]} -gt 0 ]; then return; fi

  # Iterate through all image types
  for type in "${file_types[@]}"; do
    # Iterate through all images of the current type in the directory, backup and optimize them
    for f in $1/*.$type; do
      local underscored_file_name=${f// /_}
      local file_name=$(basename $underscored_file_name)
      local source=$f
      local backup_file="${backup_path}/${file_name}"

      # Putting the restore option here so that we don't have to check if the file exists twice
      # And so that we can reuse the for loops and variables
      if [ "$RESTORE" == "y" ]; then
        if ! [ -f $backup_file ] || ! [ -f $source ]; then
          continue
        fi
        printf "${PURPLE}Restoring${YELLOW} $f...${NC}"
        mv $backup_file $source
        printf "${GREEN}Done.${NC}\n"
        continue
      fi

      # Linux doesn't like spaces in filenames so we need to escape them
      # Rename files with spaces to have underscores instead
      if [[ $source == *" "* ]]; then
        if ! [ "$rename_all" == "y" ]; then        
          echo -e "${RED}Filename has whitespaces:${YELLOW} $source${NC}"
          echo -e "${RED}Do you want to rename it and replace the whitespace with underscores?"
          echo -e "This will rename the file to ${YELLOW}${file_name// /_}${RED} so all references to it will need to be updated."
          printf "${CYAN}(y/n) ${NC}"
          read rename
        fi
        if [ "$rename" == "y" ] || [ "$rename_all" == "y" ]; then
          if [ "$rename_all" != "y" ] && [ "$rename_all" != "n" ]; then
            printf "${CYAN}Do you want to do this for all files? (y/n) ${NC}"
            read rename_all
          fi

          local new_name=${f// /_}
          mv "$source" $new_name
          local source=$new_name
          
          echo -e "${GREEN}Renamed $f${NC}"
        else
          echo -e "${YELLOW}Skipping $f$ due to whitespace in filename${NC}"
          continue
        fi
      fi
      
      # Check if the file exists
      if ! [ -f "$source" ]; then continue; fi            

      # If there already is a backup, use that
      if [ -f $backup_file ]; then
          local source=$backup_file
          continue # Skip the file if there is backup - This line can be removed if you want to re-optimize all images
      else
          cp $source $backup_file
      fi
      
      printf "${PURPLE}Optimizing${YELLOW} $f...${NC}"
      # Actually finally run the optimization command
      convert $source -resize $MAX_WIDTH -density $MAX_DPI -quality $QUALITY $source
      printf "${GREEN}Done.${NC}\n"
    done
  done
}

# The recursive crawler function
function crawl {
  # Define a bunch of guard clauses to avoid errors
  if ! [ -d "$1" ]; then return; fi # Check if the directory exists
  if ! [ "$(ls -A $1)" ]; then return; fi # Check if the directory is empty
  if [[ "$1" == *"${BACKUPS_DIR_NAME}"* ]]; then return; fi # Check if the directory is the backup directory
  # if the directory is a symlink, skip it
  if [ -L $1 ]; then 
    echo -e "${YELLOW}Skipping symlink $1${NC}"
    return
  fi
  
  local d=$1
  local b="${d}/${BACKUPS_DIR_NAME}"
  # Optimize images in the subdirectory
  optimize_images $d $b

  if ! [ "$RECURSIVE" == "y" ]; then return; fi # Check if we should crawl through subdirectories

  for d in $1/*; do    
    crawl $d
  done
}

crawl $TARGET_PATH

echo -e "${GREEN}Finished.${NC}"

exit 0


