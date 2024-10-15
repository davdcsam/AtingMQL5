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
class TimeLapseNode : public CObject
{
public:
    int identifier;           ///< Unique identifier for the node
    datetime startTime;       ///< Start time of the time lapse
    datetime endTime;         ///< End time of the time lapse
    TimeLapseNode *left;  ///< Pointer to the left child
    TimeLapseNode *right; ///< Pointer to the right child

    /**
     * @brief Constructor for TimeLapseNode.
     * @param id Node identifier
     * @param start Start time of the time lapse
     * @param end End time of the time lapse
     */
    TimeLapseNode(int id, datetime start, datetime end)
    {
        identifier = id;
        startTime = start;
        endTime = end;
        left = NULL;
        right = NULL;
    };

    /**
     * @brief Destructor for TimeLapseNode.
     */
    virtual ~TimeLapseNode() 
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
