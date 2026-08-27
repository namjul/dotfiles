function n --description 'Open nvim in cwd or on given paths'
  if test (count $argv) -eq 0
    nvim .
  else
    nvim $argv
  end
end
