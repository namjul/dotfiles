import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

myAdditionalKeys =
        [ ((mod1Mask .|. controlMask, xK_l), spawn "i3lock -d -c 000000")
        , ((controlMask, xK_Print), spawn "shutter -s")
        , ((0, xK_Print), spawn "scrot")
        , ((mod1Mask, xK_b), sendMessage ToggleStruts)
        , ((mod1Mask, xK_p), spawn  "rofi -matching fuzzy -modi combi -show combi -combi-modi run,drun")
        ]

myConfig p = def 
        { manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ layoutHook defaultConfig
        , terminal = "gnome-terminal"
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn p
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        , ppCurrent = xmobarColor "#fff" "" . wrap "[" "]" 
                        }
        , borderWidth = 1
        , normalBorderColor = "#1d1f21"
        , focusedBorderColor = "#8abeb7"
        } `additionalKeys` myAdditionalKeys

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ myConfig xmproc
