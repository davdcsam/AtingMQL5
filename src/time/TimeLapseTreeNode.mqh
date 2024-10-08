//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Object.mqh>

//+------------------------------------------------------------------+
/**
 * @brief Node structure for the TimeLapseTree.
 */
class TimeLapseTreeNode : public CObject
{
public:
    int identifier;           ///< Unique identifier for the node
    datetime startTime;       ///< Start time of the time lapse
    datetime endTime;         ///< End time of the time lapse
    TimeLapseTreeNode *left;  ///< Pointer to the left child
    TimeLapseTreeNode *right; ///< Pointer to the right child

    /**
     * @brief Constructor for TimeLapseTreeNode.
     * @param id Node identifier
     * @param start Start time of the time lapse
     * @param end End time of the time lapse
     */
    TimeLapseTreeNode(int id, datetime start, datetime end)
    {
        identifier = id;
        startTime = start;
        endTime = end;
        left = NULL;
        right = NULL;
    };

    /**
     * @brief Destructor for TimeLapseTreeNode.
     */
    virtual ~TimeLapseTreeNode() 
    {
        if (left != NULL)
        {
            delete left;
            left = NULL;
        }
        if (right != NULL)
        {
            delete right;
            right = NULL;
        }
    };
};
//+------------------------------------------------------------------+
