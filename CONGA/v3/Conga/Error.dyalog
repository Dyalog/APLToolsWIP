﻿ r←Error no;i
      ⍝ Return error text

 :If (1↑⍴ErrorTable)≥i←ErrorTable[;1]⍳no
     r←ErrorTable[i;]
 :ElseIf (no<1000)∨no>10000
     r←no('OS Error #',⍕no)'Consult TCP documentation'
 :Else
     r←no'? Unknown Error' ''
 :EndIf
