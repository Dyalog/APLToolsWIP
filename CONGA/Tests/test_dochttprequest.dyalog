 r←test_dochttprequest dummy;srv;z;ret
⍝∇Test: group=Classy
⍝ Test Class-based servers

 r←''

 :Trap 0
    srv←Conga.Srv 8088 #.HttpServers.DocHttpRequest
    srv.Start
 :Else
    →fail because'Unable to start server: ',⊃⎕DMX.DM
 :EndTrap

 :If 0≠⊃ret←#.Samples.HTTPGet 'http://localhost:8088/index.html'
     →fail⊣r←'HTTPGet failed: ',,⍕ret ⋄ :EndIf
∘∘∘

fail:
:If 9=⎕NC 'srv'
    srv.Stop
:EndIf
