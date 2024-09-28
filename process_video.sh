#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <input_file> <output_folder>"
    echo "  <input_file>: Path to the input video file"
    echo "  <output_folder>: Path to the output folder"
    exit 1
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg to use this script."
    exit 1
fi

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Assign arguments to variables
input_file="$1"
output_folder="$2"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file does not exist."
    exit 1
fi

# Check if output folder exists, create if it doesn't
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

# Ask user for output file name
read -p "Enter the desired output file name (without extension): " output_name

# Ask for trimming timestamps
read -p "Enter start time for trimming (format: HH:MM:SS): " start_time
read -p "Enter end time for trimming (format: HH:MM:SS): " end_time

# Ask for audio channel type
read -p "Enter desired audio channel type (stereo/mono): " channel_type

# Validate channel type
if [ "$channel_type" != "stereo" ] && [ "$channel_type" != "mono" ]; then
    echo "Error: Invalid channel type. Use 'stereo' or 'mono'."
    exit 1
fi

# Function to get current audio channel count
get_channel_count() {
    ffprobe -v error -select_streams a:0 -count_packets -show_entries stream=channels -of csv=p=0 "$1"
}

# Step 1: Trim the video
trimmed_output="${output_folder}/${output_name}_trimmed.mp4"
ffmpeg -i "$input_file" -ss "$start_time" -to "$end_time" -c copy "$trimmed_output"

if [ $? -ne 0 ]; then
    echo "Error: Failed to trim video."
    exit 1
fi

echo "Video trimmed successfully."

# Step 2: Convert to 9:16 aspect ratio
aspect_output="${output_folder}/${output_name}_9_16.mp4"
ffmpeg -i "$trimmed_output" -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy "$aspect_output"

if [ $? -ne 0 ]; then
    echo "Error: Failed to convert video to 9:16 aspect ratio."
    exit 1
fi

echo "Video converted to 9:16 aspect ratio successfully."

# Step 3: Convert audio to desired channel type
current_channels=$(get_channel_count "$aspect_output")
final_output="${output_folder}/${output_name}_final.mp4"

if [ "$channel_type" = "stereo" ] && [ "$current_channels" -eq 1 ]; then
    ffmpeg -i "$aspect_output" -ac 2 "$final_output"
elif [ "$channel_type" = "mono" ] && [ "$current_channels" -ne 1 ]; then
    ffmpeg -i "$aspect_output" -ac 1 "$final_output"
else
    echo "The audio is already in $channel_type format. Copying file..."
    cp "$aspect_output" "$final_output"
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to convert audio to $channel_type."
    exit 1
fi

echo "Audio converted to $channel_type successfully."

# Step 4: Generate subtitles
echo "Generating subtitles..."
node sub.mjs "$final_output"

if [ $? -ne 0 ]; then
    echo "Error: Failed to generate subtitles."
    exit 1
fi

echo "Subtitles generated successfully."

echo "All processing steps completed successfully."
echo "Final output: $final_output"
echo "Subtitle file should be in the same directory as the output video."

# Clean up intermediate files
rm "$trimmed_output" "$aspect_output"

echo "Intermediate files cleaned up."