:Namespace KeyPress ⍝ V1.01
⍝ 2017 03 02 MBaas: Initial code for KP as UCMD
⍝ 2017 03 09 MBaas: Runs in classic, using 4 digits for hex-codes in non-classic, easy BCol-Fiddling

    BCol_Form←188 188 188      ⍝ background of the form
    BCol_Label←166 166 166     ⍝ labels for the various fields
    BCol_Result←208 208 208    ⍝ interpreted elements of the message
    BCol_RawMsg←127 255 255    ⍝ the event message     
    

    ⎕IO←1 ⋄ ⎕ML←1
    NOTWIN←'Windows'≢7↑1⊃'.'⎕WG'aplversion'
    classic←82=⎕DR'' ⍝ Classic Version?
    ∇ r←List
      :If NOTWIN
          r←⍬
      :Else
          r←⎕NS ⍬
          r.Name←'KeyPress'
          r.Group←'MSWIN'
          r.Desc←'Display message arguments of KeyPress event.'
          r.Parse←''
      :EndIf
    ∇

    ∇ r←level Help Cmd;⎕ML;h
      r←⊂'Display message arguments of KeyPress event.'
      :If 1<level
          h←'After launching it displays a GUI and waits for the KeyPress-Event being triggered. '
          h,←'Whenever the event is triggered (i.e. a key is pressed), it displays the arguments. '
          h,←'If run from the session, this data will also be displayed in the session. '
          h,←'If run under program control, or if the result is captured with ]result←',Cmd,' then all the data is collected and returned as a vector vectors of arguments.'
          r,←h'' 'More information about the KeyPress-Event: http://help.dyalog.com/16.0/Content/GUI/MethodOrEvents/KeyPress.htm'
      :Else
          r,←⊂']??',Cmd,' ⍝ for more info'
      :EndIf
    ∇

    ∇ R←Run(Cmd Input);C;E;H;HP;HZ;MSG;P;Q;VP;VZ;W;X;Z;JR;⎕IO;⎕ML;object;event;input;char;key;shift;kl
⍝ 03 Apr 1995  Rex Swain, Independent Consultant, Tel (+1) 203-868-0131
⍝ 15 Aug 1995  Simplify and improve handling of System and APL fonts
      ⎕IO←1
      ⎕ML←1
      R←⍬
      :If ~##.RIU ⋄ ⎕←'Keys pressed:' ⋄ :EndIf
     
⍝ ----- Create form ---------------------------------------------------
     
      Q←('Coord' 'Pixel')('Event'('KeyPress' 'Close')1)
      Q,←('MinButton' 0)('MaxButton' 0)('Sizeable' 0)
      'MSG'⎕WC'Form' 'KeyPress Event',Q,⊂'BCol'BCol_Form   ⍝⍎ MSG←
     
     
⍝ ----- Query System and APL fonts ------------------------------------
     
      'MSG.SYS'⎕WC'Font' 'MS Sans Serif' 13 ⍝ Create copy of font as object
     
      Q←'⎕SE'⎕WG'Font'                   ⍝ Want session/APL font for Labels
      'MSG.APL'⎕WC(⊂'Font'),Q            ⍝ Create copy of font as object
     
      Z←'MSG'⎕WG⊂'TextSize' 'Z' 'MSG.SYS'  ⍝ Size of one char in System font
      C←'MSG'⎕WG⊂'TextSize' '⎕' 'MSG.APL'  ⍝ Size of one char in APL font
     
      H←C[1]⌈Z[1]                        ⍝ Larger height (×1.5 for border)
      W←C[2]                             ⍝ Width of one APL character
      VP←H×¯1.5+2×⍳7                     ⍝ Vertical positions
     
⍝ ----- Resize form ---------------------------------------------------
     
      C←1⊃'.'⎕WG'DevCaps'                ⍝ Screen size in pixels
      Z←(7⊃VP)(2⊃C)                      ⍝ For now, unnecessarily wide
      'MSG'⎕WS('Font' 'MSG.SYS')('Size'Z)
     
⍝ ----- Create column 1: left-hand labels -----------------------------
     
      HP←W                               ⍝ Horizontal position
      VZ←H×1.5                           ⍝ Vertical size
      HZ←⍬                               ⍝ Horizontal size
     
      Q←('Size'(VZ HZ))('BCol'BCol_Label)
      'MSG.L1'⎕WC'Label' '[1] Object:'('Posn'(1⊃VP)HP),Q
      'MSG.L2'⎕WC'Label' '[2] Event:'('Posn'(2⊃VP)HP),Q
      'MSG.L3'⎕WC'Label' '[3] Input Code:'('Posn'(3⊃VP)HP),Q
      'MSG.L4'⎕WC'Label' '[4] Char Code:'('Posn'(4⊃VP)HP),Q
      'MSG.L5'⎕WC'Label' '[5] Key Number:'('Posn'(5⊃VP)HP),Q
      'MSG.L6'⎕WC'Label' '[6] Shift State:'('Posn'(6⊃VP)HP),Q
     
      X←'Label'⎕WN'MSG'                  ⍝ Names of all child labels
      X←2⊃¨¨X ⎕WG¨⊂'Posn' 'Size'         ⍝ Horizontal posn and size of each
      X←⌈/+/¨X                           ⍝ Largest Posn+Size
     
