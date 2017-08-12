 XLS2JSON;json;path;inp;csv;val;err;z;xls
⍝ A utility to convert user-friendly XLS-Files
⍝ into .json that the ConfReg-App will process. So this only needs to be executed
⍝ when the underlying XLS-Files were changed.
⍝
⍝ This function needs to be loaded into a V16-Interpreter with MiServer running (so that we can access #.json)
⍝ NB: fields that have names starting with 'id' or that contain a '_' will be converted into numbers!
⍝ Prefix "nv" contains a numeric vector where elements are separated by "/" - be careful to enter these as strings!
⍝ Suffix "TS" indicates a field is a timestamp (3 to 7 integers, space-separated in one cell.)

 split←{⎕ML←3 ⋄ ⍺←' ' ⋄ ⍵⊂⍨~⍵∊⍺}
 tonum←{0=⍴⎕D∩w←⍕⍵:0 ⋄ ⍬⍴2⊃⎕VFI{w←⍵ ⋄ ((w='-')/w)←'¯' ⋄ ((w=',')/w)←'.' ⋄ w}w}
 dupes←{0~⍨,{(1<⍴⍵)/⍺}⌸⍵}
 err←0  ⍝ did we encounter any errors during processing?

 :If 16>{2⊃⎕VFI(¯1+⍵⍳'.')↑⍵}2⊃'.'⎕WG'aplversion'
     'Please execute this data-conversion with V16 - that version is just too good to ignore it! ;-)'⎕SIGNAL 1
 :EndIf
 :If 0=⎕NC⊂'#.JSON.fromTable'
     'Please execute this conversion function inside an instance of MiServer3'⎕SIGNAL 1
 :EndIf
 :If 0=#.⎕NC'LoadXL' ⋄ ⎕CY'LoadData' ⋄ :EndIf
 path←#.Boot.AppRoot,'Data\'


 :For inp :In FileList←'confs' 'items' 'packages' 'items2packages' 'itemtypes' 'texts'  ⍝ wrong casing does not matter under Windows!
 ⍝    csv←getCSV path,inp,'.csv'                                          ⍝ read the file
     xls←LoadXL path,inp,'.xlsx'
     csv←⍉↑{
         ((2↑1⊃⍵)≡'id')∨'_'≡1⊃1⊃⍵:⍵[1],tonum¨1↓⍵     ⍝ convert id/_ into numeric fields
         'TS'≡¯2↑1⊃⍵:⍵[1],{7↑2⊃⎕VFI⍕⍵}¨1↓⍵           ⍝ everything ending with TS is a timestamp (NumVec with 7 elems)
         'nv'≡2↑1⊃⍵:⍵[1],{tonum¨'/'split ⍵}¨⍕¨1↓⍵
         ⋄ ⍵
     }¨↓[1]{⍵≡⎕NULL:'' ⋄ ⍵}¨xls  ⍝ replace ⎕NULL with '' and handle some special fields as well as numeric fields
     :For c :In ⍸{'TS'≡¯2↑⍵}¨csv[1;]   ⍝ search for TS-Columns (and add a columns with the same name + suffix "_IDN") which is easier for comparisons/sorting
         val←{⍵≢7↑0:+2 ⎕NQ'.' 'DateToIDN'⍵ ⋄ 0}¨1↓csv[;c]
         csv,←(⊂(' '~⍨1⊃csv[;c]),'_IDN'),val
     :EndFor
     json←#.JSON.fromTable csv                                           ⍝ build json
     ⍎inp,'←json'
     :Select inp
     :Case 'items'
          ⍝items.(_Price+←_PriceAccommodation)    ⍝ is layed out in separate columns in the Items-Table and needs to be added...
     :Case 'packages'
         ⍝packages.(_Price←_Price+_PriceAccommodation)
     :Else
     :EndSelect
 :EndFor

 itemtypes.HasListeners←0
 items.BelongsToObservedType←0
 :For (it cnt) :In (∪items.nvOnlyIfTypeCount)~⊂⍬
     itemtypes[itemtypes.id⍳it].HasListeners←1
     items[⍸items._Type=it].BelongsToObservedType←1
 :End
 items.SuperType←(itemtypes._SuperType,0)[itemtypes.id⍳items._Type]
 items.NeedsOneOf←⊂⍬
 :For i :In (items._SubSelectionOf>0)/items
     z←items.id⍳i._SubSelectionOf
     items[z].NeedsOneOf,⍨←i.id
     :If items[z].id_conf∨.≠i.id_conf
         ⎕←'Plausibility-error: item with id=',(⍕i.id),'._SubSelectionOf points to items with a different value for conf_id!'
     :EndIf
 :EndFor

 :For inp :In FileList
 ⍝ do not try to combine these two loops into one - this is done intentionally, so that one table may have effects
 ⍝ on another table's data!
     json←1(⎕JSON⍠'Compact' 0)⍎inp
     1 ⎕NDELETE path,inp,'.json'                                           ⍝ and write it
     json'UTF-8-BOM' 10 ⎕NPUT path,inp,'.json'
     ⎕EX'json'
 :EndFor

 ⍝ Error-Checking
 :If err∨←∨/z←~items2packages.id_item∊items.id
     '### Plausibility-Error: there are records in "items2packages" with id_item that do not have corresponding entries (with the same id) in table "items"'
     '### Please check records referring to these values of "id_item":' ⋄ z/items2packages.id_item
 :EndIf
 z←~z
 :If err∨←∨/z1←items.id_conf[items.id⍳z/items2packages.id_item]≠packages.id_conf[packages.id⍳z/items2packages.id_package]
     '### Plausibility-Error: there are records in "items2packages" with id_item that do not have corresponding entries (with the same id) in table "items"'
     '### Please check the following records:' ⋄ '<[>,I3,<]>'⎕FMT z1/⍸z
 :EndIf
 :If 0<⍴z←dupes confs.id ⋄ '### Error: Duplicate IDs in table "confs": ',z ⋄ err←1 ⋄ :EndIf
 :If 0<⍴z←dupes packages.id ⋄ '### Error: Duplicate IDs in table "packages": ',z ⋄ err←1 ⋄ :EndIf
 :If 0<⍴z←dupes items.id ⋄ ∘∘∘ ⋄ '### Error: Duplicate IDs in table "items": ',z ⋄ err←1 ⋄ :EndIf
 :If 0<⍴z←dupes itemtypes.id ⋄ '### Error: Duplicate IDs in table "itemtypes": ',z ⋄ err←1 ⋄ :EndIf
 ⎕←(1+err)⊃'*** Created all .json-Files w/o problems!' '### Pls. check these issues and re-run!'
