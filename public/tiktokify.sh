#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <input_video> <output_video>"
    echo "  <input_video>: Path to the input video file"
    echo "  <output_video>: Path to the output video file"
    exit 1
}

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Assign arguments to variables
input_video="$1"
output_video="$2"

# Check if input video exists
if [ ! -f "$input_video" ]; then
    echo "Error: Input video file does not exist."
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg to use this script."
    exit 1
fi

# Perform the center crop and resize operation
ffmpeg -i "$input_video" -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy "$output_video"

# Check if ffmpeg command was successful
if [ $? -eq 0 ]; then
    echo "Video processed successfully: $output_video"
else
    echo "Error: Failed to process video."
    exit 1
fi
