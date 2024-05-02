//+------------------------------------------------------------------+
//|                                                    RemoveHandler |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include "Remove.mqh";

input group "Remove";

input bool input_remove_positions_out_section_time = false; // Remove Positions Out Section Time

input bool input_remove_pending_orders_out_section_time = true; // Remove Pending Orders Out Section Time

input bool input_show_remove_handler_comment = true; // Show Comment

string comment_remove_handler;

Remove remove();


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void update_comment_remove()
  {
   if(input_show_remove_handler_comment)
      comment_remove_handler =  StringFormat(
                                   "\n Remove Positions Out: %s\n Remove Pending Orders Out: %s\n",
                                   input_remove_positions_out_section_time ? "Allowed" : "Prohibited",
                                   input_remove_pending_orders_out_section_time ? "Allowed" : "Prohibited"
                                );
   else
      comment_remove_handler= "";
  }
//+------------------------------------------------------------------+
