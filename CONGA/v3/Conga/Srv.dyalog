﻿ ref←{DRCref}Srv arg;service;conclass;address;extra
 :If 0=⎕NC'DRCref'
 :OrIf DRCref≡⍬
     DRCref←Init''
 :EndIf
 (service conclass address extra)←(enc arg)defaults 5000 Connection''(⎕NS'')

 :If 9≠⎕NC'conclass'
 :OrIf ~(⊂,Connection)∊{0::⍬ ⋄ ⎕CLASS ⍵}conclass
     ((⍕conclass),' is not a class deriving from Conga.Connection')⎕SIGNAL 11
 :EndIf

 ref←⎕NEW Server(DRCref service conclass address extra)