⍝ ----- Create column 2: APL "edit" boxes -----------------------------
     
      HP←X                               ⍝ Horiz positions (column 2)
      Q←'"KeyPress"' 'Ctrl+Shift+Enter'
      HZ←W×2+(↑∘⍴∘,)¨Q
      Q←('Font' 'MSG.APL')('Border' 0)('BCol'BCol_RawMsg)
      JR←⊂'Justify' 'Right'
      'MSG.K1'⎕WC'Label'('Posn'((1⊃VP)HP))('Size'(VZ,1⊃HZ)),Q
      'MSG.K2'⎕WC'Label'('Posn'((2⊃VP)HP))('Size'(VZ,1⊃HZ)),Q
      'MSG.K3'⎕WC'Label'('Posn'((3⊃VP)HP))('Size'(VZ,1⊃HZ)),Q
      'MSG.K4'⎕WC'Label'('Posn'((4⊃VP)HP))('Size'(VZ,1⊃HZ)),Q
      'MSG.K5'⎕WC'Label'('Posn'((5⊃VP)HP))('Size'(VZ,1⊃HZ)),Q
      'MSG.K6'⎕WC'Label'('Posn'((6⊃VP)HP))('Size'(VZ,1⊃HZ)),Q
      Q←(¯1↓Q),⊂'BCol'BCol_Result
     
⍝ ----- Explain input code --------------------------------------------
      E←('Caption' '≡')('Font' 'MSG.APL')('Size'VZ(W×1.5))('BCol'BCol_Label)
      :If classic
          P←(3⊃VP),HP+(2⊃HZ)+W×0.5
          'MSG.Y1'⎕WC'Label'('Posn'P),E
          Z←'MSG.Y1'⎕WG'Size'
          P[2]+←Z[2]
          'MSG.K8'⎕WC'Label'('Posn'P)('Size'(VZ,2⊃HZ)),Q
      :EndIf
     
⍝ ----- Create more ASCII stuff ---------------------------------------
     
      P←(4⊃VP),HP+(1⊃HZ)+W×0.5
      X←('Size'VZ ⍬)('BCol'BCol_Label)
      'MSG.D1'⎕WC'Label' 'decimal'('Posn'P),X
      Z←'MSG.D1'⎕WG'Size'
      P[2]+←Z[2]
      'MSG.D3'⎕WC'Label'('Posn'P),E,⊂'BCol'BCol_Label
      Z←'MSG.D3'⎕WG'Size'
      P[2]+←Z[2]
      :If classic ⋄ P[2]←2⊃'MSG.K8'⎕WG'Posn' ⋄ :EndIf
      'MSG.K7'⎕WC'Label'('Posn'P)('Size'(VZ,0.5×2⊃HZ)),Q
      P[2]+←(0.5×2⊃HZ)+W×0.5
      'MSG.D2'⎕WC'Label' 'hex'('Posn'P),X
     
⍝ ----- Create shift state buttons ------------------------------------
     
      P←(6⊃VP),HP+(1⊃HZ)+W×1.5
      'MSG.B0'⎕WC'Label'('Posn'P),E
      Z←'MSG.B0'⎕WG'Size'
      P[2]+←Z[2]+W×1.25
      Q←('Style' 'Check')('ReadOnly' 1)('Event' 'Select' ¯1),X
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
      P←⌈0.30000000000000004 0.9×C-(7⊃VP),X
      'MSG'⎕WS('Size'⍬ X)('Posn'P)  ⍝ Fix overall width and position
     
⍝ ----- Trace keystrokes until Close ----------------------------------
     
      H←⎕D,6⍴⎕A                         ⍝ Hex digits
      Z←⌽'MSG.B1' 'MSG.B2' 'MSG.B3'     ⍝ Shift state buttons
      :Repeat ⍝ Wait for an event
          X←⎕DQ'MSG'                      ⍝ Wait for event
          :Select 1
          :Case X[1]∊Z                      ⍝ Shift state buttons?
     ⍝ --> Don't let buttons get focus
              (1⊃X)⎕WS'State' 0
              ⎕NQ'MSG' 'GotFocus'
          :Case ~X[2]∊'Select' 'Close'        ⍝ Close (button or SysMenu)?
     
              object event input char key shift←X
              kl←⎕KL input
              'MSG.K1'⎕WS'Caption'(object)
              'MSG.K2'⎕WS'Caption'(event)
              'MSG.K3'⎕WS'Caption'(input)
              :If classic
                  'MSG.K8'⎕WS'Caption'(' ',kl)
              :EndIf
              'MSG.K4'⎕WS'Caption'(⍕char)
              'MSG.K7'⎕WS'Caption'(' ',H[1+((4-2×classic)⍴16)⊤char])
              'MSG.K5'⎕WS'Caption'(⍕key)
              'MSG.K6'⎕WS'Caption'(' ',⍕shift)
              Z ⎕WS¨(⊂⊂'State'),¨2 2 2⊤shift
              :If ##.RIU
                  R,←input(classic/kl)char key(2 2 2⊤shift)
              :Else
              ⍝
                  r←'Input Code: ',(3↑⍕input),(classic/,'[',kl,']'),', Char: ',⍕char
                  r,←', Key Number: ',(⍕key)
                  r,←', Shift state: ',1 0⍕2 2 2⊤shift
                  ⎕←r
              :EndIf
          :EndSelect
      :Until X[2]∊⊂'Close' ⍝ loop forever
      :If ~##.RIU ⋄ R←'' ⋄ :EndIf
    ∇
:EndNamespace
