﻿ r←IWAAuth con;tok;cmd;rc;rr;kp
 err HANDLE←IWAStart 1 'NTLM' ''
 :Repeat
     err kp len tok←IWAGet HANDLE 1 200 200
     tok←len↑tok
     rc cmd←Send con tok
     rr←Wait cmd 10000
     tok←4⊃rr
     IWASet HANDLE(⍴tok)tok
 :Until 0=kp
 r←IWAName HANDLE 100
     ⍝ r←GetProp con'IWA'
