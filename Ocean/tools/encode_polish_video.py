import bpy, json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
folders=[root/'build/polish-animation-frames',root/'build/polish-rare-frames']
assert all(list(folder.glob('*.jpg')) for folder in folders)
s=bpy.context.scene
s.render.resolution_x=1300;s.render.resolution_y=1000;s.render.resolution_percentage=100
s.render.fps=15
s.frame_start=1
s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1
editor=s.sequence_editor_create();cursor=1
for folder in folders:
    frames=sorted(folder.glob('*.jpg'))
    strip=editor.strips.new_image('Roblox Studio '+folder.name,str(frames[0]),1,cursor)
    for frame in frames[1:]:strip.elements.append(frame.name)
    cursor+=len(frames)
s.frame_end=cursor-1
s.render.image_settings.media_type='VIDEO';s.render.image_settings.file_format='FFMPEG'
s.render.ffmpeg.format='MPEG4';s.render.ffmpeg.codec='H264';s.render.ffmpeg.constant_rate_factor='MEDIUM'
s.render.filepath=str(root/'build/SuckTheSea-visual-polish.mp4')
bpy.ops.render.render(animation=True)
print('POLISH_VIDEO_ENCODED',cursor-1)
