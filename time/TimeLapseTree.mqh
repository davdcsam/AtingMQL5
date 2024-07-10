//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Arrays/ArrayObj.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TimeLapseTreeNode : public CObject
  {
public:
   int               identifier;
   int               startTime;
   int               endTime;
   TimeLapseTreeNode* left;
   TimeLapseTreeNode* right;

                     TimeLapseTreeNode(int id, int start, int end)
     {
      identifier = id;
      startTime = start;
      endTime = end;
      left = NULL;
      right = NULL;
     }

   virtual          ~TimeLapseTreeNode()
     {
      if(left != NULL)
        {
         delete left;
         left = NULL;
        }
      if(right != NULL)
        {
         delete right;
         right = NULL;
        }
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TimeLapseTree
  {
private:
   TimeLapseTreeNode* root;

public:
                     TimeLapseTree()
     {
      root = NULL;
     }

                    ~TimeLapseTree()
     {
      if(root != NULL)
         delete root;
     }

   void              Insert(int id, int start, int end)
     {
      root = InsertRecursive(root, id, start, end);
     }

   TimeLapseTreeNode* InsertRecursive(TimeLapseTreeNode* node, int id, int start, int end)
     {
      if(node == NULL)
        {
         node = new TimeLapseTreeNode(id, start, end);
        }
      else
        {
         if(id < node.identifier)
           {
            node.left = InsertRecursive(node.left, id, start, end);
           }
         else
            if(id > node.identifier)
              {
               node.right = InsertRecursive(node.right, id, start, end);
              }
        }
      return node;
     }

   void              TraverseInorder()
     {
      InorderRecursive(root);
     }

   void              InorderRecursive(TimeLapseTreeNode* node)
     {
      if(node != NULL)
        {
         InorderRecursive(node.left);
         PrintFormat("Node id: %d start: %d end: %d", node.identifier, node.startTime, node.endTime);
         InorderRecursive(node.right);
        }
     }

   void              FindNodesInRange(int intInput, TimeLapseTreeNode* node, CArrayObj &result)
     {
      if(node != NULL)
        {
         // Check the left subtree
         FindNodesInRange(intInput, node.left, result);

         // Check the current node
         if(intInput >= node.startTime && intInput <= node.endTime)
           {
            result.Add(new TimeLapseTreeNode(node.identifier, node.startTime, node.endTime)); 
           }

         // Check the right subtree
         FindNodesInRange(intInput, node.right, result);
        }
     }

   void              GetNodesInRange(int dt, CArrayObj* &arrObj)
     {
      arrObj = new CArrayObj();
      FindNodesInRange(dt, root, arrObj);
     }

   bool              UpdateNode(int id, int newStart, int newEnd)
     {
      TimeLapseTreeNode* node = FindNode(root, id);
      if(node != NULL)
        {
         node.startTime = newStart;
         node.endTime = newEnd;
         return true;
        }
      return false;
     }

private:
   TimeLapseTreeNode* FindNode(TimeLapseTreeNode* node, int id)
     {
      if(node == NULL)
        {
         return NULL;
        }
      if(id == node.identifier)
        {
         return node;
        }
      else
         if(id < node.identifier)
           {
            return FindNode(node.left, id);
           }
         else
           {
            return FindNode(node.right, id);
           }
     }
  };
//+------------------------------------------------------------------+
