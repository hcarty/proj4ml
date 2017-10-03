type t
(** A type defining a projection *)

type errcode =
  | PJD_ERR_NO_ARGS
  | PJD_ERR_LAT_OR_LON_EXCEED_LIMIT
  | PJD_ERR_TOLERANCE_CONDITION
  | PJD_ERR_CONIC_LAT_EQUAL
  | PJD_ERR_LAT_LARGER_THAN_90
  | PJD_ERR_LAT1_IS_ZERO
  | PJD_ERR_LAT_TS_LARGER_THAN_90
  | PJD_ERR_CONTROL_POINT_NO_DIST
  | PJD_ERR_NO_ROTATION_PROJ
  | PJD_ERR_W_OR_M_ZERO_OR_LESS
  | PJD_ERR_LSAT_NOT_IN_RANGE
  | PJD_ERR_PATH_NOT_IN_RANGE
  | PJD_ERR_H_LESS_THAN_ZERO
  | PJD_ERR_LAT_1_OR_2_ZERO_OR_90
  | PJD_ERR_LAT_0_OR_ALPHA_EQ_90
  | PJD_ERR_ELLIPSOID_USE_REQUIRED
  | PJD_ERR_INVALID_UTM_ZONE
  | PJD_ERR_FAILED_TO_FIND_PROJ
  | PJD_ERR_INVALID_M_OR_N
  | PJD_ERR_N_OUT_OF_RANGE
  | PJD_ERR_ABS_LAT1_EQ_ABS_LAT2
  | PJD_ERR_LAT_0_HALF_PI_FROM_MEAN
  | PJD_ERR_GEOCENTRIC
  | PJD_ERR_UNKNOWN_PRIME_MERIDIAN
  | PJD_ERR_AXIS
  | PJD_ERR_GRID_AREA
  | PJD_ERR_INVALID_SWEEP_AXIS
  | PJD_ERR_INVALID_SCALE
  | PJD_ERR_NON_CONVERGENT
  | PJD_ERR_MISSING_ARGS
  | PJD_ERR_LAT_0_IS_ZERO
  | UNKNOWN_ERRCODE
(** Error codes (taken from projects.h in the source dist. of PROJ.4). *)

exception Proj4_ERR of int

type trans_t = {
  xt : float;
  yt : float;
}
(** A single translated location *)

val init_plus : string -> t
(** [init_plus def] creates a projection based on the specs in [def]. *)

val is_valid : string -> bool
(** [is_valid def] checks to see if the specs in [def] make a valid
    projection. *)

val transform :
  t -> t -> float array -> float array -> float array * float array
(** [transform src dest xs ys] transforms the points [xs], [ys]
    from [src] coordinate system to the [dest] coordinate system. *)

val transform_one :
  t -> t -> float -> float -> trans_t
val transform_one_tuple :
  t -> t -> float -> float -> float * float
(** [transform_one src dest x y] transforms the point [x], [y]
    from [src] coordinate system to the [dest] coordinate system. *)

val is_latlong : t -> bool
(** [is_latlong t] returns [true] if [t] is geographic. *)

val is_geocent : t -> bool
(** [is_geocent t] returns [true] if [t] is geocentric. *)

val get_def : t -> string
(** [get_def t] returns a definition string appropriate for passing to
    {!init_plus}. *)

val latlong_from_proj : t -> t
(** [latlong_from_proj t] returns the geographic coordinate system underlying
    [t]. *)

val errcode_of_int : int -> errcode
(** [errcode_of_int i] converts the PROJ.4 error code [i] into human-readable form. *)
  
val string_of_errcode : errcode -> string
(** [string_of_errcode e] converts the error code [e] into a string. *)
