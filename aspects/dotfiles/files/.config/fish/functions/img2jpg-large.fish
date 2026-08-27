function img2jpg-large --description 'Transcode any image to large JPG (max 3160px)'
  set -l img $argv[1]
  set -l rest $argv[2..]
  set -l base (string replace -r '\.[^.]*$' '' -- $img)
  magick "$img" $rest -resize "3160x>" -quality 85 -strip "$base-large.jpg"
end
