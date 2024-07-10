//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
#include <Arrays/ArrayInt.mqh>
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

                     TimeLapseTreeNode(int id, int start, int end);

   virtual          ~TimeLapseTreeNode();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TimeLapseTree
  {
private:
   TimeLapseTreeNode* root;

   TimeLapseTreeNode* InsertRecursive(TimeLapseTreeNode* node, int id, int start, int end);

   void              InorderRecursive(TimeLapseTreeNode* node);

   void              GetNodesInRange(CArrayObj &result, TimeLapseTreeNode* rootNode, int intInput);

public:
                     TimeLapseTree();

                    ~TimeLapseTree();

   void              Insert(int id, int start, int end);
   void              Insert(TimeLapseTreeNode* newNode);

   bool              UpdateNode(int id, int newStart, int newEnd);
   bool              UpdateNode(TimeLapseTreeNode* newNode);

   void              TraverseInorder();

   TimeLapseTreeNode* GetNode(TimeLapseTreeNode* node, int id);

   void              GetNodesInRange(CArrayObj* &result, int dt);

   void              GetNodesByIdentifierCArr(CArrayObj &result, CArrayInt &identifiers);
   void              GetNodesByIdentifierArr(CArrayObj &result, int &identifiers[]);

   void              GetIdentifierInRange(CArrayInt &result, int dt);
   void              GetIdentifierInRange(int &result[], int dt);

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeLapseTreeNode::TimeLapseTreeNode(int id, int start, int end)
  {
   identifier = id;
   startTime = start;
   endTime = end;
   left = NULL;
   right = NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeLapseTreeNode::~TimeLapseTreeNode()
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeLapseTree::TimeLapseTree()
  {
   root = NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeLapseTree::~TimeLapseTree()
  {
   if(root != NULL)
      delete root;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::InsertRecursive(TimeLapseTreeNode* node, int id, int start, int end)
  {
   if(node == NULL)
      node = new TimeLapseTreeNode(id, start, end);
   else
     {
      if(id < node.identifier)
         node.left = InsertRecursive(node.left, id, start, end);
      else
         if(id > node.identifier)
            node.right = InsertRecursive(node.right, id, start, end);
     }
   return node;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::InorderRecursive(TimeLapseTreeNode* node)
  {
   if(node != NULL)
     {
      InorderRecursive(node.left);
      PrintFormat("Node id: %d start: %d end: %d", node.identifier, node.startTime, node.endTime);
      InorderRecursive(node.right);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::GetNodesInRange(CArrayObj &result, TimeLapseTreeNode* rootNode, int dt)
  {
   if(rootNode != NULL)
     {
      // Check the left subtree
      GetNodesInRange(result, rootNode.left, dt);

      // Check the current node
      if(dt >= rootNode.startTime && dt <= rootNode.endTime)
         result.Add(new TimeLapseTreeNode(rootNode.identifier, rootNode.startTime, rootNode.endTime));

      // Check the right subtree
      GetNodesInRange(result, rootNode.right, dt);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::Insert(int id, int start, int end)
  {
   root = InsertRecursive(root, id, start, end);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeLapseTree::Insert(TimeLapseTreeNode* newNode)
  {
   root = InsertRecursive(root, newNode.identifier, newNode.startTime, newNode.endTime);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              TimeLapseTree::UpdateNode(int id, int newStart, int newEnd)
  {
   TimeLapseTreeNode* node = GetNode(root, id);
   if(node != NULL)
     {
      node.startTime = newStart;
      node.endTime = newEnd;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TimeLapseTree::UpdateNode(TimeLapseTreeNode *newNode)
  {
   TimeLapseTreeNode* node = GetNode(root, newNode.identifier);
   if(node != NULL)
     {
      node.startTime = newNode.startTime;
      node.endTime = newNode.endTime;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::TraverseInorder()
  {
   InorderRecursive(root);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::GetNode(TimeLapseTreeNode* node, int id)
  {
   if(node == NULL)
      return NULL;

   if(id == node.identifier)
      return node;
   else
      if(id < node.identifier)
         return GetNode(node.left, id);
      else
         return GetNode(node.right, id);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::GetNodesInRange(CArrayObj* &result, int dt)
  {
   result = new CArrayObj();
   GetNodesInRange(result, root, dt);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesByIdentifierCArr(CArrayObj &result, CArrayInt &identifiers)
  {
   for(int i = 0; i < identifiers.Total(); i++)
     {
      TimeLapseTreeNode* node = GetNode(root, identifiers[i]);
      if(node != NULL)
        {
         result.Add(node); // Agregar el nodo encontrado directamente
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesByIdentifierArr(CArrayObj &result, int &identifiers[])
  {
   for(int i = 0; i < ArraySize(identifiers); i++)
     {
      TimeLapseTreeNode* node = GetNode(root, identifiers[i]);
      if(node != NULL)
        {
         result.Add(node); // Agregar el nodo encontrado directamente
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::GetIdentifierInRange(CArrayInt &result, int dt)
  {
   CArrayObj* nodesInRange;
   GetNodesInRange(nodesInRange, dt);

   for(int i = 0; i < nodesInRange.Total(); i++)
     {
      TimeLapseTreeNode* node = (TimeLapseTreeNode*)nodesInRange.At(i);
      if(node != NULL)
         result.Add(node.identifier);
      delete node;
     }

   delete nodesInRange;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              TimeLapseTree::GetIdentifierInRange(int &result[], int dt)
  {
   CArrayObj* nodesInRange;
   GetNodesInRange(nodesInRange, dt);

   int total = nodesInRange.Total();

   ArrayResize(result, total);

   for(int i = 0; i < total; i++)
     {
      TimeLapseTreeNode* node = (TimeLapseTreeNode*)nodesInRange.At(i);
      if(node != NULL)
         result[i] = node.identifier;
      delete node;
     }

   delete nodesInRange;
  }
//+------------------------------------------------------------------+
