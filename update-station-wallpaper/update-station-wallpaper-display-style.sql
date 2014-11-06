/*
 * Updates all stations' wallpaper display style to a given setting
 *  1 = tile, 2 = center
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;

UPDATE Switches
  SET SWI_SW1 = $(DisplayStyle)
  WHERE SWI_Type = 'S' AND SWI_Switch = 201
