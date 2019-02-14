 (rc rootref disposition copied)←{protect}InitConga args;isChar;found;root;ref;libpath;wsname;ref∆;roots;index
⍝args is an argument list of: root {ref} {libpath} {wsname}
⍝
⍝
⍝
⍝root is the Conga root name to look for or create.
⍝
⍝    '' means 'DEFAULT' or 'DEFAULTn' if protect=2 (see below)
⍝
⍝
⍝
⍝ref is the reference or character array for where to look for/copy the Conga class or instance.
⍝
⍝    default is #
⍝    '' means the location where the code is running (⎕CS '')
⍝
⍝
⍝
⍝libpath is the optional path to the Conga shared library
⍝
⍝    this would rarely be used, but it's useful in the case of trying to use a version of the library
⍝    other than what's in the used by someone wanting to run something other than the
⍝    default library – e.g. someone testing newer or older library versions.
⍝
⍝
⍝
⍝wsname is the workspace name to ⎕CY Conga from if Conga is not found in ref
⍝
⍝    this is also an argument only someone using a new/old version of Conga might use
⍝    default is 'conga'
⍝
⍝
⍝
⍝protect is an optional integer flag indicating what to do when root is or is not found
⍝
⍝    0 (default) – create the root if not found, use the existing root if it is found
⍝    this is the predominant use case in older applications
⍝    1 – create the root if not found, fail if it is found
⍝    2 – create the root if not found, create a new "incremented" root if it is found
⍝    3 – fail if the root is not found, use it if it is found
⍝
⍝
⍝
⍝rc is the return code indicating success (0) or the reason for failure
⍝
⍝    rc>0 is the Conga error code from ErrorTable
⍝    rc<0 is "our" error code for things like workspace not found, copy failed, root not found, etc.
⍝    1 Error while copying wsname
⍝
⍝
⍝
⍝rootref is a reference to the created/found Conga.LIB instance
⍝
⍝
⍝
⍝disposition is
⍝
⍝    0 – root created
⍝    1 – existing root used
⍝    2 – incremented root created
⍝    3 – failed to find root
⍝
⍝
⍝
⍝copied indicates whether Conga was copied into the workspace

 isChar←{(10|⎕DR ⍵)∊0 2}
 (root ref libpath wsname)←4↑⊆args

 :If 0=≢ref ⋄ ref←⎕CS'' ⋄ :EndIf
 :If 0=≢wsname ⋄ wsname←'conga' ⋄ :EndIf
 :If 0=⎕NC'protect' ⋄ protect←0 ⋄ :EndIf

 rootref←0/rc←disposition←found←found←copied←0  ⍝ initialize
sel:
 :Select ⎕NC⊂'ref'
 :Case 2.1 ⍝ variable
     ref←⍎∊⍕ref ⋄ →sel
 :CaseList 9.1,((⊂∊⍕ref)∊(,'#')'⎕SE')/9.2  ⍝ namespace → look for Conga class in the namespace or copy it if not found
     :If found←(⊂'Conga')∊ref.⎕NL-9 ⋄ ref∆←ref.Conga
     :Else
         :Trap 0
             'Conga'⎕CY libpath,wsname
             copied←1 ⋄ ref∆←Conga
         :Else ⋄ →~rc←1
         :EndTrap
     :EndIf
 :Case 9.2 ⍝ instance → make sure its ⎕CLASS is Conga
     :If ~found←∨/'Conga.LIB'⍷⍕⎕CLASS ref
         →0⊣rc←2
     :EndIf
 :EndSelect

 :If 0<≢roots←⎕INSTANCES ref∆.LIB
     root←'DEFAULT'{0<≢⍵:⍵ ⋄ ⍺}root  ⍝ make sure we have a valid rootname (length > 0) - assume DEFAULT if empty (to avoid not finding root if called w empty root)
     (index found)←roots.RootName{(≢⍺){⍵,⍵≤⍺}⍺⍳⍵}⊆root
 :EndIf

 :Select protect
 :Case 0 ⍝    0 (default) – create the root if not found, use the existing root if it is found
        ⍝    this is the predominant use case in older applications
     disposition←found
     :If ~found ⋄ rootref←ref∆.Init root ⋄ :EndIf
 :Case 1 ⍝    1 – create the root if not found, fail if it is found
     :If rc←~disposition←found
         rootref←ref∆.Init root
     :EndIf
 :Case 2 ⍝    2 – create the root if not found, create a new "incremented" root if it is found
     :If found
         ⍝ Increment root
         root←{pre←(∧/~(1⊃⍵)∊⎕D)/1⊃⍵ ⋄ cnt←1+⌈/∊2⊃¨⎕VFI¨{0=≢⍵:'0' ⋄ ⍵}¨{(⌽∧\⌽⍵∊⎕D)/⍵}¨⍵ ⋄ pre,¯4↑'000',⍕cnt}roots.RootName
         disposition←2
     :EndIf
     rootref←ref∆.Init root
 :Case 3 ⍝    3 – fail if the root is not found, use it if it is found
     :If found ⋄ root←index⊃roots ⋄ :EndIf
     disposition←3*~found
 :EndSelect
