:Namespace KEYPRESS
⍝ Private User Command

    ⎕IO←1 ⋄ ⎕ML←1
    NOTWIN←'Windows'≢7↑1⊃'.'⎕WG'aplversion'

    ∇ r←List
      r←⎕NS¨1⍴⊂⍬
   ⍝ Name, group, short description and parsing rules
      r.Name←,¨⊂'KEYPRESS'
      r.Group←⊂'MSWIN'
      r[1].Desc←'Display message arguments of KeyPress event.',NOTWIN/' *** Not useable on your platform!'
      r.Parse←⊂''
    ∇

    ∇ r←Run(Cmd Input)
      :Select Cmd
      :Case 'KEYPRESS'
          :If NOTWIN
              r←'This command is not useable on non-Windows platforms.'
          :Else
              r←↑RunKeyPress
              r←'' ⍝ I think showing the results directly in the session (as I do also)
     ⍝ is more useful than printing them afterwards, so I decided to discard the result.
     ⍝ Opinions??? ;-)
          :EndIf
      :EndSelect
    ∇

    ∇ r←level Help Cmd;⎕ML
      ⎕ML←1
      :Select Cmd
      :Case 'KEYPRESS'
          r←⊂'This command can be used to display the event message reported by the KeyPress-event.'
          r,←⊂'After launching it displays a form and waits for the KeyPress-Event being triggered.'
          r,←⊂'Whenever the event is triggered, it displays the arguments on the form as well as in the session.'
          r,←⊂'More information about the KeyPress-Event: http://help.dyalog.com/16.0/Content/GUI/MethodOrEvents/KeyPress.htm'
          r,←NOTWIN/'' '*** This command is not useable on non-Windows platforms. ***'
      :EndSelect
     
    ∇


    ∇ R←RunKeyPress;C;E;H;HP;HZ;MSG;P;Q;VP;VZ;W;X;Z;⎕IO;⎕ML;classic
⍝ Trace and decypher KeyPress events
⍝ Replaces ∇CODES from Dyadic's UTIL workspace (APL/W version 7.0)
⍝ Requires: -
⍝ 03 Apr 1995  Rex Swain, Independent Consultant, Tel (+1) 203-868-0131
⍝ 15 Aug 1995  Simplify and improve handling of System and APL fonts
⍝ 17 Feb 2017  MBaas: ]keypress, added control-structures, added session-output (I like "persistent results")
      ⎕IO←1
      ⎕ML←3
      R←⊂'Keys pressed:'
      classic←82=⎕DR'' ⍝ Classic Version?
     
⍝ ----- Create form ---------------------------------------------------
     
      Q←('Coord' 'Pixel')('Event'('KeyPress' 'Close')1)
      Q,←('MinButton' 0)('MaxButton' 0)('Sizeable' 0)
      'MSG'⎕WC'Form' 'KeyPress Event',Q  ⍝⍎ MSG←
     
⍝ ----- Query System and APL fonts ------------------------------------
     
      'MSG.SYS'⎕WC'Font' 'MS Sans Serif' 13 ⍝ Create copy of font as object
     
      Q←'⎕SE'⎕WG'Font'                   ⍝ Want session/APL font for Labels
      'MSG.APL'⎕WC(⊂'Font'),Q            ⍝ Create copy of font as object
     
      Z←'MSG'⎕WG⊂'TextSize' 'Z' 'MSG.SYS'  ⍝ Size of one char in System font
      C←'MSG'⎕WG⊂'TextSize' '⎕' 'MSG.APL'  ⍝ Size of one char in APL font
     
      H←C[1]⌈Z[1]                        ⍝ Larger height (×1.5 for border)
      W←C[2]                             ⍝ Width of one APL character
      VP←H×¯1.5+2×⍳8                     ⍝ Vertical positions
     
⍝ ----- Resize form ---------------------------------------------------
     
      C←1⊃'.'⎕WG'DevCaps'                ⍝ Screen size in pixels
      Z←(8⊃VP)(2⊃C)                      ⍝ For now, unnecessarily wide
      'MSG'⎕WS('Font' 'MSG.SYS')('Size'Z)
     
