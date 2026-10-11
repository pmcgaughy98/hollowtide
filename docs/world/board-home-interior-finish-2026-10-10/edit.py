from pathlib import Path
W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(r,old,new):
    raw=(W/'originals'/r).read_bytes()
    crlf=b'\r\n' in raw
    s=raw.decode('utf-8').replace('\r\n','\n')
    assert s.count(old)==1,(r,old[:80])
    s=s.replace(old,new)
    (C/r).write_bytes(s.replace('\n','\r\n').encode('utf-8') if crlf else s.encode('utf-8'))
edit('scripts/town/room_painter.gd','\treturn img\n','\tif id == "home":\n\t\tpreload("res://scripts/town/home_room_details.gd").finish(img)\n\treturn img\n')
edit('scripts/town/job_board_painter.gd','\tsprite.texture = load(ART)\n\tFinish.apply(sprite, true)', '''\tsprite.texture = _display_texture()
\tFinish.apply(sprite, true)
\t# Full purposeful-building ink on the frame, posts and notice details.
\tsprite.material.set_shader_parameter("detail_ink", 1.0)''')
p=C/'scripts/town/job_board_painter.gd'
raw=p.read_bytes(); crlf=b'\r\n' in raw;s=raw.decode('utf-8').replace('\r\n','\n')
at='static func _visual_offset() -> Vector2:'
fn='''static func _display_texture() -> Texture2D:
\t# Display swatches only. Original stand, papers, ink, alpha and footprint are retained.
\tvar img := load(ART).get_image().duplicate() as Image
\tvar wood := [Color("#59432f"), Color("#8a6a48"), Color("#b59768")]
\tfor y in img.get_height():
\t\tfor x in img.get_width():
\t\t\tvar c := img.get_pixel(x,y)
\t\t\tif c.a<0.5 or c.get_luminance()<0.13 or c.r>=0.8 or c.r<c.g*1.2 or c.b>c.g*0.8: continue
\t\t\tvar swatch: Color = wood[0 if c.get_luminance()<0.28 else (1 if c.get_luminance()<0.48 else 2)]
\t\t\tswatch.a=c.a
\t\t\timg.set_pixel(x,y,swatch)
\treturn ImageTexture.create_from_image(img)

'''
assert s.count(at)==1;s=s.replace(at,fn+at)
p.write_bytes(s.replace('\n','\r\n').encode('utf-8') if crlf else s.encode('utf-8'))
(W/'after.flag').write_text('candidate',encoding='utf-8')
print('Prepared board material finish and Home details; room/controller layouts untouched.')
