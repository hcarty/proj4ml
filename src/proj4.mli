type t
val init_plus : string -> t
val transform :
  t -> t -> float array -> float array -> float array * float array
val is_latlong : t -> bool
val is_geocent : t -> bool
val get_def : t -> string
val latlong_from_proj : t -> t