⍝ ----- Create column 1: left-hand labels -----------------------------
     
      HP←W                               ⍝ Horizontal position
      VZ←H×1.5                           ⍝ Vertical size
      HZ←⍬                               ⍝ Horizontal size
     
      Q←'Size'VZ HZ
      'MSG.L1'⎕WC'Label' '[1] Object Name:'('Posn'(1⊃VP)HP)Q
      'MSG.L2'⎕WC'Label' '[2] Event Code:'('Posn'(2⊃VP)HP)Q
      'MSG.L3'⎕WC'Label' '[3] Input Code:'('Posn'(3⊃VP)HP)Q
      'MSG.L4'⎕WC'Label' '[4] ASCII Code:'('Posn'(4⊃VP)HP)Q
      'MSG.L5'⎕WC'Label' '[5] Key Number:'('Posn'(5⊃VP)HP)Q
      'MSG.L6'⎕WC'Label' '[6] Shift State:'('Posn'(6⊃VP)HP)Q
     
      X←'Label'⎕WN'MSG'                  ⍝ Names of all child labels
      X←2⊃¨¨X ⎕WG¨⊂'Posn' 'Size'         ⍝ Horizontal posn and size of each
      X←⌈/+/¨X                           ⍝ Largest Posn+Size
     
⍝ ----- Create column 2: APL "edit" boxes -----------------------------
     
      HP←X                               ⍝ Horiz positions (column 2)
      Q←'"MSG"' '"KeyPress"' '"F12"' '000' '000' '0' 'FF' 'Ctrl+Shift+Enter'
      HZ←W×2+(↑∘⍴∘,)¨Q
      Q←('Font' 'MSG.APL')('Border' 1)('BCol' 127 255 255)  ⍝ ('BCol' ¯6)
      'MSG.K1'⎕WC'Label'('Posn'(1⊃VP)HP)('Size'VZ(1⊃HZ)),Q
      'MSG.K2'⎕WC'Label'('Posn'(2⊃VP)HP)('Size'VZ(2⊃HZ)),Q
      'MSG.K3'⎕WC'Label'('Posn'(3⊃VP)HP)('Size'VZ(3⊃HZ)),Q
      'MSG.K4'⎕WC'Label'('Posn'(4⊃VP)HP)('Size'VZ(4⊃HZ)),Q
      'MSG.K5'⎕WC'Label'('Posn'(5⊃VP)HP)('Size'VZ(5⊃HZ)),Q
      'MSG.K6'⎕WC'Label'('Posn'(6⊃VP)HP)('Size'VZ(6⊃HZ)),Q
     
⍝ ----- Explain input code --------------------------------------------
     
      E←('Caption' '≡')('Font' 'MSG.APL')('Size'VZ(W×1.5))
      Q,←⊂'BCol' ¯6
      P←(3⊃VP),HP+(3⊃HZ)+W×0.5
      'MSG.Y1'⎕WC'Label'('Posn'P),E
      Z←'MSG.Y1'⎕WG'Size'
      P[2]+←Z[2]
      'MSG.K8'⎕WC'Label'('Posn'P)('Size'VZ(8⊃HZ)),Q
     
⍝ ----- Create more ASCII stuff ---------------------------------------
     
      P←(4⊃VP),HP+(4⊃HZ)+W×0.5
      X←'Size'VZ ⍬
      'MSG.D1'⎕WC'Label' 'decimal'('Posn'P)X
      Z←'MSG.D1'⎕WG'Size'
      P[2]+←Z[2]
      'MSG.D3'⎕WC'Label'('Posn'P),E
      Z←'MSG.D3'⎕WG'Size'
      P[2]+←Z[2]
      'MSG.K7'⎕WC'Label'('Posn'P)('Size'VZ(7⊃HZ)),Q
      P[2]+←(7⊃HZ)+W×0.5
      'MSG.D2'⎕WC'Label' 'hex'('Posn'P)X
     
