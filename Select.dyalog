 R←{prompt}Select list;html;ChosenPath;res;SelectedEntry;i;PlugInsPath

 ⍝ Init - paths will/may need to be adjusted...
 PlugInsPath←'H:\MiServer\PlugIns\'
 ChosenPath←PlugInsPath,'Other\chosen-1.6.2'

 SelectedEntry←1007  ⍝ eventnumber to improve readability

 :If 2=≡list  ⍝ "simple" function call from the user
     :If 0=⎕NC'prompt' ⋄ prompt←'Please make a selection' ⋄ :EndIf

     'F1'⎕WC'HTMLRenderer'('ASChild' 0)('Size' 400 500)('Coord' 'ScaledPixel')

     html←'<html><head><style>',(1⊃⎕NGET ChosenPath,'\chosen.min.css'),'</style>'
     html,←'<script type="text/javascript" >',(1⊃⎕NGET PlugInsPath,'JQuery\jquery-1.12.3.min.js'),'</script>'
     html,←'<script type="text/javascript" >',(1⊃⎕NGET ChosenPath,'\chosen.jquery.min.js'),'</script>'
     html,←'<script>$(function() {$("#select").chosen({width: 200});});'
⍝ would be nice to embed the following (so something similar)
⍝ so that we could have kbd-shortcuts. At least to support "Enter" (=Submit)
⍝ but possibly also something to open the list and maybe alao <Esc>.
⍝     html,←'$(window).keypress(function(event) {'
⍝     html,←'    switch (event.keyCode) {'
⍝     html,←'    case 13:'
⍝     html,←'        $("form").submit();"'
⍝     html,←'        break;'
⍝     html,←'    }'
⍝     html,←'});'
     html,←'<link rel="shortcut icon" type="image/png" href="http://dyalog.com/favicon.ico">'
     html,←'</script>'
     html,←'<title>',prompt,'</title>'  ⍝ HTMLify the title?
     html,←'<meta charset="UTF-8">'
     html,←'</head><body><form method="post" action="#submit">'
     html,←'<div><select name="select" id="select">'
     :For i :In list
         html,←'<option>',i,'</option>'
     :EndFor
     html,←'</select></div>'
     html,←'<input type="submit" value="Ok" style="margin-top: 2em;display: block; margin: 0 auto;">'
     html,←'</form></body></html>'
     F1.HTML←html
     F1.onHTTPRequest←'Select'  ⍝ avoid creating too many fns...
     'F1'⎕WS'Event'SelectedEntry 1
     R←⎕DQ'F1'
     ⎕EX'F1'
     :If 1<⍴R
     :AndIf SelectedEntry=2⊃R ⋄ R←3⊃R
     :Else ⋄ R←''    ⍝ closed form w/o selecting
     :EndIf

 :ElseIf 'HTTPRequest'≡2⊃list         ⍝ handling Callbacks with this fn too, to reduce amount of stuff involved...
⍝     ⎕SE.Dyalog.Utils.display list
     :If ∨/'/#submit'⍷8⊃list  ⍝ submit?
         res←7↓10⊃list ⍝ drop the "select=" (7 chars) from the query-string to extract result
         ⎕←'res=',res
         ⎕NQ'F1'SelectedEntry res
         R←0
         →0
     :ElseIf 'http://dyalog_root'≡18↑8⊃list   ⍝ requests a resource
         list[8]←⊂'file://',ChosenPath,18↓8⊃list
         list[4]←1
         R←list
         →0
     :Else
         ∘∘∘
     :EndIf
     ∘∘∘
 :EndIf

