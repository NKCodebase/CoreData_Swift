 If you use NSManagedObject Subclass....
 
 In your .xcdatamodeld file,

 Your Codegen setting is still set to “Class Definition”.
 
 Step 1:
  Open:
    CoreData_Swift.xcdatamodeld file
  Click On:
    CDPerson entity

 Step 2:
    On right side → Data Model Inspector
      Find Codegen
    Change it to:
      Manual/None✅
 
 Step 3: Clean Build and Build
