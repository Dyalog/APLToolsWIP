:Namespace help
⍝ Private User Command
    Myname←'Help'
    ⎕IO←1 ⋄ ⎕ML←1

    ∇ r←List
      r←⎕NS¨1⍴⊂⍬
   ⍝ Name, group, short description and parsing rules
      r.Name←,¨⊂Myname
      r.Group←⊂'TOOLS'
      r[1].Desc←'First attempt to do a smart help-command. '
      r.Parse←⊂' -web  -src= '
    ∇

    ∇ r←Run(Cmd Input);HtmlHelp;helpdir;searchTerm;matches;searchTerm∆;dir;xml;tab
      :Select Cmd
      :Case Myname
          helpdir←(2 ⎕NQ'.' 'getenvironment' 'dyalog'),'/help/'
          searchTerm←1⊃Input.Arguments
     
          :If 1=≢searchTerm  ⍝ help for a single character? Let's try to find it in the help of the language-bar
          ⍝ we need the xml-data - and it is in the same dir as this fn was...
              dir←1⊃⎕NPARTS Scriptfile
              xml←1⊃⎕NGET dir,'/lbar.xml'
              tab←⎕XML xml  ⍝ no plausibility-checking - we assume file was untampered. If it was and this creates errors, that's the tamperer's problem ;-)
              tab←{(⌽3,3÷⍨⍴⍵)⍴⍵}(tab[;1]=2)⌿tab[;3]  ⍝ char/desc/text
              :If (⊂searchTerm)∊tab[;1]
                  r←tab[tab[;1]⍳⊂searchTerm;3 2]
                  :Return
              :EndIf
          :EndIf
     
          :If 0=≢matches←⊃0(⎕NINFO⍠1)helpdir,searchTerm             ⍝ any immediate matching filenames?
              :If 0=≢matches←⊃0(⎕NINFO⍠1)helpdir,searchTerm,'*'     ⍝ any filenames starting with searchTerm
                  matches←⊃0(⎕NINFO⍠1)helpdir,'*',searchTerm,'*'    ⍝ or ending ith it?
              :EndIf
          :EndIf
     
          :If 0=≢matches                                      ⍝ if  nothing found...
              :Trap 0
                  matches←911⌶searchTerm                                ⍝ check if we have an entry for searchTerm as a symbol
              :Else
                  matches←'microsoft'   ⍝ looks stupid, but sometimes 911 does not return a result and immediately goes to social.microsoft.com etc.
              :EndTrap
              :If ~∨/'microsoft'⍷matches
              ⍝ todo;
              ⍝ are we on Windows?
              ⍝ how is help presented on other platforms and how can we access it from here?
                  ⎕SE.SALT.⎕NA'u hhctrl.ocx|HtmlHelp* U <0T U U'
                  {}⎕SE.SALT.HtmlHelp('⎕se'⎕WG'handle')matches 0 0
                  r←matches
                  :Return
              :Else
⍝                  :If matches{((⍺⍳'?')↑⍺)≡(⍵⍳'?')↑⍵}911⌶'SurelyWillNotFindAnythingForThisTextin911'
          ⍝ Possible next steps:
          ⍝ * search idiom-list (call http://miserver.dyalog.com/Examples/Applications/Idiom_Search.mipage)
          ⍝   passing a value for the filter
          ⍝ * search the Help-Index (but how can we call specific help-topic cross-platform?) - requires info from MadCap
          ⍝ * launch a google-search on dyalog.com for "searchTerm" (this will include a search of dfns etc.)
          ⍝
          ⍝ For further thinking:
          ⍝ * what to do with RIDE?  Minimal solution: →0  // does RIDE-Protocol allow us to instruct RIDE to open URL?
          ⍝ * TTY???
⍝ is it perhaps a user command?
                  ⎕SE.UCMD'matches←',searchTerm∆←{(('?'≢⍬⍴⍵)⍴'?'),⍵}searchTerm
                  :If 'No commands or groups match ]'≡29↑1⊃matches
     
                      r←'Found no help for argument "',searchTerm,'"'
     
                  :Else
                      r←matches{⎕ML←1 ⋄ 1=≡⍺:⍵,(⎕UCS 13),⍺ ⋄ ∊(⍵,⎕UCS 13),⍺,¨⎕UCS 13}']',searchTerm∆
                      :return
                  :EndIf
                  :Return
 ⍝                 :Else  ⍝ got result from 911
 ⍝                 :EndIf
              :EndIf
          :ElseIf 1<≢matches
     
          :EndIf
          r←1⊃matches
          ⍝ differentiate by platform:
          ⍝ OSX: open <filename>
          ⍝ Linux: xdg-open
          ⎕CMD('start "Your doc" ',{'"',⍵,'"'}1⊃matches)⍝'Normal'
      :EndSelect
    ∇

    ∇ r←level Help Cmd;⎕ML
      r←'Help text to appear for ]?help'
    ∇

    ∇ R←Scriptfile
    ⍝ unfortunately Salt uses different variables to refer to {current script} in different contexts.
    ⍝ This little utility tries to return something that worked in all cases I tested (with SALT 2.63)
      :If 2=##.⎕NC'SourceFile' ⋄ R←##.SourceFile            ⍝ Run
      :ElseIf 2=##.##.⎕NC'c' ⋄ R←##.##.c                    ⍝ Help
      :ElseIf 2=##.⎕NC't' ⋄ R←##.t                          ⍝ List
      :ElseIf 2=##.##.⎕NC't' ⋄ R←⊃,/2↑⎕NPARTS ##.##.t~'"'   ⍝ observed when UCMD was called during MiServer's Start
      :Else ⋄ R←'(unkown)'
          600⌶1
          ∘∘∘Can not determine Scriptfile∘∘∘
          600⌶0
      :EndIf
    ∇


:EndNamespace
