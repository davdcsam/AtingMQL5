//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayInt.mqh>
#include <Arrays/ArrayObj.mqh>

//+------------------------------------------------------------------+
/**
 * @brief Node structure for the TimeLapseTree.
 */
class TimeLapseTreeNode : public CObject
  {
public:
   int               identifier;    ///< Unique identifier for the node
   datetime          startTime;     ///< Start time of the time lapse
   datetime          endTime;       ///< End time of the time lapse
   TimeLapseTreeNode* left;         ///< Pointer to the left child
   TimeLapseTreeNode* right;        ///< Pointer to the right child

   /**
    * @brief Constructor for TimeLapseTreeNode.
    * @param id Node identifier
    * @param start Start time of the time lapse
    * @param end End time of the time lapse
    */
                     TimeLapseTreeNode(int id, datetime start, datetime end);

   /**
    * @brief Destructor for TimeLapseTreeNode.
    */
   virtual          ~TimeLapseTreeNode();
  };

//+------------------------------------------------------------------+
/**
 * @brief Tree structure to manage time lapses.
 */
class TimeLapseTree
  {
private:
   TimeLapseTreeNode* root; ///< Root node of the tree

   /**
    * @brief Recursively inserts a node into the tree.
    * @param node Current node
    * @param id Node identifier
    * @param start Start time of the time lapse
    * @param end End time of the time lapse
    * @return Pointer to the inserted node
    */
   TimeLapseTreeNode* InsertRecursive(TimeLapseTreeNode* node, int id, datetime start, datetime end);

   /**
    * @brief Recursively traverses the tree in-order.
    * @param node Current node
    */
   void              InorderRecursive(TimeLapseTreeNode* node);

   /**
    * @brief Recursively searches for a node by its identifier.
    * @param node Current node
    * @param id Node identifier
    * @return Pointer to the found node
    */
   TimeLapseTreeNode* GetNode(TimeLapseTreeNode* node, int id);

   /**
    * @brief Recursively gets nodes within a specified time range.
    * @param result Array to store the result nodes
    * @param rootNode Current node
    * @param dt Time to check within the range
    */
   void              GetNodesInRange(CArrayObj &result, TimeLapseTreeNode* rootNode, datetime dt);

   /**
    * @brief Collects identifiers of all nodes.
    * @param node Current node
    * @param identifiers Array to store the identifiers
    */
   void              CollectIdentifiers(TimeLapseTreeNode* node, CArrayInt &identifiers);

public:
   /**
    * @brief Constructor for TimeLapseTree.
    */
                     TimeLapseTree();

   /**
    * @brief Destructor for TimeLapseTree.
    */
                    ~TimeLapseTree();

   /**
    * @brief Inserts a new node into the tree.
    * @param id Node identifier
    * @param start Start time of the time lapse
    * @param end End time of the time lapse
    */
   void              Insert(int id, datetime start, datetime end);

   /**
    * @brief Inserts an existing node into the tree.
    * @param newNode Pointer to the new node
    */
   void              Insert(TimeLapseTreeNode* newNode);

   /**
    * @brief Updates an existing node's time range.
    * @param id Node identifier
    * @param newStart New start time
    * @param newEnd New end time
    * @return True if the update was successful
    */
   bool              UpdateNode(int id, int newStart, int newEnd);

   /**
    * @brief Updates an existing node with a new node's details.
    * @param newNode Pointer to the new node
    * @return True if the update was successful
    */
   bool              UpdateNode(TimeLapseTreeNode* newNode);

   /**
    * @brief Traverses the tree in-order.
    */
   void              TraverseInorder();

   /**
    * @brief Gets a node by its identifier.
    * @param id Node identifier
    * @return Pointer to the found node
    */
   TimeLapseTreeNode* GetNode(int id);

   /**
    * @brief Gets nodes within a specified time range.
    * @param result Pointer to the array to store the result nodes
    * @param dt Time to check within the range
    */
   void              GetNodesInRange(CArrayObj* &result, datetime dt);

   /**
    * @brief Gets nodes by their identifiers using CArrayInt.
    * @param result Array to store the result nodes
    * @param identifiers Array of identifiers
    */
   void              GetNodesByIdentifierCArr(CArrayObj &result, CArrayInt &identifiers);

   /**
    * @brief Gets nodes by their identifiers using a native array.
    * @param result Array to store the result nodes
    * @param identifiers Array of identifiers
    */
   void              GetNodesByIdentifierArr(CArrayObj &result, int &identifiers[]);

   /**
    * @brief Gets identifiers of nodes within a specified time range using CArrayInt.
    * @param result Array to store the identifiers
    * @param dt Time to check within the range
    */
   void              GetIdentifierInRange(CArrayInt &result, datetime dt);

   /**
    * @brief Gets identifiers of nodes within a specified time range using a native array.
    * @param result Array to store the identifiers
    * @param dt Time to check within the range
    */
   void              GetIdentifierInRange(int &result[], datetime dt);

   /**
    * @brief Gets all identifiers in the tree using CArrayInt.
    * @param result Array to store the identifiers
    */
   void              GetAllIdentifiers(CArrayInt &result);

   /**
    * @brief Gets all identifiers in the tree using a native array.
    * @param result Array to store the identifiers
    */
   void              GetAllIdentifiers(int &result[]);
  };

//+------------------------------------------------------------------+
TimeLapseTreeNode::TimeLapseTreeNode(int id, datetime start, datetime end)
  {
   identifier = id;
   startTime = start;
   endTime = end;
   left = NULL;
   right = NULL;
  }

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
TimeLapseTree::TimeLapseTree()
  { root = NULL; }

//+------------------------------------------------------------------+
TimeLapseTree::~TimeLapseTree()
  {
   if(root != NULL)
      delete root;
  }

//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::InsertRecursive(TimeLapseTreeNode* node, int id, datetime start, datetime end)
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
void TimeLapseTree::InorderRecursive(TimeLapseTreeNode* node)
  {
   if(node != NULL)
     {
      InorderRecursive(node.left);
      PrintFormat("Node id: %d start: %d end: %d", node.identifier, node.startTime, node.endTime);
      InorderRecursive(node.right);
     }
  }

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
void TimeLapseTree::GetNodesInRange(CArrayObj &result, TimeLapseTreeNode* rootNode, datetime dt)
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
void TimeLapseTree::CollectIdentifiers(TimeLapseTreeNode* node, CArrayInt &identifiers)
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
void TimeLapseTree::Insert(TimeLapseTreeNode* newNode)
  {
   root = InsertRecursive(root, newNode.identifier, newNode.startTime, newNode.endTime);
  }

//+------------------------------------------------------------------+
bool TimeLapseTree::UpdateNode(int id, int newStart, int newEnd)
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
void TimeLapseTree::TraverseInorder()
  { InorderRecursive(root); }

//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::GetNode(int id)
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
      TimeLapseTreeNode* node = GetNode(root, identifiers[i]);
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
      TimeLapseTreeNode* node = GetNode(root, identifiers[i]);
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
      TimeLapseTreeNode* node = (TimeLapseTreeNode*)nodesInRange.At(i);
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
      TimeLapseTreeNode* node = (TimeLapseTreeNode*)nodesInRange.At(i);
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
