import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat
    , className =? "Vncviewer" --> doFloat
    ]

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ defaultConfig
        { manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ layoutHook defaultConfig
        , terminal = "gnome-terminal"
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        , ppCurrent = xmobarColor "#fff" "" . wrap "[" "]" 
                        }
        } `additionalKeys` myAdditionalKeys

myAdditionalKeys =
        [ ((mod1Mask .|. controlMask, xK_l), spawn "i3lock -d -c 000000")
        , ((controlMask, xK_Print), spawn "shutter -s")
        , ((0, xK_Print), spawn "scrot")
        , ((mod1Mask, xK_b), sendMessage ToggleStruts)
        , ((mod1Mask, xK_p), spawn  "rofi -matching fuzzy -modi combi -show combi -combi-modi run,drun")
        ]
