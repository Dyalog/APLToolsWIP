 r←verify_empty iConga;tree;one
⍝ Verify that root is empty

 :If 0≠⍴tree←2 2⊃tree←iConga.Tree'.'
     one←1=≢tree
     r←(⍕≢tree),' object',((~one)/'s'),' exist',(one/'s'),' under root: ',,⍕(⊂1 1)⊃¨tree
 :Else ⋄ r←''
 :EndIf
