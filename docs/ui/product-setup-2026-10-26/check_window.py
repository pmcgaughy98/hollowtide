from pathlib import Path
from ctypes import wintypes as T
from PIL import Image,ImageChops,ImageStat
import ctypes as C,json
W=Path(__file__).parent
def capture(pid):
 u=C.WinDLL('user32',use_last_error=True);g=C.WinDLL('gdi32',use_last_error=True)
 cbtype=C.WINFUNCTYPE(T.BOOL,T.HWND,T.LPARAM);windows=[]
 def visit(hwnd,param):
  actual=T.DWORD();u.GetWindowThreadProcessId(hwnd,C.byref(actual))
  if actual.value==pid and u.IsWindowVisible(hwnd):windows.append(hwnd)
  return True
 u.EnumWindows(cbtype(visit),0);assert windows,'No visible test window'
 u.SendMessageW.argtypes=[T.HWND,T.UINT,T.WPARAM,T.LPARAM];u.SendMessageW.restype=T.LPARAM
 hicon=u.SendMessageW(windows[0],0x7f,1,0);assert hicon,'No native large window icon'
 class Header(C.Structure):_fields_=[('size',T.DWORD),('width',T.LONG),('height',T.LONG),('planes',T.WORD),('bits',T.WORD),('compression',T.DWORD),('image_size',T.DWORD),('xppm',T.LONG),('yppm',T.LONG),('used',T.DWORD),('important',T.DWORD)]
 class Info(C.Structure):_fields_=[('header',Header),('colour',T.DWORD*3)]
 info=Info();info.header=Header(C.sizeof(Header),256,-256,1,32,0,0,0,0,0,0);bits=C.c_void_p()
 g.CreateCompatibleDC.argtypes=[T.HDC];g.CreateCompatibleDC.restype=T.HDC;dc=g.CreateCompatibleDC(None)
 g.CreateDIBSection.argtypes=[T.HDC,C.POINTER(Info),T.UINT,C.POINTER(C.c_void_p),T.HANDLE,T.DWORD];g.CreateDIBSection.restype=T.HBITMAP
 bitmap=g.CreateDIBSection(dc,C.byref(info),0,C.byref(bits),None,0)
 g.SelectObject.argtypes=[T.HDC,T.HGDIOBJ];g.SelectObject.restype=T.HGDIOBJ;old=g.SelectObject(dc,bitmap)
 u.DrawIconEx.argtypes=[T.HDC,C.c_int,C.c_int,T.HANDLE,C.c_int,C.c_int,T.UINT,T.HBRUSH,T.UINT]
 assert u.DrawIconEx(dc,0,0,hicon,256,256,0,None,3)
 im=Image.frombytes('RGBA',(256,256),C.string_at(bits,256*256*4),'raw','BGRA').convert('RGB');im.save(W/'native-window-icon.png')
 expected=Image.open(W/'icon.png').convert('RGB');mae=sum(ImageStat.Stat(ImageChops.difference(im,expected)).mean)/3
 g.SelectObject(dc,old);g.DeleteObject.argtypes=[T.HGDIOBJ];g.DeleteObject(bitmap);g.DeleteDC.argtypes=[T.HDC];g.DeleteDC(dc)
 result={'pid':pid,'window_icon_captured':True,'mean_rgb_error_to_app_icon':mae,'passed':mae<15.0};(W/'window-icon-result.json').write_text(json.dumps(result,indent=2));assert result['passed'],result
