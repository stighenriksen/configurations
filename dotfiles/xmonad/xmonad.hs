 import XMonad
 import XMonad.Hooks.SetWMName

 myWorkspaces = ["1:main","2:chat","3","whatever","5:plasma","6","7","8:web"]
 main = xmonad defaultConfig
     { workspaces = myWorkspaces,
       manageHook = myManageHook <+> manageHook defaultConfig,
       startupHook = setWMName "LG3D",
       modMask = mod4Mask -- use the Windows button as mod
     } 

 myManageHook = composeAll
     [ className =? "Plasma" --> doShift "5:plasma" ]

--import XMonad
--import XMonad.Config.Kde
--import qualified XMonad.StackSet as W -- to shift and float windows
-- 
--main = xmonad kdeConfig
--    { modMask = mod4Mask -- use the Windows button as mod
--    , manageHook = manageHook kdeConfig <+> myManageHook
--    }
-- 
--myManageHook = composeAll . concat $
--    [ [ className   =? c --> doFloat           | c <- myFloats]
--    , [ title       =? t --> doFloat           | t <- myOtherFloats]
--    , [ className   =? c --> doF (W.shift "2") | c <- webApps]
--    , [ className   =? c --> doF (W.shift "3") | c <- ircApps]
--    ]
--  where myFloats      = ["MPlayer", "Gimp"]
--        myOtherFloats = ["alsamixer"]
--        webApps       = ["Firefox-bin", "Opera"] -- open on desktop 2
--        ircApps       = ["Ksirc"]                -- open on desktop 3
