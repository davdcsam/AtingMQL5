//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <AtingMQL5/.mqh>

//+------------------------------------------------------------------+
void OnStart()
  {
   TestTime tt;

   tt.Start();

   bool passZeroIsZero = TestZeroProcessorIsZero();
   bool passZeroRunArray = TestZeroProcessorRunArray();
   bool passZeroRunArrayType = TestZeroProcessorRunArrayType();

   bool passNegativeIsNegative = TestNegativeProcessorIsNegative();
   bool passNegativeRunArray = TestNegativeProcessorRunArray();
   bool passNegativeRunArrayType = TestNegativeProcessorRunArrayType();

   bool passNoEmptyRunString = TestNoEmptyProcessorRunString();
   bool passNoEmptyRunCObject = TestNoEmptyProcessorRunCObject();
   bool passNoEmptyRunStringArray = TestNoEmptyProcessorRunStringArray();
   bool passNoEmptyRunCArrayString = TestNoEmptyProcessorRunCArrayString();
   bool passNoEmptyRunCObjectArray = TestNoEmptyProcessorRunCObjectArray();

   bool allPassed = passZeroIsZero && passZeroRunArray && passZeroRunArrayType &&
                    passNegativeIsNegative && passNegativeRunArray && passNegativeRunArrayType &&
                    passNoEmptyRunString && passNoEmptyRunCObject && passNoEmptyRunStringArray &&
                    passNoEmptyRunCArrayString && passNoEmptyRunCObjectArray;

   Print("Overall Test Result - All Tests Passed: ", allPassed);

   tt.End();
  }

//+------------------------------------------------------------------+
void PrintTestResult(string testName, bool result)
  {
   Print(testName, " - Passed: ", result);
  }

//+------------------------------------------------------------------+
bool TestZeroProcessorIsZero()
  {
   bool test1 = ZeroProcessor::Run(0);   // Expected: true
   bool test2 = ZeroProcessor::Run(1);   // Expected: false

   bool result = (test1 == true) && (test2 == false);
   PrintTestResult("TestZeroProcessorIsZero", result);
   return result;
  }

