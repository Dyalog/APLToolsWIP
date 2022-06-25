 r←setup_ftpclient_test_basic dummy;home
⍝ Setup test
 ⎕IO←⎕ML←1 ⋄ r←''
 :If 0=#.⎕NC'DRC' ⋄ #.⎕CY'conga' ⋄ ⎕←'Copied Conga' ⋄ :EndIf  ⍝ make sure conga is there...
 ⍝home←1⊃⎕NPARTS⊃(5177⌶⍬){∪((⊂⍵)≡¨1⊃¨⍺)/4⊃¨⍺}1⊃⎕si   ⍝ find source-file of current fn ()
 ⍝home←##.TESTSOURCE  ⍝ hopefully good enough...
 ⍝ 'Fixed ',#.⎕FIX'file://',home,'..\..\Conga\Library\FTPClient.dyalog'
 ⎕←'Fixed ',#.⎕FIX'file://',(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'\Library\Conga\FTPClient.dyalog'
 ⎕←'setup done'
