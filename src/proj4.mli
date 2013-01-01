type t
(** A type defining a projection *)

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