⍝ ----- Create shift state buttons ------------------------------------
     
      P←(6⊃VP),HP+(6⊃HZ)+W×1.5
      'MSG.B0'⎕WC'Label'('Posn'P),E
      Z←'MSG.B0'⎕WG'Size'
      P[2]+←Z[2]+W×1.25
      Q←('Style' 'Check')X('Event' 'Select' 1)
      'MSG.B1'⎕WC'Button' 'Shift'('Posn'P),Q
      Z←'MSG.B1'⎕WG'Size'
      P[2]+←Z[2]+W×1.5
      'MSG.B2'⎕WC'Button' 'Ctrl'('Posn'P),Q
      Z←'MSG.B2'⎕WG'Size'
      P[2]+←Z[2]+W×1.5
      'MSG.B3'⎕WC'Button' 'Alt'('Posn'P),Q
     
⍝ ----- Resize width of form ------------------------------------------
     
      X←(⎕WN'MSG')~'MSG.APL' 'MSG.SYS'  ⍝ Names of all children except fonts
      X←2⊃¨¨X ⎕WG¨⊂'Posn' 'Size'    ⍝ Horizontal posn and size of each
      X←W+⌈/+/¨X                    ⍝ Largest Posn+Size, plus right-hand pad
      P←⌈0.30000000000000004 0.9×C-(8⊃VP),X
      'MSG'⎕WS('Size'⍬ X)('Posn'P)  ⍝ Fix overall width and position
     
⍝ ----- Create right-justified Close button ---------------------------
     
      'MSG.BC'⎕WC'Button' 'Close'   ⍝ Create prototype button
      Z←(2×W)+2⊃'MSG.BC'⎕WG'Size'   ⍝ How wide is it, add padding
      P←(7⊃VP)(X-Z+W)               ⍝ Position to right-justify
      'MSG.BC'⎕WC'Button' 'Close'('Posn'P)('Size'VZ Z)('Event' 'Select' 1)
     
      Q←'Must click Close button to exit...'
      'MSG.LC'⎕WC'Label'Q('Posn'(7⊃VP)W)('Size'VZ ⍬)('FCol' 0 0 255)
      Q←'MSG.LC'⎕WG'Size'
      'MSG.LC'⎕WS'Posn'⍬(P[2]-Q[2])
     
⍝ ----- Place mouse on Close button -----------------------------------
     
      ⎕NQ'MSG.BC' 'MouseMove',(VZ Z×0.6000000000000001 0.85),1 0
     
⍝ ----- Trace keystrokes until Close ----------------------------------
     
      H←⎕D,6⍴⎕A                         ⍝ Hex digits
      Z←⌽'MSG.B1' 'MSG.B2' 'MSG.B3'     ⍝ Shift state buttons
      :Repeat ⍝ Wait for an event
          X←⎕DQ'MSG'                        ⍝ Wait for event
          :Select 1
          :Case X[1]∊Z                      ⍝ Shift state buttons?
     ⍝ --> Don't let buttons get focus
              (1⊃X)⎕WS'State' 0
              ⎕NQ'MSG' 'GotFocus'
          :Case ~X[2]∊'Select' 'Close'        ⍝ Close (button or SysMenu)?
              'MSG.K1'⎕WS'Caption'(' ''',(1⊃X),'''')
              'MSG.K2'⎕WS'Caption'(' ''',(2⊃X),'''')
              Q←3⊃X ⋄ r←', Input Code: ',(3↑⍕Q),classic/,' Key label: ',⎕KL Q
              'MSG.K3'⎕WS'Caption'(' ''',((1+Q='''')/Q),'''')
              'MSG.K8'⎕WS'Caption'(' ',⎕KL Q)
              Q←4⊃X ⋄ r←', Key Number: ',(5 0⍕5⊃X),', ASCII: ',(4 0⍕Q),r
              'MSG.K4'⎕WS'Caption'(4 0⍕Q)
              'MSG.K7'⎕WS'Caption'(' ',H[1+16 16⊤Q])
              'MSG.K5'⎕WS'Caption'(4 0⍕5⊃X)
              Q←6⊃X ⋄ r←('Shift state: ',1 0⍕2 2 2⊤Q),' ',r
              'MSG.K6'⎕WS'Caption'(' ',⍕Q)
              Z ⎕WS¨(⊂⊂'State'),¨2 2 2⊤Q
              R←R,⊂⎕←r  ⍝ append report on this keystroke to result
          :EndSelect
      :Until X[2]∊'Select' 'Close'
    ∇
:EndNamespace
