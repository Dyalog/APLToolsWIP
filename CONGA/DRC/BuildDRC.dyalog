 BuildDRC;Path
 Path←{(1-⌊/'/\'⍳⍨⌽⍵)↓⍵}4↓,¯1↑⎕CR⊃⎕SI

 :For module :In 'DRC' 'HTTPUtils' 'Samples'
     ⎕SE.SALT.Load Path,module,'.dyalog'
 :EndFor

 ⎕←'Now please:'            
 ⎕←'      ⎕EX ''BuildDRC'''
 ⎕←'      )WSID ',Path,'..\WSS\DRC.dws'
 ⎕←'      )SAVE'
