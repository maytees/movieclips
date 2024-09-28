#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <input_video> <start_time> <end_time> <output_folder>"
    echo "  <input_video>: Path to the input video file"
    echo "  <start_time>: Start time of the clip (format: HH:MM:SS)"
    echo "  <end_time>: End time of the clip (format: HH:MM:SS)"
    echo "  <output_folder>: Path to the output folder"
    exit 1
}

# Check if correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    usage
fi

# Assign arguments to variables
input_video="$1"
start_time="$2"
end_time="$3"
output_folder="$4"

# Check if input video exists
if [ ! -f "$input_video" ]; then
    echo "Error: Input video file does not exist."
    exit 1
fi

# Check if output folder exists, create if it doesn't
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

# Extract filename without extension
filename=$(basename -- "$input_video")
extension="${filename##*.}"
filename="${filename%.*}"

# Generate output filename
output_filename="${filename}_${start_time//:/-}_${end_time//:/-}.${extension}"
output_path="$output_folder/$output_filename"

# Extract the clip using ffmpeg
ffmpeg -i "$input_video" -ss "$start_time" -to "$end_time" -c copy "$output_path"

# Check if ffmpeg command was successful
if [ $? -eq 0 ]; then
    echo "Clip extracted successfully: $output_path"
else
    echo "Error: Failed to extract clip."
    exit 1
fi

