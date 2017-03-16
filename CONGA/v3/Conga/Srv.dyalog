 ref←{DRCref}Srv arg;service;conclass;address;extra
 :If 0=⎕NC'DRCref'
 :OrIf DRCref≡⍬
     DRCref←Init''
 :EndIf
 (service conclass address extra)←(enc arg)defaults 5000 Connection''(⎕NS'')
 ref←⎕NEW Server(DRCref service conclass address extra)
