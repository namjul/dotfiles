
function fdo --description "Fuzzy find & open"

  set ext_exceptions pdf

  # list of extensions that should be opened with preferred application
  # image extensions from https://github.com/arthurvr/image-extensions/blob/master/image-extensions.json
  set image_extensions ase art bmp blp cd5 cit cpt cr2 cut dds dib djvu egt exif gif gpl grf icns ico iff jng jpeg jpg jfif jp2 jps lbm max miff mng msp nef nitf ota pbm pc1 pc2 pc3 pcf pcx pdn pgm PI1 PI2 PI3 pict pct pnm pns ppm psb psd pdd psp px pxm pxr qfx raw rle sct sgi rgb int bw tga tiff tif vtf xbm xcf xpm 3dv amf ai awg cgm cdr cmx dxf e2d egt eps fs gbr odg svg stl vrml x3d sxd v2d vnd wmf emf art xar png webp jxr hdp wdp cur ecw iff lbm liff nrrd pam pcx pgf sgi rgb rgba bw int inta sid ras sun tga heic heif

  # append
  set -a ext_exceptions $image_extensions

  fzf | read -l result

  if [ -n "$result" ]
    set ext (string split -r -m1 '.' $result)

    if not contains $ext[2] $ext_exceptions
      command $EDITOR $result
    else
      open $result
    end
  end

  commandline -f repaint
end
