"""Encode the actual 12fps Studio QA capture; no generated frames or audio."""
import bpy
from pathlib import Path
root = Path(__file__).resolve().parents[1]
frames = sorted((root / 'build/sparkle-animation-frames').glob('0*.jpg'))
assert len(frames) == 216
scene = bpy.context.scene
scene.render.resolution_x = 1300
scene.render.resolution_y = 1000
scene.render.resolution_percentage = 100
scene.render.fps = 12
scene.frame_start = 1
scene.frame_end = len(frames)
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0
scene.view_settings.gamma = 1
strip = scene.sequence_editor_create().strips.new_image('Studio QA capture', str(frames[0]), 1, 1)
for frame in frames[1:]:
    strip.elements.append(frame.name)
scene.render.image_settings.media_type = 'VIDEO'
scene.render.image_settings.file_format = 'FFMPEG'
scene.render.ffmpeg.format = 'MPEG4'
scene.render.ffmpeg.codec = 'H264'
scene.render.ffmpeg.constant_rate_factor = 'MEDIUM'
scene.render.filepath = str(root / 'build/SuckTheSea-sparkle-animations.mp4')
bpy.ops.render.render(animation=True)
print('SPARKLE_VIDEO_ENCODED', len(frames), flush=True)
