:namespace TestFtpClient
⍝ Description:: 
⍝ This namespace contains functions to test the functionality of the FtpClient class.
⍝ All functions named test_* are test-functions.
⍝ Documentation of the individual functions and the tests they perform
⍝ is provided in the functions themselves.
⍝ Documentation of FtpClient is contained in the class and can be viewed using
⍝    #.FtpClient.Describe           ⍝ brief overview
⍝    #.FtpClient.Documentation      ⍝ a bit more
⍝
⍝    #.TestFtpClient.Documentation  ⍝ Documentation of the namespace TestFtpClient
⍝    #.TestFtpClient.Run            ⍝ to execute all tests
⍝
⍝ Testing::
⍝ The Run Function will execute all Functions that have names beginning with "test_".
⍝ Currently there is one test-function implemented which connects to ftp.mirrorservice.org,
⍝ gets a listing of a folder'c content and then retrieves a file.


    :Section Documentation
    ⎕ML←1 ⋄ ⎕IO←1 ⍝ standard-settings for these
    ⍝ these are generic utilities used for documentation

    ∇ docn←ExtractDocumentationSections describeOnly;⎕IO;box;CR;sections
    ⍝ internal utility function
      ⎕IO←1
      CR←⎕UCS 13
      box←{{⍵{⎕AV[(1,⍵,1)/223 226 222],CR,⎕AV[231],⍺,⎕AV[231],CR,⎕AV[(1,⍵,1)/224 226 221]}⍴⍵}(⍵~CR),' '}
      docn←1↓⎕SRC ⎕THIS
      docn←1↓¨docn/⍨∧\'⍝'=⊃¨docn ⍝ keep all contiguous comments
      docn←docn/⍨'⍝'≠⊃¨docn     ⍝ remove any lines beginning with ⍝⍝
      sections←{∨/'::'⍷⍵}¨docn
      :If describeOnly
          (sections docn)←((2>+\sections)∘/¨sections docn)
      :EndIf
      (sections/docn)←box¨sections/docn
      docn←∊docn,¨CR
    ∇

    ∇ r←Documentation
    ⍝ return full documentation
      :Access public shared
      r←ExtractDocumentationSections 0
    ∇

    ∇ r←Describe
    ⍝ return description only
      :Access public shared
      r←ExtractDocumentationSections 1
    ∇


    ∇ R←Version
      R←'#.TestFtpClient' '1.0.3' '2017-03-11'
    ∇
    :endsection

    :section Testing (feel free to add more)
    ∇ test_mirrorservice;z;pub;readme;host;user;pass;folder;file;sub;path;NL;CR
⍝ Test the FTP Client
      NL←⎕UCS 13 10 ⋄ CR←1⊃NL
      (host user pass)←'ftp.mirrorservice.org' 'anonymous' 'testing'
      path←∊(folder sub file)←'pub/' 'FreeBSD/' 'README.TXT'
     
      :Trap 0
          z←⎕NEW #.FtpClient(host user pass)
     ⍝ Create a new object
      :Else
          ⎕←'Unable to connect to ',host ⋄ →0
      :EndTrap
     
     
      :If 0≠1⊃pub←z.List folder ⍝ retrieve contents of a folder
          ⎕←'Unable to list contents of folder: ',,⍕pub ⋄ →0
      :EndIf
     
      :If ~∨/(¯1↓sub)⍷2⊃pub   ⍝ does it contain the subfolder we're expecting?
          ⎕←'Sub folder ',sub,' not found in folder ',folder,': ',file ⋄ →0
      :EndIf
     
      :If 0≠1⊃readme←z.Get path   ⍝ retrieve file README.TXT
          ⎕←'File not found in folder ',folder,': ',file ⋄ →0
      :EndIf
     
      ⎕←path,' from ',host,':',CR
      ⎕←(⍕⍴2⊃readme),' characters read'  ⍝ maybe we should also check if the file has the expected length? (Assuming it does not change over time - not sure if that is a valid assumption)
    ∇
    :EndSection Documentation

    :section QA
    ∇ Run
⍝ Runs all "test_" functions in current namespace
⍝ we should get a result from these to determine whether they executed successfully or not -
⍝ but the design of these is something for later.
⍝ "We need an "APLUnit" namespace" (MK)
     
⍝[@all] do we care about setting up the ws properly - or is it up to the user to make sure conga and the FTPClient are loaded?
      :If 0=#.⎕NC'DRC' ⋄ 'DRC'#.⎕CY'conga' ⋄ :EndIf  ⍝ make sure conga is there...
     
      ⍎¨{((⊂'test_')≡¨5↑¨⍵)/⍵}⎕NL-3
    ∇
    :endsection
:endnamespace
