type t
(** A type defining a projection *)

val init_plus : string -> t
(** [init_plus def] creates a projection based on the specs in [def]. *)

val transform :
  t -> t -> float array -> float array -> float array * float array
(** [transform src dest xs ys] transforms the points [xs], [ys]
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
