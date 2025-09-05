
# TODO

- make aplication launcher idempotent actions

# NOTE

## Example using `i3-msg`:

`# Bind Mod+Enter to open or focus Firefox
bindsym $mod+Return exec --no-startup-id bash -c '
  if i3-msg -t get_tree | grep -q "Firefox"; then
    i3-msg "[class=\"Firefox\"] focus"
  else
    firefox
  fi
'`

**Explanation:**

1.  `i3-msg -t get_tree` → gets a JSON tree of all windows.
2.  `grep -q "Firefox"` → checks if a Firefox window exists.
3.  If yes → focus it (`i3-msg "[class=\"Firefox\"] focus"`).
4.  If no → start the app (`firefox`).

* * * * *

### Notes:

-   Replace `"Firefox"` with the **WM_CLASS** of your app. You can check it with:

`xprop | grep WM_CLASS`

Click the window of the app, and it will print something like:

`WM_CLASS(STRING) = "firefox", "Firefox"`

Use the second value (`Firefox`) in your `i3-msg` command.

-   You can turn this into a reusable script if you have many apps.
