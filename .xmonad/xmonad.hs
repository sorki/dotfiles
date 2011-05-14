import XMonad
import Data.Monoid
import System.Exit
import Data.Ratio ((%))
import XMonad.Config.Gnome
import XMonad.Config.Desktop


import XMonad.Util.EZConfig
import XMonad.Util.Run
import qualified XMonad.Prompt as P
import XMonad.Prompt.Shell
import XMonad.Prompt

import XMonad.Actions.CycleWS
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.WindowGo
import qualified XMonad.Actions.Search as S
import XMonad.Actions.Search
import qualified XMonad.Actions.Submap as SM
import XMonad.Actions.GridSelect
import XMonad.Actions.NoBorders

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers

import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect
import XMonad.Layout.IM
import XMonad.Layout.Tabbed
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints



import qualified XMonad.StackSet as W
import qualified Data.Map        as M



-- > xprop | grep WM_CLASS
myManageHook = composeAll
    [ manageHook gnomeConfig
    , className =? "MPlayer"           --> doFloat
    , className =? "Gimp"              --> doFloat
    , className =? "Pidgin"            --> doShift "im"
    , className =? "Skype0"            --> doShift "im"
    , className =? "Sonata"            --> doShift "music"
    , className =? "Thunderbird"       --> doShift "mail"
    , className =? "Chromium-browser"  --> doShift "web"
    , resource  =? "desktop_window"    --> doIgnore
    , resource  =? "kdesktop"          --> doIgnore
    , title     =? "irssi"             --> doShift "irssi"

    , isFullscreen                     --> (doF W.focusDown <+> doFullFloat) 
    ] <+> manageDocks

dzenFg = "#222222"
dzenBg = "#edecec"
dzenFont = "Sans:bold:size=9"
dzenWidth = 16
dzenCommon = "-h "++(show dzenWidth)++" -bg '"++dzenBg++"' -fg '"++dzenFg++"' -fn '"++dzenFont++"'"

m1Width = 1280
m1Height = 800

lbarOffset = 28
statusRatio = (5%6)
bottomRatio = (1%2)

ltopBarWidth = floor $ fromRational $ statusRatio * (fromInteger (m1Width - lbarOffset))
rtopBarWidth = ceiling $ fromRational $ (1 - statusRatio) * (fromInteger  (m1Width - lbarOffset))

lbotBarWidth = floor $ fromRational $ bottomRatio * (fromInteger (m1Width - lbarOffset))
rbotBarWidth = ceiling $ fromRational $ (1 - bottomRatio) * (fromInteger  (m1Width - lbarOffset))

ltopBar = "dzen2 -x "++ (show lbarOffset) ++" -w "++ (show ltopBarWidth) ++" -ta l -sa l " ++ dzenCommon
rtopBar  = "conky -c ~/.xmonad/conkytop | dzen2 -x "++ (show $ ltopBarWidth + lbarOffset) ++" -w "++ (show rtopBarWidth) ++" -ta r -sa l " ++ dzenCommon
lbotBar  = "conky -c ~/.xmonad/conkylbot | dzen2 -y "++(show $ m1Height - dzenWidth) ++" -x "++ (show lbarOffset) ++" -w "++ (show lbotBarWidth)++" -ta l -sa l " ++ dzenCommon
rbotBar  = "conky -c ~/.xmonad/conkyrbot | dzen2 -y "++(show $ m1Height - dzenWidth)++" -x "++ (show $ lbotBarWidth + lbarOffset) ++" -w "++ (show rbotBarWidth) ++" -ta r -sa l " ++ dzenCommon

main = do 
    statusBar <- spawnPipe ltopBar
    rtBar <- spawnPipe rtopBar
--    lbBar <- spawnPipe lbotBar
--    rbBar <- spawnPipe rbotBar
    xmonad $ withUrgencyHook NoUrgencyHook
           $ gnomeConfig {
        terminal           = "urxvt",
        modMask            = mod1Mask,
        focusFollowsMouse  = True,
        numlockMask        = mod2Mask,
        workspaces         = ["irssi", "web","con","im","dev","music","mail","latex","8","9", "0"],
        normalBorderColor  = "#000000",
        focusedBorderColor = "#00dd00",
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

        layoutHook         = avoidStruts $ smartBorders $ myLayout,
        manageHook         = myManageHook,
--        handleEventHook    = myEventHook,
--      startupHook        = myStartupHook >> gnomeRegister >> startupHook desktopConfig,
        logHook            = myLogHook statusBar

    }

