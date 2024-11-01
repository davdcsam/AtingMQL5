//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayInt.mqh>
#include <Arrays/ArrayObj.mqh>
#include "../TimeHelper.mqh"
#include "TimeLapseNode.mqh"

//+------------------------------------------------------------------+
/**
 * @brief Tree structure to manage time lapses.
 */
class TimeLapseTree
  {
private:
   TimeLapseNode* root; ///< Root node of the tree

   /**
    * @brief Recursively inserts a node into the tree.
    * @param node Current node
    * @param id Node identifier
    * @param start Start time of the time lapse
    * @param end End time of the time lapse
    * @return Pointer to the inserted node
    */
   TimeLapseNode* InsertRecursive(TimeLapseNode* node, int id, datetime start, datetime end);

   /**
    * @brief Recursively traverses the tree in-order.
    * @param node Current node
    */
   void              InorderRecursive(TimeLapseNode* node);

   /**
    * @brief Recursively searches for a node by its identifier.
    * @param node Current node
    * @param id Node identifier
    * @return Pointer to the found node
    */
   TimeLapseNode* GetNode(TimeLapseNode* node, int id);

   /**
    * @brief Recursively gets nodes within a specified time range.
    * @param result Array to store the result nodes
    * @param rootNode Current node
    * @param dt Time to check within the range
    */
   void              GetNodesInRange(CArrayObj &result, TimeLapseNode* rootNode, datetime dt);

   /**
    * @brief Collects identifiers of all nodes.
    * @param node Current node
    * @param identifiers Array to store the identifiers
    */
   void              CollectIdentifiers(TimeLapseNode* node, CArrayInt &identifiers);

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
   void              Insert(TimeLapseNode* newNode);

   /**
    * @brief Updates an existing node's time range.
    * @param id Node identifier
    * @param newStart New start time
    * @param newEnd New end time
    * @return True if the update was successful
    */
   bool              UpdateNode(int id, datetime newStart, datetime newEnd);

   /**
    * @brief Updates an existing node with a new node's details.
    * @param newNode Pointer to the new node
    * @return True if the update was successful
    */
   bool              UpdateNode(TimeLapseNode* newNode);

   /**
    * @brief Updates all nodes to current date
   */
   void              UpdateDates(void);

   /**
    * @brief Traverses the tree in-order.
    */
   void              TraverseInorder();

   /**
    * @brief Gets a node by its identifier.
    * @param id Node identifier
    * @return Pointer to the found node
    */
   TimeLapseNode* GetNode(int id);

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
