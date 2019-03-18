 (rc rootref disposition copied)←{protect}InitConga args;root;ref;libpath;wsname;found;ref∆;roots;index
⍝ args is an argument list of: root {ref} {libpath} {wsname}
⍝
⍝ root is the Conga root name to look for or create.
⍝    '' means 'DEFAULT' or 'DEFAULTn' if protect=2 (see below)
⍝
⍝ ref is the reference or character array for where to look for/copy the Conga namespace
⍝    default is #
⍝    '' means the location where the code is running (⎕CS '')
⍝
⍝ libpath is the optional path to the Conga shared library
⍝    this would rarely be used, but it's useful in the case of trying to use a version of the library
⍝    other than what's in the used by someone wanting to run something other than the
⍝    default library – e.g. someone testing newer or older library versions.
⍝
⍝ wsname is the workspace name to ⎕CY Conga from if Conga is not found in ref
⍝    this is also an argument only someone using a new/old version of Conga might use
⍝    default is 'conga'
⍝
⍝ protect is an optional integer flag indicating what to do when root is or is not found
⍝    0 – (default) create the root if not found, use the existing root if it is found
⍝    1 – create the root if not found, fail if it is found
⍝    2 – create the root if not found, create a new "incremented" root if it is found
⍝    3 – fail if the root is not found, use it if it is found
⍝
⍝ rc is the return code indicating success (0) or the reason for failure
⍝    0 - success
⍝    1 - error while copying from wsname
⍝    2 - Conga.LIB not found
⍝    3 - invalid Conga reference
⍝    4 - root already exists
⍝    5 - root not found
⍝    6 - Conga initialization failed
⍝
⍝ rootref is a reference to the created/found Conga.LIB instance
⍝
⍝ disposition is
⍝    0 – root created
⍝    1 – existing root used
⍝    2 – incremented root created
⍝   ¯1 - error
⍝
⍝ copied indicates whether Conga was copied into the workspace

 (root ref libpath wsname)←4↑(⊆args),'' '' '' ''

 :If 0=≢ref ⋄ ref←⎕CS'' ⋄ :EndIf
 :If 0=≢wsname ⋄ wsname←'conga' ⋄ :EndIf
 :If 0=⎕NC'protect' ⋄ protect←0 ⋄ :EndIf
 :If 0=≢root ⋄ root←'DEFAULT' ⋄ :EndIf

 (rootref rc disposition found copied)←⍬ ¯1 ¯1 0 0  ⍝ initialize

sel:
 :Select ⎕NC⊂'ref'
 :Case 2.1 ⍝ variable
     ref←⍎∊⍕ref ⋄ →sel
 :CaseList 9.1 9.2 9.4 ⍝ namespace, class, or instance
     :If found←9.1=ref.⎕NC⊂'Conga'
         ref∆←ref.Conga
     :Else
         :Trap 0
             'Conga'ref.⎕CY libpath,wsname
             copied←1 ⋄ ref∆←ref.Conga
         :Else ⋄ →0⊣rc←1
         :EndTrap
     :EndIf
 :Else
     →0⊣rc←3 ⍝ invalid reference
 :EndSelect

 :If 9.4≠ref∆.⎕NC⊂'LIB' ⋄ →0⊣rc←2 ⋄ :EndIf

 :If 0<≢roots←⎕INSTANCES ref∆.LIB
     (index found)←roots.RootName{(≢⍺){⍵,⍵≤⍺}⍺⍳⍵}⊆root
     :If found ⋄ rootref←index⊃roots ⋄ :EndIf
 :Else
     (index found)←1 0
 :EndIf

 disposition←found

 :Select protect
 :Case 0 ⍝    0 (default) – create the root if not found, use the existing root if it is found
         ⍝    this is the predominant use case in older applications
     :If found
         →rc←0
     :EndIf

 :Case 1 ⍝    1 – create the root if not found, fail if it is found
     :If found
         →0⊣(rc disposition rootref)←4 ¯1 ⍬
     :EndIf

 :Case 2 ⍝    2 – create the root if not found, create a new "incremented" root if it is found
     :If found ⍝ Increment root
         root,←,'ZI4'⎕FMT 1+⌈/∊0,2⊃¨⎕VFI¨(≢root)↓¨root{⍵/⍨⊃¨⍺∘⍷¨⍵}roots.RootName
         disposition←2
     :EndIf
 :Case 3 ⍝    3 – fail if the root is not found, use it if it is found
     :If ~found
         →0⊣rc←5
     :EndIf
 :EndSelect

 :Trap 999
     rootref←ref∆.Init root
     rc←0
 :Else
     rc←6
 :EndTrap
