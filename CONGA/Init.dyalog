 Init path;cd
 cd←# ⎕SE.UCMD'settings cmddir'
 # ⎕SE.UCMD'settings cmddir ',path,'/DyalogBuild:',cd
 # ⎕SE.UCMD'ureset'
 {}# ⎕SE.UCMD'DBuild ',path,'CONGA/CONGA'
 {}# ⎕SE.UCMD'DBuild ',path,'CONGA/CONGADEV'
 #.CONGALIB←'/devt/users/bhc/build/congabuild/distribution/linux/'
 #.CONGALIB←'/devt/builds/Conga_Trunk/latest/linux/'
 ⎕←']DTest ',path,'CONGA/Tests/all -verbose'