myLayout = onWorkspace "web" (noBorders Full ||| tall ) $ onWorkspace "im" imLayout $ onWorkspace "0" Grid $ std
    where
      std = (tall ||| Mirror tall ||| noBorders Full)
      tall = Tall 1 (3/100) (1/2) 
      imtall = Tall 2 (3/100) (1/2)

      imLayout = reflectHoriz $ withIM pidginRatio pidginRoster $ reflectHoriz $ withIM skypeRatio skypeRoster (imtall ||| Mirror imtall ||| Grid)
      pidginRatio  = (1%7)
      pidginRoster = And (ClassName "Pidgin") (Role "buddy_list")
      skypeRatio= (1%7)
      skypeRoster  = And (ClassName "Skype0") (Role "MainWindow")

-- X prompt
myXPConfig = defaultXPConfig                                    
    {
        font  = "-*-terminus-*-*-*-*-12-*-*-*-*-*-*-u"
        ,fgColor = "#00dd00"
        , bgColor = "#000000"
        , borderColor = "#00dd00"
        , bgHLight    = "#000000"
        , fgHLight    = "#ff0000"
        , position = Bottom
    }

searchEngineMap method = M.fromList $
       [ ((0, xK_g), method S.google )
       , ((0, xK_y), method S.youtube )
       , ((0, xK_m), method S.maps )
       , ((0, xK_d), method S.dictionary )
       , ((0, xK_w), method S.wikipedia )
       , ((0, xK_i), method S.imdb )
       ]       

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_c     ), kill)
    , ((modm,               xK_space ), sendMessage NextLayout)
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modm,               xK_n     ), refresh)
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((modm .|. shiftMask, xK_Tab   ), cycleRecentWS [xK_Alt_L] xK_Tab xK_grave)
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_k     ), windows W.focusUp  )
    , ((modm,               xK_m     ), windows W.focusMaster  )
    , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modm,               xK_h     ), sendMessage Shrink)
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    , ((modm,               xK_a     ), focusUrgent)
    , ((modm,               xK_comma ), sendMessage (IncMasterN 1))
    , ((modm,               xK_period), sendMessage (IncMasterN (-1)))
    , ((modm,               xK_b     ), sendMessage ToggleStruts)
    , ((modm,               xK_g     ), withFocused toggleBorder)
--    , ((modm,               xK_s     ), SM.submap $ searchEngineMap $ S.promptSearchBrowser myXPConfig "chromium-browser")
    , ((modm,               xK_d     ), shellPrompt myXPConfig)
    , ((modm,               xK_s     ), spawn "~/bin/dim")
    , ((modm .|. shiftMask, xK_s     ), spawn "killall dim")
    , ((modm,               xK_r     ), spawn "killall conky; killall dzen2; xmonad --recompile; xmonad --restart")
    ]
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_grave] ++ [xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_q] [0..] -- w, q for xinerama
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    , ((modm, button4), (\w ->focus w >>  sendMessage Shrink))
    , ((modm, button5), (\w ->focus w >>  sendMessage Expand))
    ]

myLogHook h = dynamicLogWithPP $ defaultPP
      {   ppCurrent  = dzenColor "black" "" . pad
        , ppVisible  = dzenColor "purple" "" . pad
        , ppHidden   = dzenColor "#777777" "" . pad
        , ppHiddenNoWindows = dzenColor "white"  "" . pad
        , ppUrgent   = dzenColor "#dd0000" "" . dzenStrip
        , ppWsSep    = ""
        , ppSep      = " | "
        , ppTitle    = (" " ++) . dzenColor "" "" . dzenEscape
        , ppOutput   = hPutStrLn h
      }

--myStartupHook = 
--    spawn "urxvt -title irssi -e ~/bin/irssi_single"

