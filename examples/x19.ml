(*
   Illustrates backdrop plotting of world, US maps.
   Contributed by Wesley Ebisuzaki.

   Updated for OCaml by Hezekiah Carty

   Copyright 2007, 2008, 2010  Hezekiah M. Carty

This file is part of PLplot.

PLplot is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

PLplot is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with PLplot.  If not, see <http://www.gnu.org/licenses/>.
*)

open Plplot
open Printf
open Proj4

let pi = atan 1.0 *. 4.0

let radians_of_degrees d = d /. 180.0 *. pi

(* "Normalize" longitude values so that they always fall between -180.0 and
   180.0 *)
let normalize_longitude lon =
  if lon >= -180.0 && lon <= 180.0 then
    lon
  else
    let times = floor ((abs_float lon +. 180.0) /. 360.0) in
    if lon < 0.0 then
      lon +. 360.0 *. times
    else
      lon -. 360.0 *. times

(* mapform using PROJ.4 *)
let mapform_proj4 transform x y =
  let xy_t = pj_fwd [|radians_of_degrees x; radians_of_degrees y|] transform in
  xy_t.(0), xy_t.(1)

(* Show a Transverse Mercator projection of the USA *)
let () =
  (* Parse and process command line arguments *)
  plparseopts Sys.argv [PL_PARSE_FULL];

  plinit();

  (* The Americas w/transform *)
  let minx = -125.0 in
  let maxx = -60.0 in

  let miny = 20.0 in
  let maxy = 50.0 in

  (* merc projection. *)
  let merc = pj_init [|"proj=tmerc"; "lon_0=100w"|] in

  let minx_win, miny_win = mapform_proj4 merc (normalize_longitude minx) miny in
  let maxx_win, maxy_win = mapform_proj4 merc (normalize_longitude maxx) maxy in

  plcol0 1;
  pllsty 1;
  plenv minx_win maxx_win miny_win maxy_win 1 (-1);
  plset_mapform (mapform_proj4 merc);
  plmap "usaglobe" minx maxx miny maxy;
  (* This call to plmeridians is also after the set_mapform call, so it uses
     the same projection as the plmap call above. *)
  pllsty 2;
  plcol0 10;
  plmeridians 10.0 10.0 0.0 360.0 (-10.0) 80.0;

  plcol0 1;
  pllab "" "" "Transverse Mercator Projection of the USA";

  plend ();
  ()
