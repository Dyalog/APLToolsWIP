﻿ ref←{DRCref}X509 arg;address;service;timeout
 :If 0=⎕NC'DRCref'
 :OrIf DRCref≡⍬
     DRCref←Init''
 :EndIf

 ref←⎕NEW X509Cert(DRCref,enc arg)
