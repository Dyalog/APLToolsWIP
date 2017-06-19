:Namespace MatLab
⍝ Tools to read and write MatLab files from Dyalog APL

    Compress←1      ⍝ Set to 0 to NOT gzip each array on export
    NaNValue←⎕NULL  ⍝ Represent NaNs as ⎕NULLS

    ∇ r←MatToSparse array;t;m;n
    ⍝ Convert dense APL array to MatLab Sparse array
      n←+/m←0≠t←⍉array
      r←((,m)/,(⍴m)⍴¯1+⍳≢array)(0,+\n)((,m)/,t)
    ∇

    ∇ r←SparseToMat(shape data);ci;values;jc;ri
     ⍝ Convert MatLab Sparse array to a Dense APL Array
      (ri jc values)←data
      ci←(¯2-/jc)/⍳2⊃shape
      r←shape⍴0
      r[(1+ri),¨ci]←values ⍝ could be optimised
    ∇

    ∇ r←RCDtoSparse(rows cols data);c;p    
     ⍝ Rows Cols Data to MatLab Sparse Array triplet (rows col-offsets data)
      (rows cols data)←(⊂⍋cols)∘⌷¨rows cols data ⍝ Ascending by column 
      rows←rows-1                 ⍝ Index origin zero in MatLab files
      c←(⌈/cols)⍴0                ⍝ Highest column number found
      p←((2≠/cols),1)/⍳⍴cols      ⍝ Indices of ends of each column found
      c[∪cols]←¯2-/0,p            ⍝ Number of elements in each column
      c←+\0,c                     ⍝ Matlab wants a pointer to the start of each column
      r←rows c data
    ∇

    ∇ r←Test;data;f2;f1;new;old;hdrs;p;m;diff;d2;folder;file;d1;b2;b1;common;Compress;i;v1;name;shape;type;identical;sparse;s;t;v2
      ⎕NUNTIE ⎕NNUMS
      folder←'C:\Devt\MatLabAPL\'
     
      :For file :In 'sparse' 'testdataset_nonulls' 'testdataset_uncompressed' 'testdataset'
     
          Compress←(⊂file)∊'sparse' 'testdataset'
          ⎕←'Testing "',file,'.mat"',Compress/'(using zlib compression)'
          d1←Read f1←folder,file,'.mat'
          b1←ReadFile f1
     
          {}d1 Write f2←folder,file,'-copy.mat'
          d2←Read f2
          b2←ReadFile f2
     
          :If (124↓b1)≡124↓b2
              ⎕←'   File is identical except for header.'
          :ElseIf (≢b1)≠≢b2
              ⎕←'   Copy size = ',(⍕≢b2),', original file size was ',⍕≢b1
          :ElseIf
              ⎕←'   Files are same size but ',(⍕(124↓b1)+.≠124↓b2),' bytes are different following the header.'
          :EndIf
     
          :If d1.Variables≢d2.Variables
              ⎕←'   Variable lists not identical:'
              ⎕←'Original' 'Copy',⍉⍪(d1 d2).Variables
          :EndIf
     
          common←↑(↓d1.Variables)∩↓d2.Variables
          identical←⍬
          :For i :In ⍳≢common
              (name shape type)←common[i;]
              :If (v1←d1.Data⍎name)≡v2←d2.Data⍎name
                  identical,←⊂name
              :Else
                  ∘∘∘
              :EndIf
              :If type≡'mxSPARSE_CLASS'
                  t←FromSparse shape v1
                  :If v1≢ToSparse t
                      ∘∘∘ ⍝ to/from Sparse worked
                  :Else
                      ⎕←'To/From Sparse OK: ',name
                  :EndIf
              :EndIf
          :EndFor
          '   Identical after read/write/read: ',,⍕identical
      :EndFor
     
    ∇

    ∇ r←data Write name;header;now;vars;ref;v;sparse;tn;i;value;z;dr;shape;type;int;shapes
      ⍝ Read a Matlab File in Little-Endian Format
     
      int←{⎕UCS,⌽⍉(⍺⍴256)⊤⍵} ⍝ litte-endian ⍺-byte integer
     
      :If 9=(ref←data).⎕NC'Data' ⋄ ref←data.Data ⋄ :EndIf
     
      :If 2=data.⎕NC'Variables' ⋄ vars←data.Variables
      :Else
          vars←⍪(ref.⎕NL-2)(,⍤0 1)⍬'mxDOUBLE_CLASS'
          :If 2=data.⎕NC'Sparse'
          :AndIf ∧/data.Sparse∊vars[;1]
              vars[{⍵/⍳⍴⍵}vars[;1]∊data.Sparse;3]←⊂'mxSPARSE_CLASS'
              vars←(~vars[;1]∊⊂'Sparse')⌿vars
          :EndIf
     
          :For i :In ⍳≢vars
              dr←⎕DR value←ref⍎⊃vars[i;1]
              :Select ⎕DR value
              :Case dyNESTED
                  :If 1=≡value ⍝ simple array with nulls?
                  :AndIf (10|⎕DR(,value)~⎕NULL)∊1 3 5 ⍝ numeric
                      vars[i;2 3]←(⍴value)'mxDOUBLE_CLASS'
                  :Else ⍝ really nested
                      :If 'mxSPARSE_CLASS'≡⊃vars[i;3]
                          :If 3≠⍴value
                              ∘∘∘ ⍝ Sparse array which is not a 3-element vector
                          :EndIf
     
                      :Else ⍝ Not sparse
                          :If ∧/,80=⎕DR¨value
                          :AndIf ∧/1=≢¨shapes←⍴¨value   ⍝ All vectors
                              value←(1,¨shapes)⍴¨value  ⍝ Make 1-row matrices to keep MatLab happy
                          :EndIf
                          vars[i;3]←⊂'mxCELL_CLASS'
                      :EndIf
                  :EndIf
              :CaseList z←dyDOUBLE dyINT32 dyINT16 dyINT8
                  vars[i;3]←(4⍴⊂'mxDOUBLE_CLASS')[z⍳dr] ⍝ Do'em all as doubles for now
              :Else
                  ∘∘∘ ⍝ as yet unsupported type
              :EndSelect
          :EndFor
      :EndIf
     
      1 ⎕NDELETE name
      tn←name ⎕NCREATE 0
     
      now←⎕TS
      header←'MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: '
      header,←(1+7|¯1+2 ⎕NQ'.' 'DateToIDN'(3↑now))⊃Days ⍝ weekday
      header,←' ',(now[2]⊃Months),' '
      header,←,'ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2,< >,ZI4'⎕FMT 1 5⍴now[3 4 5 6 1]
      header←(116↑header),(⎕UCS(8⍴0),0 1),'IM' ⍝ Version 0x0100 and Little Endian IM
      header ⎕NAPPEND tn 80
     
      :For i :In ⍳≢vars
          (name shape type)←vars[i;]
          :If 80=⎕DR type ⋄ :AndIf 2=⎕NC type ⋄ type←⍎type ⋄ :EndIf
          value←ref⍎name
          data←type shape EncodeVariable name value
          :If Compress
              data←80 ⎕DR 2⊃2(219⌶)83 ⎕DR data
              data←(4 int miCOMPRESSED(≢data)),data
          :EndIf
          data ⎕NAPPEND tn
      :EndFor
     
      r←⎕NSIZE tn
      ⎕NUNTIE tn
    ∇

    ∇ r←larg EncodeVariable(name value);flags;global;logical;complex;nzmax;shape;length;data;z;i;apl;eltype;class;nans;j
     ⍝ Encode a variable in MatLab format
     
      complex←logical←global←0
      (class shape)←larg
      :If mxSPARSE_CLASS≡class
          nzmax←≢⊃value       ⍝ number of non-zero elements
          complex←1
      :Else
          (shape nzmax)←(⍴value)0
      :EndIf
     
      r←4 int miMATRIX 65535  ⍝ Everything is a matrix, we will fill in length at the end
      r,←4 int miUINT32 8     ⍝ Array flag header
      flags←2⊥⌽0 0 0 0 complex logical global 0
      r,←(⎕UCS⌽0 0 flags class),(4 int nzmax) ⍝ Array flags
      r,←4 int miINT32,(4×≢shape),({⍵+2|⍵}⍴shape)↑shape ⍝ Dimensions
     
      :If 4≥length←≢name ⍝ Short name
          r,←(2 int miINT8 length),4↑name,4⍴⎕UCS 0
      :Else              ⍝ Long name
          r,←(4 int miINT8 length),(8×⌈length×÷8)↑name,8⍴⎕UCS 0
      :EndIf
     
      :Select class
     
      :Case mxCELL_CLASS
          :If 80=⎕DR∊value
              r,←∊{mxCHAR_CLASS EncodeVariable''⍵}¨value
          :Else
              ∘∘∘ ⍝ Only support char data in Cell Arrays
          :EndIf
     
      :Case mxSPARSE_CLASS
          r,←4 int miINT32(4×≢z←1⊃value)  ⍝ ir
          r,←80 ⎕DR{⍵,(2|≢⍵)⍴0}⊃(⎕DR z) dyINT32 ⎕DR z
          r,←4 int miINT32(4×≢z←2⊃value)  ⍝ jc
          r,←80 ⎕DR{⍵,(2|≢⍵)⍴0}⊃(⎕DR z) dyINT32 ⎕DR z
          r,←4 int miDOUBLE(8×≢z←3⊃value) ⍝ pr
          r,←80 ⎕DR⊃(⎕DR z) dyDOUBLE ⎕DR z
     
      :CaseList z←mxCHAR_CLASS mxDOUBLE_CLASS ⍝ non-nested formats
          apl←(163 645)[i←z⍳class]
     
          nans←⍬
          value←,⍉value
          :If class=mxDOUBLE_CLASS
              value[nans←(value∊⊂NaNValue)/⍳⍴value]←0
          :AndIf (0=⍴nans)∧5≠j←dyINT32 dyINT16 dyINT8 dyBOOL⍳apl←⎕DR value
              eltype←j⊃miINT32 miINT16 miINT8 miINT8 ⍝ We can use a smaller type
          :Else
              eltype←(miUINT16 miDOUBLE)[i]
          :EndIf
     
          data←80 ⎕DR⊃(⎕DR value) apl ⎕DR value
          :If 0≠≢nans
              data[(8×nans-1)∘.+⍳8]←((⍴nans),8)⍴⌽NaN
          :EndIf
          r,←(2*1+4<≢data)int eltype(≢data)
          r,←data
     
      :Else
          ∘∘∘ ⍝ Unsupported type
      :EndSelect
     
      r,←(8|8-8|≢r)⍴⎕UCS 0 ⍝ Word align
      r[4+⍳4]←4 int(≢r)-8×1+2×class=miMATRIX ⍝ Adjust size (2 extra words for miMATRIX)
    ∇

    ∇ var←type DecodeVariable data;flags;class;logical;global;complex;z;rank;size;offset;shape;len;name;arrays;bytes;dr;i;t;nzmax;u;width;eltype
     ⍝ Decode a variable (recursive for matrix types)
     
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
          offset←8×⌈(⊃⌽offset)÷8
     
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
              :If 0∧.≠(eltype bytes)←int 2 2⍴data[offset+⍳4] ⍝ "Compressed" type & length?
              :AndIf bytes≤4
                  offset+←4
              :Else                                     ⍝ 4-byte type & length
                  (eltype bytes)←int 2 4⍴data[offset+⍳8]
                  offset+←8
              :EndIf
     
              :Select eltype      ⍝ Element type
              :Case miMATRIX ⍝ nested element
                  t←eltype DecodeVariable data[offset+⍳bytes]
                  assert 0=≢2⊃t
                  t←4⊃t ⍝ Just the data value
     
              :Case miUTF8
                  t←shape⍴'UTF-8'⎕UCS ⎕UCS data[offset+⍳bytes]
     
              :Case miDOUBLE
                  ⍝ turn NaNs into NaNValue
                  z←data[offset+⍳bytes]
                  z[(¯1+⍳8)∘.+i←((swap NaN)⍷z)/⍳⍴z]←⎕UCS 0
                  t←dyDOUBLE ⎕DR z
                  t[⌈i÷8]←⊂NaNValue
     
              :CaseList miINTs ⍝ Signed Numeric
                  dr←(miINTs⍳eltype)⊃dyINTs
                  t←dr ⎕DR data[offset+⍳bytes]
     
              :CaseList miUINTs
                  width←(miUINTs⍳eltype)⊃1 2 4 8
                  t←int((×/shape),width)⍴data[offset+⍳bytes]
     
              :Else
                  ∘∘∘ ⍝ as yet unsupported type
              :EndSelect
     
              :If (class≠mxSPARSE_CLASS)∧~eltype∊miUTF8 miMATRIX
                  t←⍉(⌽shape)⍴t
              :EndIf
     
              arrays,←⊂t
              offset+←bytes
              offset←8×⌈offset÷8
          :EndWhile
          assert offset=≢data ⍝ no incomplete arrays
     
          :Select class
          :Case mxSPARSE_CLASS
              ⍝ Leave as 3 vectors
          :Case mxCELL_CLASS
              :If (1≠≢arrays)∧80≠⎕DR⊃arrays
              :AndIf 1∧.=≢¨arrays
                  arrays←⎕UCS¨arrays ⍝ uINT16 encoded chars, we think
              :EndIf
              arrays←⍉(⌽shape)⍴arrays
          :Else
              :If 1≠≢arrays ⋄ ∘∘∘ ⋄ :EndIf
              arrays←⊃arrays
          :EndSelect
      :Else
          ∘∘∘ ⍝ Unsupported type
      :EndSelect
      var←shape name class arrays
    ∇

    ∇ r←Read name;data;header;offset;vars;type;size;var;compressed;classes;z;int;swap
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
     
      r.Data←⎕NS''
      :If 1=≢vars←↑vars
          ⍎'r.Data.(',(⍕vars[1;2]),')←vars[1;4]'
      :Else
          ⍎'r.Data.(',(⍕vars[;2]),')←vars[;4]'
      :EndIf
     
      z←vars[;2 1 3]
      classes←↓{(⍵[;1 2]∧.='mx')⌿⍵}'m'⎕NL 2
      z[;3]←classes[(⍎⍕classes)⍳z[;3]]
      r.Variables←z
     
      r.⎕DF header
    ∇

    ∇ data←ReadFile name;tn
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
     
      classes←↓{(⍵[;1 2]∧.='mx')⌿⍵}'m'⎕NL 2
      r⍪←'Variables'('Name' 'Shape' 'Type'⍪ml.Variables)
    ∇

    ∇ assert x
      'Assertion Failed'⎕SIGNAL x↓11
    ∇

    :Section Constants

    ⎕ML←⎕IO←1  ⍝ Do not change these

    ⍝ MatLab Array Classes
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

    ⍝ Matab Element Types
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

    ⍝ Dyalog Element Types
    dyBOOL←11
    dyCHAR←80
    dyINT8←83
    dyINT16←163
    dyINT32←323
    dyNESTED←326
    dyDOUBLE←645
    dyDECF←1287
    dyCOMPLEX←1289

    ⍝ Collections
    miUINTs←miUINT8 miUINT16 miUINT32 miUINT64
    miINTs←miINT8 miINT16 miINT32 ⍝ INT64 not yet supported
    dyINTs←dyINT8 dyINT16 dyINT32

    Months←'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'
    Days←'Mon' 'Tue' 'Wed' 'Thu' 'Fri' 'Sat' 'Sun'

    NaN←⎕UCS 8↑255 248 ⍝ IEEE NaN

    :EndSection

:EndNamespace
