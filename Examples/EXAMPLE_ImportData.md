# LSS Example - Adding User Data to Active Directory
    Add-LSSOUFromFile -FileName R:\cis25x_lss\SampleData\25605_OU.csv
    Add-LSSUserFromFile -FileName R:\cis25x_lss\SampleData\25605_US.csv
    Add-LSSGroupFromFile -FileName R:\cis25x_lss\SampleData\25605_GR.csv
    Add-LSSGroupMemberFromFile -FileName R:\cis25x_lss\SampleData\25605_UG.csv