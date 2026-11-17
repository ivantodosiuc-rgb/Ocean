import bpy,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'build/animation-frames-final'
frames=sorted(folder.glob('*.jpg'))
assert frames
s=bpy.context.scene;s.render.resolution_x=1300;s.render.resolution_y=1000;s.render.resolution_percentage=100;s.render.fps=json.loads((folder/'timing.json').read_text(encoding='utf-8-sig'))['fps'];s.frame_start=1;s.frame_end=len(frames)
s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1
editor=s.sequence_editor_create();strip=editor.strips.new_image('Actual Roblox Studio Play capture',str(frames[0]),1,1)
for frame in frames[1:]:strip.elements.append(frame.name)
s.render.image_settings.media_type='VIDEO';s.render.image_settings.file_format='FFMPEG';s.render.ffmpeg.format='MPEG4';s.render.ffmpeg.codec='H264';s.render.ffmpeg.constant_rate_factor='MEDIUM';s.render.filepath=str(ROOT/'build/SuckTheSea-animations.mp4')
bpy.ops.render.render(animation=True)
print('STUDIO_VIDEO_ENCODED',len(frames))
