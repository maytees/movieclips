

# Function to display usage information
usage() {
    echo "Usage: $0 <input_file> <output_file> <stereo|mono>"
    echo "  <input_file>: Path to the input video file"
    echo "  <output_file>: Path to the output video file"
    echo "  <stereo|mono>: Desired audio channel type"
    exit 1
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg to use this script."
    exit 1
fi

# Check if correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

# Assign arguments to variables
input_file="$1"
output_file="$2"
channel_type="$3"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file does not exist."
    exit 1
fi

# Validate channel type
if [ "$channel_type" != "stereo" ] && [ "$channel_type" != "mono" ]; then
    echo "Error: Invalid channel type. Use 'stereo' or 'mono'."
    usage
fi

# Function to get current audio channel count
get_channel_count() {
    ffprobe -v error -select_streams a:0 -count_packets -show_entries stream=channels -of csv=p=0 "$1"
}

# Get current channel count
current_channels=$(get_channel_count "$input_file")

# Convert audio
convert_audio() {
    if [ "$channel_type" = "stereo" ] && [ "$current_channels" -eq 1 ]; then
        ffmpeg -i "$input_file" -ac 2 "$output_file"
    elif [ "$channel_type" = "mono" ] && [ "$current_channels" -ne 1 ]; then
        ffmpeg -i "$input_file" -ac 1 "$output_file"
    else
        echo "The audio is already in $channel_type format. Copying file..."
        cp "$input_file" "$output_file"
    fi
}

# Perform conversion
echo "Converting audio to $channel_type..."
convert_audio

# Verify conversion
new_channels=$(get_channel_count "$output_file")
if [ "$channel_type" = "stereo" ] && [ "$new_channels" -eq 2 ]; then
    echo "Conversion to stereo successful."
elif [ "$channel_type" = "mono" ] && [ "$new_channels" -eq 1 ]; then
    echo "Conversion to mono successful."
else
    echo "Conversion may have failed. Please check the output file."
fi


