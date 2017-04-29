 r←setup_ftpclient_test_basic dummy;home
⍝ Setup test 
 ⎕io←⎕ml←r←1
 :If 0=#.⎕NC'DRC' ⋄ 'DRC'#.⎕CY'conga' ⋄ :EndIf  ⍝ make sure conga is there...
 ⍝home←1⊃⎕NPARTS⊃(5177⌶⍬){∪((⊂⍵)≡¨1⊃¨⍺)/4⊃¨⍺}1⊃⎕si   ⍝ find source-file of current fn ()
 home←'H:\GitHub\APLToolsWIP\FTPClient\Tests\'  ⍝ this needs to be improved and generalized once environment does work....
 'Fixed ',#.⎕fix 'file://',home,'..\FTPClient.dyalog'
 ⎕←'setup done'
