﻿ r←ClientAuth arg;con;tok;cmd;rc;rr;kp;err;se;sk;st
 :If 1=≡arg
     arg←,⊂arg
 :EndIf
 con←1⊃arg
 err←SetProp con'IWA'('NTLM' '',1↓arg)
 :Repeat
     kp tok←2⊃GetProp con'Token'
     rc cmd←Send con(err kp tok)
     rr←Wait cmd 10000
     :If 0=⊃rr
         (se sk st)←3↑4⊃rr

         :If 0<⍴st
         :AndIf se=0
             err←SetProp con'Token'(st)
         :Else
             kp←0
         :EndIf
     :EndIf
 :Until (0=kp)∨(sk=0)
 r←GetProp con'IWA'
