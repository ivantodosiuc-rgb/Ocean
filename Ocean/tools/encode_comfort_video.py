import bpy
from pathlib import Path
root=Path(__file__).resolve().parents[1];frames=sorted((root/'build/comfort-animation-frames').glob('0*.jpg'));assert len(frames)==132
s=bpy.context.scene;s.render.resolution_x=1300;s.render.resolution_y=1000;s.render.resolution_percentage=100;s.render.fps=12;s.frame_start=1;s.frame_end=len(frames)
s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1
strip=s.sequence_editor_create().strips.new_image('Roblox Studio restroom',str(frames[0]),1,1)
for frame in frames[1:]:strip.elements.append(frame.name)
s.render.image_settings.media_type='VIDEO';s.render.image_settings.file_format='FFMPEG';s.render.ffmpeg.format='MPEG4';s.render.ffmpeg.codec='H264';s.render.ffmpeg.constant_rate_factor='MEDIUM';s.render.filepath=str(root/'build/SuckTheSea-restroom.mp4')
bpy.ops.render.render(animation=True);print('COMFORT_VIDEO_ENCODED',len(frames),flush=True)
