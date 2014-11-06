/*
 * Updates all stations' wallpapers to a given file
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;

UPDATE Switches
  SET SWI_SW2 = '$(WallpaperPath)'
  WHERE SWI_Type = 'S' AND SWI_Switch = 200
