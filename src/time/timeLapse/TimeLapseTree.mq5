//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "TimeLapseTree.mqh"

//+------------------------------------------------------------------+
TimeLapseTree::TimeLapseTree()
  { root = NULL; }

//+------------------------------------------------------------------+
TimeLapseTree::~TimeLapseTree()
  {
   if(root != NULL)
      delete root;
  }

//+------------------------------------------------------------------+
TimeLapseNode* TimeLapseTree::InsertRecursive(TimeLapseNode* node, int id, datetime start, datetime end)
  {
   if(node == NULL)
      node = new TimeLapseNode(id, start, end);
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
void TimeLapseTree::InorderRecursive(TimeLapseNode* node)
  {
   if(node != NULL)
     {
      InorderRecursive(node.left);
      PrintFormat("Node id: %d start: %d end: %d", node.identifier, node.startTime, node.endTime);
      InorderRecursive(node.right);
     }
  }

//+------------------------------------------------------------------+
TimeLapseNode* TimeLapseTree::GetNode(TimeLapseNode* node, int id)
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
void TimeLapseTree::GetNodesInRange(CArrayObj &result, TimeLapseNode* rootNode, datetime dt)
  {
   if(rootNode != NULL)
     {
      // Check the left subtree
      GetNodesInRange(result, rootNode.left, dt);

      // Check the current node
      if(dt >= rootNode.startTime && dt <= rootNode.endTime)
         result.Add(new TimeLapseNode(rootNode.identifier, rootNode.startTime, rootNode.endTime));

      // Check the right subtree
      GetNodesInRange(result, rootNode.right, dt);
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::CollectIdentifiers(TimeLapseNode* node, CArrayInt &identifiers)
  {
   if(node != NULL)
     {
      CollectIdentifiers(node.left, identifiers);
      identifiers.Add(node.identifier);
      CollectIdentifiers(node.right, identifiers);
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::Insert(int id, datetime start, datetime end)
  { root = InsertRecursive(root, id, start, end); }

//+------------------------------------------------------------------+
void TimeLapseTree::Insert(TimeLapseNode* newNode)
  {
   root = InsertRecursive(root, newNode.identifier, newNode.startTime, newNode.endTime);
  }

//+------------------------------------------------------------------+
bool TimeLapseTree::UpdateNode(int id, datetime newStart, datetime newEnd)
  {
   TimeLapseNode* node = GetNode(root, id);
   if(node != NULL)
     {
      node.startTime = newStart;
      node.endTime = newEnd;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool TimeLapseTree::UpdateNode(TimeLapseNode *newNode)
  {
   TimeLapseNode* node = GetNode(root, newNode.identifier);
   if(node != NULL)
     {
      node.startTime = newNode.startTime;
      node.endTime = newNode.endTime;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
void TimeLapseTree::UpdateDates(void)
  {
   CArrayInt identifiers;
   GetAllIdentifiers(identifiers);
   for(int i=0;i<identifiers.Total();i++)
     {
      TimeLapseNode* node = GetNode(identifiers.At(i));
      Time timeS, timeE;
      TimeHelper::DateTimeToTimeStruct(timeS, node.startTime);
      TimeHelper::DateTimeToTimeStruct(timeE, node.endTime);
      node.startTime = TimeHelper::IntegerToDateTime(timeS.Hour, timeS.Min, timeS.Sec);
      node.endTime = TimeHelper::IntegerToDateTime(timeE.Hour, timeE.Min, timeE.Sec);
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::TraverseInorder()
  { InorderRecursive(root); }

//+------------------------------------------------------------------+
TimeLapseNode* TimeLapseTree::GetNode(int id)
  { return GetNode(root, id); }

//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesInRange(CArrayObj* &result, datetime dt)
  {
   result = new CArrayObj();
   GetNodesInRange(result, root, dt);
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesByIdentifierCArr(CArrayObj &result, CArrayInt &identifiers)
  {
   for(int i = 0; i < identifiers.Total(); i++)
     {
      TimeLapseNode* node = GetNode(root, identifiers[i]);
      if(node != NULL)
        {
         result.Add(node);
        }
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesByIdentifierArr(CArrayObj &result, int &identifiers[])
  {
   for(int i = 0; i < ArraySize(identifiers); i++)
     {
      TimeLapseNode* node = GetNode(root, identifiers[i]);
      if(node != NULL)
        {
         result.Add(node);
        }
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetIdentifierInRange(CArrayInt &result, datetime dt)
  {
   CArrayObj* nodesInRange;
   GetNodesInRange(nodesInRange, dt);

   for(int i = 0; i < nodesInRange.Total(); i++)
     {
      TimeLapseNode* node = (TimeLapseNode*)nodesInRange.At(i);
      if(node != NULL)
         result.Add(node.identifier);
      delete node;
     }

   delete nodesInRange;
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetIdentifierInRange(int &result[], datetime dt)
  {
   CArrayObj* nodesInRange;
   GetNodesInRange(nodesInRange, dt);

   int total = nodesInRange.Total();

   ArrayResize(result, total);

   for(int i = 0; i < total; i++)
     {
      TimeLapseNode* node = (TimeLapseNode*)nodesInRange.At(i);
      if(node != NULL)
         result[i] = node.identifier;
      delete node;
     }

   delete nodesInRange;
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetAllIdentifiers(CArrayInt &result)
  {
   CollectIdentifiers(root, result);
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetAllIdentifiers(int &result[])
  {
   CArrayInt identifiers;
   CollectIdentifiers(root, identifiers);

   int total = identifiers.Total();
   ArrayResize(result, total);

   for(int i = 0; i < total; i++)
     {
      result[i] = identifiers[i];
     }
  }
//+------------------------------------------------------------------+
