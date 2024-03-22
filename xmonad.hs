-- dzen2 plus conky config with urgency for xmonad-0.9*
-- uses icons from dzen.geekmode.org
import XMonad
import XMonad.Core

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Man
import XMonad.Prompt.Ssh

import XMonad.Layout
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops

import XMonad.Actions.UpdatePointer

import XMonad.Actions.DynamicWorkspaces
import qualified XMonad.Actions.DynamicWorkspaceOrder as DWO

import qualified XMonad.StackSet as W
import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow as CopyWindow

import qualified Data.Map as M
import Graphics.X11.Xlib
import XMonad.Util.Run

import Data.Ratio ((%))
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect

import XMonad.Util.Loggers
import qualified XMonad.Util.Hacks as Hacks

main = do
  myStatusBarPipe <- spawnPipe myStatusBar
  xmonad $ myUrgencyHook $ docks $ ewmh $ Hacks.javaHack $ def {
    terminal = myTerminal,
    normalBorderColor = myInactiveBorderColor,
    focusedBorderColor = myActiveBorderColor,
    workspaces = myWorkspaces,
    modMask = myModMask,
    keys = myKeys,
    startupHook = setWMName "LG3D" <+> startupHook def,
    manageHook = myManageHook <+> manageDocks <+> manageHook def,
    handleEventHook = handleEventHook def <> Hacks.windowedFullscreenFixEventHook,
    layoutHook = avoidStruts $ layoutHints $ myLayoutHook,
    logHook = (dynamicLogWithPP $ myDzenPP myStatusBarPipe) -- >> updatePointer (Relative 0.5 0.5)
    }

-- Fonts
myFont = "xft:dejavu sans mono:size=10:weight=bold"
--myFont = "Terminus-12"
mySmallFont = "xft:monospace:size=8"

-- Paths
myBitmapsPath = "/home/jimbo/.common/bitmaps/"

-- Colors - xenburn
myBgBgColor = "black"
myFgColor = "#DCDCDC"
myBgColor = "#3F3F3F"

myHighlightedFgColor = myFgColor
myHighlightedBgColor = "#7F9F7F"

myActiveBorderColor = myCurrentWsBgColor
myInactiveBorderColor = "#262626"

myCurrentWsFgColor = myBgColor
myCurrentWsBgColor = "#CCDC90"
myVisibleWsFgColor = myFgColor
myVisibleWsBgColor = myBgColor
myHiddenWsFgColor = myHighlightedFgColor
myHiddenEmptyWsFgColor = "#8F8F8F"
myUrgentWsFgColor = myBgColor
myUrgentWsBgColor = "#DCA3A3"
myTitleFgColor = myFgColor

myUrgencyHintFgColor = myBgColor
myUrgencyHintBgColor = "#DCA3A3"

-- Bars
myDzenBarGeneralOptions = "-fn '" ++ myFont ++ "' -fg '" ++ myFgColor ++ "' -bg '" ++ myBgColor ++ "'"

myStatusBar = "dzen2 -w 1263 -xs 1 -ta l " ++ myDzenBarGeneralOptions
-- myCPUBar = "conky -c ~/.conky_cpu | sh | dzen2 -x 953 -w 90 -ta l " ++ myDzenBarGeneralOptions
-- myTimeBar = "conky -c ~/.conky_time | dzen2 -x 1108 -w 156 -ta c " ++ myDzenBarGeneralOptions

-- Prefered terminal
-- myTerminal = "urxvt"
myTerminal = "kitty"

-- Rebind Mod to Windows key
myModMask = mod4Mask

-- Prompt config
myXPConfig = def {
  position = Top,
  promptBorderWidth = 0,
  font = myFont,
  height = 15,
  bgColor = myBgColor,
  fgColor = myFgColor,
  fgHLight = myHighlightedFgColor,
  bgHLight = myHighlightedBgColor
  }

-- Union default and new key bindings
myKeys x  = M.union (M.fromList (newKeys x)) (keys def x)

-- Add new and/or redefine key bindings
newKeys conf@(XConfig {XMonad.modMask = modm}) = [
  -- Use shellPrompt instead of default dmenu
  ((modm, xK_p), shellPrompt myXPConfig),
  ((modm .|. shiftMask, xK_p), spawn "xfce4-appfinder"),
  -- ResizableTall key bindings
  ((modm, xK_a), sendMessage MirrorShrink),
  ((modm, xK_z), sendMessage MirrorExpand),
  -- Manual page prompt
  ((modm, xK_o), manPrompt myXPConfig),
  ((modm, xK_s), sshPrompt myXPConfig),
  -- Urgency Hook
  ((modm, xK_u), focusUrgent),
--  ((modm .|. shiftMask, xK_u), clearUrgents),
  -- Make a screeshot
--  ((0,           xK_Print), spawn "scrot -e 'mv $f ~/tmp/'"),
--  ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e 'mv $f ~/tmp/'"), -- interactive
  -- Lock xscreensaver
  ((modm, xK_Escape), spawn "xscreensaver-command -lock"),

  -- Dynamic Workspaces
  ((modm .|. shiftMask, xK_d), removeWorkspace ), -- require shift to remove workspace, just super-D is dangerous
  ((modm, xK_apostrophe), selectWorkspace myXPConfig ),
  ((modm .|. shiftMask, xK_apostrophe), withWorkspace myXPConfig (windows . W.shift)),
  ((modm, xK_c), withWorkspace myXPConfig (windows . CopyWindow.copy)),
  ((modm, xK_r), renameWorkspace myXPConfig )

  -- Delete copy of window, kill (like default) if it's the only copy
  ,((modm .|. shiftMask, xK_c), CopyWindow.kill1)

  ,((modm, xK_0), toggleWS)   -- back to previous displayed workspace
  ,((modm, xK_minus), DWO.moveToGreedy Prev (WSIs $ hiddenNonEmptyNonDottedWS)) -- switch to previous ws
  ,((modm, xK_equal), DWO.moveToGreedy Next (WSIs $ hiddenNonEmptyNonDottedWS)) -- switch to next ws

  ,((modm .|. shiftMask, xK_minus), DWO.swapWith Prev anyWS) -- Move this workspace left
  ,((modm .|. shiftMask, xK_equal), DWO.swapWith Next anyWS) -- Move this workspace right
  ]
 -- mod-[1..9]       %! Switch to workspace N
 -- mod-shift-[1..9] %! Move client to workspace N
  ++
  zip (zip (repeat (modm)) [xK_1..xK_9]) (map (DWO.withNthWorkspace W.greedyView) [0..])
  ++
  zip (zip (repeat (modm .|. shiftMask)) [xK_1..xK_9]) (map (DWO.withNthWorkspace W.shift) [0..])

