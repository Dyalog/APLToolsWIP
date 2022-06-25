 TestTests;ctrls;tests;look4;dir;CRLF;rep;ih;txt;h;eol;base;file;d;sub;z2;lc;dirC;dirE;dirT;examples;zt;ze;z1t;z1e;c;split;repE;c1;src;e;fld;f;pf;LF;noc1;fwslash;docn;j;uses;z;z∆;ex∆;ex∆∆

 CRLF←⎕UCS 13 10
 LF←⎕UCS 10
 lc←{0(819⌶)⍵}  ⍝ lowercase for case-introlerant comparisons
 split←{⎕ML←1 ⋄ ⍺←' ' ⋄ w←((⍺≢(≢⍺)↑⍵)/⍺),⍵ ⋄ (≢⍺)↓¨(⍺⍷w)⊂w}  ⍝ this split does not only split @ invidivdual chars, but also @ strings (ie CRLF)
 noc1←{⍺⍺(819⌶)⍵}  ⍝ operator for caseless comparisons...
 fwslash←{'\'@('/'=⊢)⍵}
 :If 0=⎕NC'#.Boot.AppRoot'
     dir←'/git/MiServer/'
 :Else
     :If 2=⎕NC'#.Boot.MSRoot' ⋄ dir←#.Boot.MSRoot ⋄ :EndIf
     :If 2=⎕NC'#.Boot.WC2Root' ⋄ dir←#.Boot.WC2Root ⋄ :EndIf
 :EndIf
 :If ~⎕NEXISTS dirC←dir,'html/' ⋄ ('Folder not found: ',dirC)⎕SIGNAL 11 ⋄ :EndIf
 :If ~⎕NEXISTS dirE←dir,'MS3/Examples/' ⋄ ('Folder not found: ',dirE)⎕SIGNAL 11 ⋄ :EndIf
 :If ~⎕NEXISTS dirT←dir,'MS3/QA/Examples/' ⋄ ('Folder not found: ',dirT)⎕SIGNAL 11 ⋄ :EndIf

 rep←'<h1>Testing coverage of QA-tests in ',(fwslash dirT),'</h1>',CRLF

 ctrls←↑(⊂dirC){r←(2⊃⎕NPARTS ⍵)((≢1⊃⎕NPARTS ⍺)↓⍵) ⋄ r[2]←⊂¯1↓1⊃⎕NPARTS 2⊃r ⋄ (0<≢2⊃r)/¨r}¨⊃0(⎕NINFO⍠('Recurse' 1)('Wildcard' 1))dirC,'*.dyalog'  ⍝ [;1] filename, [;2] Folder
 ctrls←(0<≢¨ctrls[;1])⌿ctrls
 look4←ctrls[;1]∘.,'' 'Simple' 'Advanced'

 tests←{2⊃⎕NPARTS ⍵}¨⊃0(⎕NINFO⍠('Recurse' 1)('Wildcard' 1))dirT,'*.dyalog'
 examples←{2⊃⎕NPARTS ⍵}¨e←⊃0(⎕NINFO⍠('Recurse' 1)('Wildcard' 1))dirE,'*.mipage'
 ex∆∆←(≢e)⍴⊂''
 :For f :In e
     cnt←1⊃⎕NGET f
     ex∆∆[e⍳⊂f]←⊂' '#.Strings.split #.Strings.deb⊃('⍝\sControl::\s*((\s*[^\s]*)*)'⎕S'\1')cnt
 :EndFor

 zt←(0(819⌶)look4)∊0(819⌶)tests
 ze←(0(819⌶)look4)∊0(819⌶)examples

 z1e←~∨/ze
 rep,←CRLF,' <h2>',(⍕+/z1e),' controls without matching Simple/Advanced-pages in examples-folders ',(fwslash dirE),'</h2>',CRLF
 rep,←'<i>If controls are used in other samples, their names will be shown nextz to the relevant control)</i>',CRLF
 :For sub :In ∪z1e/ctrls[;2]
     z2←z1e∧ctrls[;2]≡¨⊂sub
     rep,←'  <h3>',sub,'/</h3>',CRLF,'   <ol>',CRLF
     :For j :In ⍸z2
         rep,←∊'    <li>',(j⊃ctrls[;1])
         :If ∨/z∆←(⊂⊂sub,'.',1⊃ctrls[j;])∊¨ex∆∆
             rep,←' (',(¯2↓∊examples[⍸z∆],¨⊂', '),')'
         :EndIf
         rep,←'</li>',CRLF
     :EndFor
     rep,←'   </ol>',CRLF
 :EndFor

 z1t←(∨/z1e)∧~∨/zt
 rep,←' <h2>',(⍕+/z1t),' controls that have examples, but no pages in test-folders ',(fwslash dirT),'</h2>',CRLF
 :For sub :In ∪z1t/ctrls[;2]
     z2←z1t∧ctrls[;2]≡¨⊂sub
     rep,←'  <h3>',sub,'/</h3>',CRLF,'   <ol>',CRLF
     rep,←∊{'    <li>',⍵,'</li>',CRLF}¨z2/ctrls[;1]
     rep,←'   </ol>',CRLF
 :EndFor


 rep,←CRLF,' <h2>Testing examples...</h2>',CRLF
 :For e :In ⊃0(⎕NINFO⍠('Recurse' 1)('Wildcard' 1))dirE,'*.mipage'
     src←1⊃⎕NGET e   ⍝ source of sample
     c←('^⍝\sControl::(.*)$'⎕S'\1')src      ⍝ check 'Control::'-specifiction
     c←{(0<≢¨⍵)/⍵}{(⍵⍳'.')↓⍵}¨' 'split⊃c  ⍝ remove _Folder and .
     src←('^⍝\sControl::(.*)$'⎕R'')src     ⍝ remove if from source
     repE←''
     uses←{⍵[⍋⍵]}∪('(?:Add|New) #?\.?_\.([^ \(\)\'',]*)'⎕S'\1')src
     uses←uses~#._html.⎕NL-9  ⍝ remove simple HTML-Controls from list of used controls
     :If 0<≢c
     :AndIf ∨/z←~c∊uses
         repE,←∊{'    <li>Claims to test "',⍵,'", but references to this control were not found in the source</li>',CRLF}¨z/c
     :EndIf
     :If ∨/z←~uses∊c
         repE,←∊{'    <li>Uses control "',⍵,'", but does not list it in Controls::-Section</li>',CRLF}¨z/uses
     :EndIf
     :If 0<≢repE
         rep,←'  <h3>File ',(fwslash e),'</h3>',CRLF,'   <ol>',CRLF,repE,'   </ol>',CRLF
     :EndIf
 :EndFor


 rep,←CRLF,' <h2>Testing source of controls',CRLF
 :For c :In ↓ctrls
     e←dirC,(2⊃c),'/',(1⊃c),'.dyalog'
     src←1⊃⎕NGET e 1   ⍝ read it nested
     repE←''
     :For fld :In 'Description::' 'Constructor::'  ⍝ minimum requirements
         :If ~∨/fld⍷src
             repE,←'    <li>has no ',fld,'-Comment in the source</li>',CRLF
         :EndIf
         docn←∊1↓¨src/⍨∧\'⍝'=⊃¨src ⍝ keep all contiguous comments
         src←∊src  ⍝ now enlist it...
         d←('^\s*:field public shared.*$'⎕R'')src  ⍝ remove public shared fields from analysis...(we're keeping readonly-flds...)
         pf←('^\s*\:Field\s*public\s*([^\s←]+)'⎕S'\1'⍠('IC' 1))d
         :If 0<≢pf
             j←⍸⊃⍷/noc1'Public fields::'docn
             d←(j-1)↓docn
             d←(d⍳LF)↓d  ⍝ remove comment introducing "Public Fields"...
             d←(1⍳⍨'::'⍷d)↑d  ⍝ only keep stuff until next segment
             :For f :In pf
                 :If ~∨/f⍷d
                     repE,←'    <li>public field ',f,' is not documented in "Public Fields::"-section<li>',CRLF
                 :EndIf
             :EndFor
         :EndIf
     :EndFor
     :If 0<≢repE
         rep,←'  <h3>File ',(fwslash e),'</h3>',CRLF,'   <ol>',CRLF,repE,'   </ol>',CRLF
     :EndIf
 :EndFor



 txt←rep
 :For h :In 'h1' 'h2'
     :For ih :In ⌽⍸('<',h,'>')⍷txt
         t←{¯5+1⍳⍨('</',h,'>')⍷⍵}(ih-1)↓txt
         eol←⊃⍸(ih<⍳≢txt)∧CRLF⍷txt  ⍝ find EOL following that tag
         txt←((eol+1)↑txt),(t⍴(1+h≡'h2')⊃'=-'),(∊(1+h≡'h1')⍴⊂CRLF),(eol+1)↓txt
     :EndFor
 :EndFor
 txt←('<.*>'⎕R''⍠'Greedy' 0)txt ⍝ make .txt-version by removing all tags
 base←,'<testreport_>,ZI4,ZI2,ZI2,<_>,ZI2,ZI2'⎕FMT 1 5⍴⎕TS
 file←(1⊃⎕NPARTS ¯1↓1⊃⎕NPARTS dirC),base
 txt ⎕NPUT(file,'.txt')1

 ⍝ add footer with info about the files we created
 rep,←CRLF,'<p style="border-top: thin solid black;margin-top:2em;">Reports were written to files ',file,'.html (this file) and <a href="file://',file,'.txt">',file,'.txt</a><br/>',CRLF
 rep,←'<i>The idea is that the .txt-file can (a) easily be pasted elsewhere and (b) be used to delete entries that were "processed", thus serving as a kind of "ToDo-List"</i></p>'
 rep←'<!DOCTYPE html>',CRLF,'<html>',CRLF,' <head>',CRLF,'  <meta charset="UTF-8">',CRLF,' </head>',CRLF,'<body>',CRLF,rep,CRLF,'</body>',CRLF,'</html>'
 rep ⎕NPUT(file,'.html')1
 'H'⎕WC'HTMLRenderer'('HTML'rep)  ⍝ ('URL'('file://',file,'.html'))
 ⎕←'Reports written to ',file,'.html and ',file,'.txt'
