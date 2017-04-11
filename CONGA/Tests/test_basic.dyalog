 r←test_basic dummy;ret;z;c
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 r←''

 :If 0≠⊃ret←iConga.Srv'S1' '' 5000
     →fail⊣r←'Srv failed: ',,⍕ret ⋄ :EndIf
 :If 0≠⊃ret←iConga.Clt'C1' '127.0.0.1' 5000
     →fail⊣r←'Clt failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Connect')≢(⊂1 3)⌷ret←iConga.Wait'S1' 10000
     →fail⊣r←'Wait for Connect failed: ',,⍕ret ⋄ :EndIf
 :If 0≠⊃ret←iConga.Send'C1'('hello' 'this' 'is' 'a' 'test')
     →fail⊣r←'Sent failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Receive')≢(⊂1 3)⌷c←iConga.Wait'S1' 5000
     →fail⊣r←'Wait for Srv.Receive failed: ',,⍕c ⋄ :EndIf
 :If 0≠⊃ret←iConga.Respond(2⊃c)(⌽4⊃c)
     →fail⊣r←'Respond failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Receive')≢(⊂1 3)⌷ret←iConga.Wait'C1' 5000
     →fail⊣r←'Wait for Clt.Receive failed: ',,⍕c ⋄ :EndIf
 :If (4⊃ret)≢⌽4⊃c
     →fail⊣r←'Data not faithfully returned' ⋄ :EndIf

fail:
 z←iConga.Close¨'S1' 'C1'