hiddenNonEmptyNonDottedWS :: X (WindowSpace -> Bool)
hiddenNonEmptyNonDottedWS = do
   vs <- gets ( map (W.tag . W.workspace) . W.visible . windowset) -- list of visible WS
   return (\w -> ( (W.tag w) `elem` vs && (W.tag w !! 0 /= '.') ))

supWsNum wsName wsNum =" " ++ wsName ++  "^p(;_TOP)^fn(" ++ mySmallFont  ++ ")" ++ wsNum ++ "  ^fn()^p()"

-- Workspaces names
myWorkspaces = [
 "local:1",
 "web:2",
 "disc:3",
 "music:4",
 "code:5",
 "audio:6",
 "gnum:7",
 "misc:8",
 "notes:9"
  ]

-- Dzen config
myDzenPP h = def {
  ppOutput = hPutStrLn h,
  ppSort = DWO.getSortByOrder,
  ppSep = "^bg(" ++ myBgBgColor ++ ")^r(1,15)^bg()",
  ppWsSep = "",
  ppCurrent = wrapFgBg myCurrentWsFgColor myCurrentWsBgColor . wrap "[" "]",
  ppVisible = wrapFgBg myVisibleWsFgColor myVisibleWsBgColor . wrap "[" "]",
  ppHidden = wrapFg myHiddenWsFgColor . hideDotWorkspaces,
  ppHiddenNoWindows = wrapFg myHiddenEmptyWsFgColor . hideDotWorkspaces,
  ppUrgent = wrapFgBg myUrgentWsFgColor myUrgentWsBgColor . hideDotWorkspaces,
  ppTitle = (\x -> " " ++ wrapFg myTitleFgColor x),
--  ppExtras = [ padL $ date "%a %b %d %H:%M" ],
  ppLayout  = dzenColor myFgColor"" .
                (\x -> case x of
                    "Hinted ResizableTall" -> wrapBitmap "rob/tall.xbm"
                    "Hinted Mirror ResizableTall" -> wrapBitmap "rob/mtall.xbm"
                    "Hinted Full" -> wrapBitmap "rob/full.xbm"
                    "Hinted Grid" -> wrapBitmap "rob/grid.xbm"
                    "Hinted ReflectX IM Grid" -> wrapBitmap "rob/im.xbm"
                    _  -> x
                )
  }
  where
    hideDotWorkspaces ws = if (ws !! 0) == '.' then "" else ws
    wrapFgBg fgColor bgColor content= wrap (" ^fg(" ++ fgColor ++ ")^bg(" ++ bgColor ++ ")") "^fg()^bg() " content
    wrapFg color content = wrap (" ^fg(" ++ color ++ ")") "^fg() " content
    wrapBg color content = wrap (" ^bg(" ++ color ++ ")") "^bg() " content
    wrapBitmap bitmap = "^p(5)^i(" ++ myBitmapsPath ++ bitmap ++ ")^p(5)"

-- Define a combination of layouts
myLayoutHook = smartBorders $ onWorkspace "3:im" im $ (tiled ||| grid ||| Full)
  where
    grid = Grid
    tiled = ResizableTall nmaster delta ratio []
    nmaster = 1
    delta = 3/100
    ratio = 1/2
    im = reflectHoriz $ (withIM (1%6) (Title "Buddy List") grid)

-- Urgency hint configuration
myUrgencyHook = withUrgencyHook dzenUrgencyHook
    {
      args = [
         "-x", "0", "-y", "1600", "-h", "15", "-w", "1600",
         "-ta", "r", "-expand", "l",
         "-fg", "" ++ myUrgencyHintFgColor ++ "",
         "-bg", "" ++ myUrgencyHintBgColor ++ "",
         "-fn", "" ++ myFont ++ ""
         ],
      duration = (7 * 1000000)
    }

myManageHook = composeAll [
  className =? "Pidgin" --> doF (W.shift "3:im"),
  resource  =? "XXkb" --> doIgnore,
  className =? "stalonetray" --> doIgnore
  ]
