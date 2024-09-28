> [!NOTE]  
> Much of this codebase is literally just the Tiktok template from Remotion
> The part which I configured is adding titles, and the automation part via ffmpeg...

# How to run

1. Download movie (preferabbly legally)
2. Put movie mp4 in `/public`
3. Find start and end timestamps that you wish to "clip"
4. Chnage the title of the video in `src/CaptionedVideo/index.tsx` (should probably add config for this.)
5. Use `process_video.sh` and follow instructions to clip video
6. Run `npm start` to use the remotion "editor" to render the clip

The result will be a captioned tiktok style movie thing.

# How does it work?

1. Uses ffmpeg to extract certain cut from the full mp4 based on timestamps you provide
2. Grabs that new video and converts it into 9:16 aspect ratio (titkok/reels/shorts style)
3. Uses the `sub.mjs` which uses whisper to create captions for the video
4. Finally, the video is renderd by you using the Remotion "editor" via `npm start`
