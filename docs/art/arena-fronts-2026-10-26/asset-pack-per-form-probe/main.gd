extends Node
const Loader=preload("res://image_loader.gd")
func _ready() -> void:
 var records: Array=JSON.parse_string(FileAccess.get_file_as_string("res://manifest.json"))
 var total:=0;var failed:=0
 for item in records:
  var p: String="res://"+item.destination
  var texture: bool=ResourceLoader.exists(p)
  var im: Image=Loader.res_image(p)
  var digest:=""
  if im!=null:
   var hashing:=HashingContext.new();hashing.start(HashingContext.HASH_SHA256);hashing.update(im.get_data());digest=hashing.finish().hex_encode()
  var same: bool=im!=null and digest==item.rgba_sha256
  var imported_only: bool=not FileAccess.file_exists(p)
  total+=3
  if not texture or not same or not imported_only:failed+=1
  print(item.form,": imported=",texture," RGBA_exact=",same," no_raw_png=",imported_only)
 total+=1
 var docs_gone:=not ResourceLoader.exists("res://docs/source.png") and not FileAccess.file_exists("res://docs/source.png")
 if not docs_gone:failed+=1
 print("C22 PACK RESULT ",JSON.stringify({"total":total,"failed":failed,"docs_excluded":docs_gone}))
 get_tree().quit(0 if failed==0 else 1)