//+------------------------------------------------------------------+
bool TestZeroProcessorRunArray()
  {
   int values[] = {0, 1, 0, 2};
   int result[];
   bool res = ZeroProcessor::Run(values, result, true);  // Expect to return indices

   bool expected = true;
   bool indicesMatch = true;
   int expectedResults[] = {0, 2};
   if(ArraySize(result) != ArraySize(expectedResults))
     {
      indicesMatch = false;
     }
   else
     {
      for(int i = 0; i < ArraySize(result); i++)
        {
         if(result[i] != expectedResults[i])
           {
            indicesMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && indicesMatch;
   PrintTestResult("TestZeroProcessorRunArray", resultStatus);
   return resultStatus;
  }

//+------------------------------------------------------------------+
bool TestZeroProcessorRunArrayType()
  {
   CArrayInt values;
   values.Add(0);
   values.Add(1);
   values.Add(0);
   values.Add(2);

   CArrayInt result;
   bool res = ZeroProcessor::Run(values, result, true);  // Expect to return indices

   bool expected = true;
   bool indicesMatch = true;
   CArrayInt expectedResults;
   expectedResults.Add(0);
   expectedResults.Add(2);

   if(result.Total() != expectedResults.Total())
     {
      indicesMatch = false;
     }
   else
     {
      for(int i = 0; i < result.Total(); i++)
        {
         if(result.At(i) != expectedResults.At(i))
           {
            indicesMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && indicesMatch;
   PrintTestResult("TestZeroProcessorRunArrayType", resultStatus);
   return resultStatus;
  }

//+------------------------------------------------------------------+
bool TestNegativeProcessorIsNegative()
  {
   bool test1 = NegativeProcessor::IsNegative(-1);  // Expected: true
   bool test2 = NegativeProcessor::IsNegative(0);   // Expected: false
   bool test3 = NegativeProcessor::IsNegative(1);   // Expected: false

   bool result = (test1 == true) && (test2 == false) && (test3 == false);
   PrintTestResult("TestNegativeProcessorIsNegative", result);
   return result;
  }

//+------------------------------------------------------------------+
bool TestNegativeProcessorRunArray()
  {
   int values[] = {-1, 0, 1, -2};
   int result[];
   bool res = NegativeProcessor::Run(values, result, true);  // Expect to return indices

   bool expected = true;
   bool indicesMatch = true;
   int expectedResults[] = {0, 3};
   if(ArraySize(result) != ArraySize(expectedResults))
     {
      indicesMatch = false;
     }
   else
     {
      for(int i = 0; i < ArraySize(result); i++)
        {
         if(result[i] != expectedResults[i])
           {
            indicesMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && indicesMatch;
   PrintTestResult("TestNegativeProcessorRunArray", resultStatus);
   return resultStatus;
  }

//+------------------------------------------------------------------+
bool TestNegativeProcessorRunArrayType()
  {
   CArrayInt values;
   values.Add(-1);
   values.Add(0);
   values.Add(1);
   values.Add(-2);

   CArrayInt result;
   bool res = NegativeProcessor::Run(values, result, true);  // Expect to return indices

   bool expected = true;
   bool indicesMatch = true;
   CArrayInt expectedResults;
   expectedResults.Add(0);
   expectedResults.Add(3);

   if(result.Total() != expectedResults.Total())
     {
      indicesMatch = false;
     }
   else
     {
      for(int i = 0; i < result.Total(); i++)
        {
         if(result.At(i) != expectedResults.At(i))
           {
            indicesMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && indicesMatch;
   PrintTestResult("TestNegativeProcessorRunArrayType", resultStatus);
   return resultStatus;
  }

//+------------------------------------------------------------------+
bool TestNoEmptyProcessorRunString()
  {
   bool test1 = NoEmptyProcessor::Run("Hello");  // Expected: true
   bool test2 = NoEmptyProcessor::Run("");       // Expected: false

   bool result = (test1 == true) && (test2 == false);
   PrintTestResult("TestNoEmptyProcessorRunString", result);
   return result;
  }

//+------------------------------------------------------------------+
bool TestNoEmptyProcessorRunCObject()
  {
   CObject *obj1 = new CObject();
   CObject *obj2 = NULL;

   bool test1 = NoEmptyProcessor::Run(obj1);  // Expected: true
   bool test2 = NoEmptyProcessor::Run(obj2);  // Expected: false

   bool result = (test1 == true) && (test2 == false);
   PrintTestResult("TestNoEmptyProcessorRunCObject", result);

   delete obj1;  // Cleanup
   return result;
  }

//+------------------------------------------------------------------+
bool TestNoEmptyProcessorRunStringArray()
  {
   string values[] = {"One", "Two", "", "Three"};
   string result[];
   bool res = NoEmptyProcessor::Run(values, result, true);  // Expect to return indices

   bool expected = true;
   bool indicesMatch = true;
   string expectedResults[] = {"0", "1", "3"};
   if(ArraySize(result) != ArraySize(expectedResults))
     {
      indicesMatch = false;
     }
   else
     {
      for(int i = 0; i < ArraySize(result); i++)
        {
         if(result[i] != expectedResults[i])
           {
            indicesMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && indicesMatch;
   PrintTestResult("TestNoEmptyProcessorRunStringArray", resultStatus);
   return resultStatus;
  }

//+------------------------------------------------------------------+
bool TestNoEmptyProcessorRunCArrayString()
  {
   CArrayString values;
   values.Add("One");
   values.Add("Two");
   values.Add("");
   values.Add("Three");

   CArrayString result;
   bool res = NoEmptyProcessor::Run(values, result, true);  // Expect to return indices

   bool expected = true;
   bool indicesMatch = true;
   CArrayString expectedResults;
   expectedResults.Add("0");
   expectedResults.Add("1");
   expectedResults.Add("3");

   if(result.Total() != expectedResults.Total())
     {
      indicesMatch = false;
     }
   else
     {
      for(int i = 0; i < result.Total(); i++)
        {
         if(result.At(i) != expectedResults.At(i))
           {
            indicesMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && indicesMatch;
   PrintTestResult("TestNoEmptyProcessorRunCArrayString", resultStatus);
   return resultStatus;
  }

//+------------------------------------------------------------------+
bool TestNoEmptyProcessorRunCObjectArray()
  {
   CObject *values[] = {new CObject(), NULL, new CObject()};
   CObject *result[];
   bool res = NoEmptyProcessor::Run(values, result, true);  // Expect to return objects

   bool expected = true;
   bool objectsMatch = true;
   CObject *expectedResults[] = {values[0], values[2]};

   if(ArraySize(result) != ArraySize(expectedResults))
     {
      objectsMatch = false;
     }
   else
     {
      for(int i = 0; i < ArraySize(result); i++)
        {
         if(result[i] != expectedResults[i])
           {
            objectsMatch = false;
            break;
           }
        }
     }

   bool resultStatus = res && objectsMatch;
   PrintTestResult("TestNoEmptyProcessorRunCObjectArray", resultStatus);

   for(int i = 0; i < ArraySize(values); i++)    // Cleanup
     {
      delete values[i];
     }
   return resultStatus;
  }
//+------------------------------------------------------------------+
