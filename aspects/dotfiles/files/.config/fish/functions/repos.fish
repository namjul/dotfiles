function repos --description="Git status on all repos in folder"
  find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(cd {} && [ -d .git ] && echo {} && git status -s && echo)' \;
end
