﻿ r←InitRawIWA dllname
 ⍙naedfns,←⊂'IWAStart'⎕NA dllname,'IFAuthClientStart >P <0T1 <0T1'
 ⍙naedfns,←⊂'IWAGet'⎕NA dllname,'IFAuthGetToken P >U4 =U4 >C1[]'
 ⍙naedfns,←⊂'IWASet'⎕NA dllname,'IFAuthSetToken P U4  <C1[]'
 ⍙naedfns,←⊂'IWAFree'⎕NA dllname,'IFAuthFree P '
 ⍙naedfns,←⊂'IWAName'⎕NA dllname,'IFAuthName P >0T1'
 r←0
