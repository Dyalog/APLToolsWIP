 d2h R;html;hr;b2;r
⍝ Usage: d2h disp {Array}
⍝ disp with HTMLRenderer, shades of grey to differentiate levels of nesting
⍝ WIBNI:
⍝ ○ we could show tooltips on hover with cell-coordinates (and possibly info on datatype)
⍝   - for nested cells possibly with ⊃ coordinates ⌷ or ⊃-coordinates
⍝ ...but I have no idea how to do it. Any volounteers? I fear that the naive approach of just working with disp-result
⍝ may not be suited for that...

 b2←{1=2|+⍀(⍵≡¨'┐')+0⍪¯1↓[1]⍵≡¨'┘'}R
 r←((({(⊂'<span class="nest">'),¨⍵}))@{1=2|+⍀(⍵≡¨'┌')+0⍪¯1↓[1]⍵≡¨'└'})R
 r←((({⍵,¨⊂'</span>'}))@(⍸b2))r
 r←'<pre>',(∊r,⎕UCS 13),'</pre>'
 r←{r←⍵ ⋄ z←128<u←⎕UCS r ⋄ (z/r)←↓'G<&#ZZZ9;>'⎕FMT z/u ⋄ ∊r}r
 html←'<html><style>pre {font-family: APL385 Unicode;}   .nest {background-color:##F4F4F4 ;} .nest>.nest {background-color: #E3E3E3;} .nest>.nest>.nest {background-color: #CCCCCC} .nest>.nest>.nest>.nest {background-color: #B4B4B4} .nest>.nest>.nest>.nest>.nest {background-color: #999999} .nest>.nest>.nest>.nest>.nest {background-color: #7B7B7B; text-color: #FFFFFF;} .nest>.nest>.nest>.nest>.nest>nest {background-color: #505050; text-color: #FFFFFF;}</style>',r,'</html>'
 'foo'⎕WC'htmlrenderer'('html'html)
⍝ html ⎕NPUT'c:\temp\d2h.html' 1
⍝ +2 ⎕NQ'foo' 'ShowDevTools' 1
