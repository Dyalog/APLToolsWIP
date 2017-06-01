:Namespace MatLab 
    ⍝ Tools to read and write MatLab files from Dyalog APL

    ⎕ML←⎕IO←1 ⍝ Defaults
        
    ∇ r←TestRead
      r←Read'c:\devt\matlabapl\testdataset.mat'
    ∇
    
    ∇ r←TestWrite
    
    ∇

    ∇ var←type DecodeVariable data;flags;class;logical;global;complex;z;rank;size;offset;shape;len;name;arrays;bytes;dr;i;t;nzmax
     
      :Select type
      :Case miMATRIX
          assert(miUINT32 8)≡int 2 4⍴data
          (flags class)←¯2↑⎕UCS swap data[8+⍳4]
          :If class=mxSPARSE_CLASS
              nzmax←int data[12+⍳4] ⍝ # non-zero elements
          :EndIf
          :If flags≠0
              (logical global complex)←(⌽(8⍴2)⊤flags)[5 6 7]
          :EndIf                               

          (z rank)←int 2 4⍴data[16+⍳8]
          assert z=miINT32 ⋄ size←4
          rank←rank÷size
          shape←int(rank size)⍴data[offset←24+⍳size×rank]
          offset←⊃⌽offset              

          :If miINT8=int data[offset+⍳4]     ⍝ 4-byte length type indicator?
              len←int data[offset+4+⍳4]
              name←data[offset+8+⍳len]
              offset←offset+8+8×⌈len÷8       ⍝ Padding at end of long name

          :ElseIf miINT8=int data[offset+⍳2] ⍝ 4 or less elements: length & type 2 bytes each
              len←int data[offset+2+⍳2]
              name←data[offset+4+⍳len]
              offset←offset+8                ⍝ Short name guaranteed to be in this 8-byte block
          :Else
              ∘∘∘ ⍝ Unable to decode name
          :EndIf            

          arrays←⍬  

          :While offset<≢data                ⍝ Loop on elements
              :If 0∧.≠(z bytes)←int 2 2⍴data[offset+⍳4] ⍝ "Compressed" type & length?
              :AndIf bytes≤4
                  offset+←4
              :Else                                     ⍝ 4-byte type & length
                  (z bytes)←int 2 4⍴data[offset+⍳8]
                  offset+←8
              :EndIf
     
              :Select z      ⍝ Element type
              :Case miMATRIX ⍝ nested element
                  t←z DecodeVariable data[offset+⍳bytes]
                  assert 0=≢2⊃t
                  t←4⊃t ⍝ Just the data value
              :Case miUTF8
                  t←shape⍴'UTF-8' ⎕UCS ⎕UCS data[offset+⍳bytes]
              :CaseList miINT32 miDOUBLE ⍝ Signed Numeric     
                  dr←(dyINT32 dyDOUBLE)[miINT32 miDOUBLE⍳z]
                  :If dr=dyDOUBLE
                      data[(¯1+⍳8)∘.+(NaN⍷data)/⍳⍴data]←⎕UCS 0
                  :EndIf 

                  t←dr ⎕DR data[offset+⍳bytes]     
                  :If class≠mxSPARSE_CLASS
                      t←⍉(⌽shape)⍴t
                  :EndIf
              :Case miUINT8              ⍝ Unsigned Numerics
                  t←⍉(⌽shape)⍴⎕UCS data[offset+⍳bytes]
              :Else
                  ∘∘∘ ⍝ as yet unsupported type
              :EndSelect
              arrays,←⊂t
              offset+←bytes
              offset←8×⌈offset÷8     
          :EndWhile
          assert offset=≢data ⍝ no incomplete arrays
             
          :Select class
          :Case mxSPARSE_CLASS
              ⍝ Leave as 3 vectors
          :Case mxCELL_CLASS 
              arrays←⍉(⌽shape)⍴arrays
          :Else
              arrays←⊃arrays
          :EndSelect
      :Else
          ∘∘∘ ⍝ Unsupported type
      :EndSelect
      var←shape name class arrays
    ∇

    ∇ r←Read name;data;header;offset;vars;type;size;var;compressed;classes;z;int;NaN;swap
    ⍝ Read a Matlab File
     
      :If 0=≢data←ReadFile name
          ('empty or non-existant file: ',name)⎕SIGNAL 22
      :EndIf
     
      r←⎕NS''
      header←{(-+/∧\(⌽⍵)∊⎕UCS 0 32)↓⍵}124↑data
      r.(VersionTxt Platform Created)←{1 2 2↓¨⍵⊂⍨⍵=⊃⍵}',',header
      :Select data[127 128]
      :Case 'IM' ⋄ swap←⌽ ⋄ r.LittleEndian←1
      :Case 'MI' ⋄ swap←⊢ ⋄ r.LittleEndian←0
      :Else
          'File does not contain MI or IM at position 127/128'⎕SIGNAL 11
      :EndSelect   
      
      int←{256(⊥⍤1)⎕UCS swap ⍵}
      NaN←⎕UCS swap 8↑255 248

      r.VersionNo←'0x',(⎕D,'ABCDEF')[1+,⍉16 16⊤swap ⎕UCS data[125 126]]
     
      offset←128
      vars←⍬
      :While offset<≢data
          (type size)←256(⊥⍤1)⎕UCS data[(offset+0 4)∘.+swap⍳4]
          var←data[(offset+8)+⍳size]
          offset+←size+8
          :If compressed←type=miCOMPRESSED ⍝ zlib compressed
              var←80 ⎕DR ¯2(219⌶)83 ⎕DR var
              (type size)←256(⊥⍤1)⎕UCS swap 2 4⍴var
              var←8↓var
              :If size≠≢var
                  ∘∘∘ ⍝ Assertion failed
              :EndIf
          :EndIf
          vars,←⊂type DecodeVariable var
      :EndWhile           

      :If offset≠≢data
          'Truncated file'⎕SIGNAL 11
      :EndIf          
        
      r.Data←⎕NS ''
      :If 1=≢vars←↑vars
          ⍎'r.Data.(',(⍕vars[1;2]),')←vars[1;4]'
      :Else
          ⍎'r.Data.(',(⍕vars[;2]),')←vars[;4]'
      :EndIf

      z←vars[;2 1 3]
      classes←↓{(⍵[;1 2]∧.='mx')⌿⍵}'m' ⎕NL 2
      z[;3]←classes[(⍎⍕classes)⍳z[;3]]
      r.Variables←z
       
      r.⎕DF header
    ∇

    ∇ data←ReadFile names;tn
      :Trap 0
          tn←name ⎕NTIE 0
          data←⎕NREAD tn 80 ¯1
          ⎕NUNTIE tn
      :Else
          data←''
      :EndTrap
    ∇

    ∇ r←Summary ml;props;classes;z
    ⍝ Display a summary of the contents of the result of a Read
     
      props←'VersionTxt' 'Platform' 'Created' 'LittleEndian' 'VersionNo'
      r←props,⍪⍕¨ml⍎⍕props
      
      classes←↓{(⍵[;1 2]∧.='mx')⌿⍵}'m' ⎕NL 2
      r⍪←'Variables'('Name' 'Shape' 'Type'⍪ml.Variables)   
    ∇

    ∇ assert x
      'Assertion Failed'⎕SIGNAL x↓11
    ∇

    :Section Enums

       mxCELL_CLASS←1
       mxSTRUCT_CLASS←2
       mxOBJECT_CLASS←3
       mxCHAR_CLASS←4
       mxSPARSE_CLASS←5
       mxDOUBLE_CLASS←6
       mxSINGLE_CLASS←7
       mxINT8_CLASS←8
       mxUNINT8_CLASS←9
       mxINT16_CLASS←10
       mxUINT16_CLASS←11
       mxINT32_CLASS←12
       mxUINT32_CLASS←13
       mxINT64_CLASS←14
       mxUINT64_CLASS←15

       miINT8←1
       miUINT8←2
       miINT16←3
       miUINT16←4
       miINT32←5
       miUINT32←6
       miSINGLE←7
       miDOUBLE←9
       miINT64←12
       miUINT64←13
       miMATRIX←14
       miCOMPRESSED←15
       miUTF8←16
       miUTF16←17
       miUTF32←18

       dyBOOL←11
       dyCHAR←80
       dyINT8←83
       dyINT16←163
       dyINT32←323
       dyNESTED←326
       dyDOUBLE←645
       dyDECF←1287
       dyCOMPLEX←1289

    :EndSection

:EndNamespace
