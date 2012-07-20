type t
val pj_init_plus : string -> t
val pj_transform :
  t -> t -> float array -> float array -> float array * float array
val pj_is_latlong : t -> bool
val pj_is_geocent : t -> bool
val pj_get_def : t -> string
val pj_latlong_from_proj : t -> t
