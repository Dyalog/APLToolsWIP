﻿ ref←{DRCref}Clt arg;address;service;timeout
 :If 0=⎕NC'DRCref'
 :OrIf DRCref≡⍬
     DRCref←Init''
 :EndIf

 (address service timeout)←(enc arg)defaults'localhost' 5000 10000
 ref←⎕NEW Client(DRCref address service timeout)
