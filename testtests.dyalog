 {missing}←TestTests;dir;htmlDir;qaBase;comps;tests;subd;zc;zt;lc
 ⍝ this function needs to be executed within the MiServer-Instance
 ⍝ you'd like to test.
 ⍝ It reports components that do not have tests as well as tests
 ⍝ that do not match any components (which is just a theoretical problem).
 ⍝
 ⍝ Feel free to improve the code or to write any missing tests ;-)
 ⍝ https://trello.com/c/TJU0fsOQ/49-qas-for-ms3
 
 lc←{0(819⌶)⍵}  ⍝ lowercase for case-introlerant comparisons
 missing←⍬

 'Need at least V16 to execute!'⎕SIGNAL(16>{2⊃⎕VFI(¯1+⍵⍳'.')↑⍵}2⊃'.'⎕WG'aplversion')/11
 'No QA-Directory found!'⎕SIGNAL(~⎕NEXISTS qaBase←#.Boot.AppRoot,'QA/')/11

 :For dir :In {(1=2⊃⍵)/1⊃⍵}0 1(⎕NINFO⍠1)(htmlDir←#.Boot.MSRoot,'HTML/'),'*'
     subd←2⊃⎕NPARTS dir
     comps←2⊃¨⎕NPARTS¨⊃0(⎕NINFO⍠1)dir,'/*.dyalog'
     :If ⎕NEXISTS qaDir←qaBase,'Examples/',subd
     :OrIf ⎕NEXISTS qaDir←qaBase,'Examples/',subd~'_'
         tests←2⊃¨⎕NPARTS¨⊃0(⎕NINFO⍠1)qaDir,'/*.dyalog'
         tests←{(∧\~⊃∨/('Simple' 'Advanced')⍷¨⊂⍵)/⍵}¨tests
         :If ∨/z←~(lc comps)∊lc tests
             ⎕←'Components without tests in directory ',dir
             ⎕←z/comps
             missing,←(⊂subd,'/'),¨z/comps
         :EndIf
         :If ∨/z←~(lc tests)∊lc comps
             ⎕←'Test in ',qaDir,' without corresponding controls:'
             ⎕←z/tests
         :EndIf


     :Else
         ⎕←'*** Found no matching QA-Directory for ',dir
     :EndIf
 :EndFor
