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
    , className =? "Pidgin"            --> doShift "3"
    , className =? "Skype0"            --> doShift "3"
    , className =? "Sonata"            --> doShift "5"
    , className =? "Thunderbird"       --> doShift "6"
    , className =? "google-chrome"     --> doShift "1"
    , resource  =? "desktop_window"    --> doIgnore
    , resource  =? "kdesktop"          --> doIgnore
    , className =? "stalonetray"       --> doIgnore
    , title     =? "irssi"             --> doShift "~"

    , isFullscreen                     --> (doF W.focusDown <+> doFullFloat) 
    ] <+> manageDocks

-- Colors
black = "#000000"
white = "#ffffff"

dzenFg = white
dzenBg = black
dzenFont = "Sans:bold:size=10"
dzenWidth = 24
dzenCommon = "-xs 0 -h "++(show dzenWidth)++" -bg '"++dzenBg++"' -fg '"++dzenFg++"' -fn '"++dzenFont++"'"

ppFg  = "#faaaaa" -- FG
ppBg  = black
ppVFg = "#3a0a0d" -- Visible (xinerama)
ppVBg = black
ppHFg = "#555555" -- Hidden no windows
ppUFg = "#780000" -- Urgent
ppUBg = white
iFg   = white     -- Icon
iBg   = black
ppSFg = "#171717" -- Separator
-- bord  = "#000000" -- Border
-- bordF = "#00dd00" -- Focused Border
bord  = "#000000" -- Border
bordF = "#68100B"

iDir = "/home/rmarko/.xmonad/icons"

myLogHook h = dynamicLogWithPP $ defaultPP
      {   ppCurrent  = dzenColor ppFg ppBg . dzenStrip
        , ppVisible  = dzenColor ppVFg ppVBg . dzenStrip
        , ppHidden          = dzenColor dzenFg dzenBg . dzenStrip
        , ppHiddenNoWindows = dzenColor ppHFg dzenBg . dzenStrip
        , ppUrgent          = dzenColor ppUFg ppUBg . wrap ("^i(" ++ iDir ++ "/info_03.xbm)") "" . dzenStrip
        , ppWsSep    = ""
        , ppSep      = " "
        , ppLayout   = nostr
        , ppTitle    = nostr
        , ppOutput   = hPutStrLn h
      } where nostr x = ""

m1Width = 1366
m1Height = 768

lbarOffset = 0
statusRatio = (1%9)
bottomRatio = (1%2)

rbarOffset = 24*8

ltopBarWidth = floor $ fromRational $ statusRatio * (fromInteger (m1Width - lbarOffset))
rtopBarWidth = ceiling $ fromRational $ (1 - statusRatio) * (fromInteger  (m1Width - lbarOffset))

lbotBarWidth = floor $ fromRational $ bottomRatio * (fromInteger (m1Width - lbarOffset))
rbotBarWidth = ceiling $ fromRational $ (1 - bottomRatio) * (fromInteger  (m1Width - lbarOffset))

ltopBar = "dzen2 -x "++ (show lbarOffset) ++" -w "++ (show ltopBarWidth) ++" -ta l -sa l " ++ dzenCommon
rtopBar  = "~/.xmonad/dzen_top | dzen2 -x "++ (show $ ltopBarWidth + lbarOffset) ++" -w "++ (show $ rtopBarWidth - rbarOffset) ++" -ta l -sa l " ++ dzenCommon

main = do
    statusBar <- spawnPipe ltopBar
    xmonad $ withUrgencyHook NoUrgencyHook
           $ gnomeConfig {
        terminal           = "~/bin/terminal",
        modMask            = mod1Mask,
        focusFollowsMouse  = True,
        workspaces         = ["~", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="],
        normalBorderColor  = bord,
        focusedBorderColor = bordF,
        borderWidth        = 1,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = avoidStruts $ smartBorders $ myLayout,
        manageHook         = myManageHook,
        logHook            = myLogHook statusBar,
        startupHook        = unsafeSpawn ". $HOME/.xinitrc"

    }

myLayout = onWorkspace "1" (noBorders Full ||| tall ) $ onWorkspace "3" imLayout $ std
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
        font  = "-*-terminus-*-*-*-*-18-*-*-*-*-*-*-u"
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
    , ((modm .|. shiftMask, xK_End   ), io (exitWith ExitSuccess))
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
    , ((modm,               xK_d     ), shellPrompt myXPConfig)
    , ((modm,               xK_s     ), spawn "~/bin/dim")
    , ((modm .|. shiftMask, xK_s     ), spawn "killall dim")
    , ((modm,               xK_r     ), spawn "killall conky; killall dzen2; xmonad --recompile; xmonad --restart")
    , ((modm .|. controlMask, xK_l   ), spawn "~/bin/lock")
    ]
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_grave] ++ [xK_1 .. xK_9] ++ [xK_0, xK_minus, xK_equal])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_q, xK_e] [0..] -- w, q for xinerama
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
